// 2-way set-associative, write-through, write-allocate data cache
// Backing store: original data_mem

module data_cache #(
    parameter int DATA_WIDTH  = 32,
    parameter int ADDR_WIDTH  = 17,   // lower ADDR_WIDTH bits are valid
    parameter int BYTE_WIDTH  = 8,
    parameter int CACHE_BYTES = 4096,
    parameter int NUM_WAYS    = 2
) (
    input  logic                  clk,
    input  logic                  rst,

    input  logic                  WE,       // write enable (store)
    input  logic [2:0]            funct3,   // load/store type (same as data_mem)
    input  logic [DATA_WIDTH-1:0] A,        // byte address
    input  logic [DATA_WIDTH-1:0] WD,       // write data
    output logic [DATA_WIDTH-1:0] RD        // read data
);

    // ---------------- Address split ----------------
    localparam int LINE_BYTES  = DATA_WIDTH/8;      // 4 bytes / word
    localparam int NUM_SETS    = CACHE_BYTES / (LINE_BYTES * NUM_WAYS);
    localparam int INDEX_BITS  = $clog2(NUM_SETS);
    localparam int OFFSET_BITS = $clog2(LINE_BYTES); // 2
    localparam int TAG_BITS    = ADDR_WIDTH - INDEX_BITS - OFFSET_BITS;

    // 使用地址的低 ADDR_WIDTH 位
    logic [INDEX_BITS-1:0] index;
    logic [TAG_BITS-1:0]   tag;

    assign index = A[OFFSET_BITS+INDEX_BITS-1 : OFFSET_BITS];
    assign tag   = A[ADDR_WIDTH-1           : OFFSET_BITS+INDEX_BITS];

    // ---------------- Cache arrays ----------------
    logic [DATA_WIDTH-1:0] data_way0 [NUM_SETS-1:0];
    logic [DATA_WIDTH-1:0] data_way1 [NUM_SETS-1:0];
    logic [TAG_BITS-1:0]   tag_way0  [NUM_SETS-1:0];
    logic [TAG_BITS-1:0]   tag_way1  [NUM_SETS-1:0];
    logic                  valid_way0[NUM_SETS-1:0];
    logic                  valid_way1[NUM_SETS-1:0];
    logic                  lru       [NUM_SETS-1:0]; // 0 -> way0 is LRU, 1 -> way1 is LRU

    // ---------------- Backing memory ----------------
    logic [DATA_WIDTH-1:0] mem_rd;

    data_mem #(
        .DATA_WIDTH   (DATA_WIDTH),
        .ADDRESS_WIDTH(ADDR_WIDTH),
        .BYTE_WIDTH   (BYTE_WIDTH)
    ) backing_mem (
        .clk   (clk),
        .WE    (WE),
        .funct3(funct3),
        .A     (A),
        .WD    (WD),
        .RD    (mem_rd)
    );

    // ---------------- Hit detection ----------------
    logic hit0, hit1;
    assign hit0 = valid_way0[index] && (tag_way0[index] == tag);
    assign hit1 = valid_way1[index] && (tag_way1[index] == tag);

    logic [DATA_WIDTH-1:0] cache_word;
    logic                  cache_hit;

    always_comb begin
        cache_hit  = 1'b0;
        cache_word = '0;
        if (hit0) begin
            cache_hit  = 1'b1;
            cache_word = data_way0[index];
        end else if (hit1) begin
            cache_hit  = 1'b1;
            cache_word = data_way1[index];
        end
    end

    // ---------------- Load data select ----------------
    logic [DATA_WIDTH-1:0] word_for_load;
    assign word_for_load = cache_hit ? cache_word : mem_rd;

    // 和 data_mem 一样实现 LBU / LW
    always_comb begin
        unique case (funct3)
            3'b100: RD = {24'b0, word_for_load[7:0]}; // LBU
            default: RD = word_for_load;              // LW 等
        endcase
    end

    // ---------------- Cache update logic ----------------
    integer i;

    always_ff @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < NUM_SETS; i++) begin
                valid_way0[i] <= 1'b0;
                valid_way1[i] <= 1'b0;
                lru[i]        <= 1'b0;
                data_way0[i]  <= '0;
                data_way1[i]  <= '0;
                tag_way0[i]   <= '0;
                tag_way1[i]   <= '0;
            end
        end else begin
            // ---------- LOAD path (WE == 0) ----------
            if (!WE) begin
                // miss 时把 backing memory 里的 word 填进 cache
                if (!cache_hit) begin
                    if (lru[index] == 1'b0) begin
                        // 替换 way0
                        data_way0[index]  <= mem_rd;
                        tag_way0[index]   <= tag;
                        valid_way0[index] <= 1'b1;
                        lru[index]        <= 1'b1; // way1 becomes LRU
                    end else begin
                        // 替换 way1
                        data_way1[index]  <= mem_rd;
                        tag_way1[index]   <= tag;
                        valid_way1[index] <= 1'b1;
                        lru[index]        <= 1'b0; // way0 becomes LRU
                    end
                end else begin
                    // 命中时更新 LRU
                    if (hit0)      lru[index] <= 1'b1;
                    else if (hit1) lru[index] <= 1'b0;
                end
            end
            // ---------- STORE path (WE == 1) ----------
            else begin
                // 为了保持和 data_mem 一致：
                // SB: 只更新低字节，高 24 bit 来自 mem_rd（原来的值）
                // SW: 整个 word 等于 WD
                // (注意：data_mem 自己已经被写-through 更新)

                // 选择要写入 cache 的 word
                logic [DATA_WIDTH-1:0] store_word_sb;
                store_word_sb = {mem_rd[31:8], WD[7:0]};

                // 命中 way0
                if (hit0) begin
                    if (funct3 == 3'b000)   // SB
                        data_way0[index] <= store_word_sb;
                    else                    // SW
                        data_way0[index] <= WD;

                    tag_way0[index]   <= tag;
                    valid_way0[index] <= 1'b1;
                    lru[index]        <= 1'b1;
                end
                // 命中 way1
                else if (hit1) begin
                    if (funct3 == 3'b000)
                        data_way1[index] <= store_word_sb;
                    else
                        data_way1[index] <= WD;

                    tag_way1[index]   <= tag;
                    valid_way1[index] <= 1'b1;
                    lru[index]        <= 1'b0;
                end
                // miss：按 LRU 替换
                else begin
                    if (lru[index] == 1'b0) begin
                        if (funct3 == 3'b000)
                            data_way0[index] <= store_word_sb;
                        else
                            data_way0[index] <= WD;

                        tag_way0[index]   <= tag;
                        valid_way0[index] <= 1'b1;
                        lru[index]        <= 1'b1;
                    end else begin
                        if (funct3 == 3'b000)
                            data_way1[index] <= store_word_sb;
                        else
                            data_way1[index] <= WD;

                        tag_way1[index]   <= tag;
                        valid_way1[index] <= 1'b1;
                        lru[index]        <= 1'b0;
                    end
                end
            end
        end
    end

endmodule


