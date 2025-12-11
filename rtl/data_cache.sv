/* verilator lint_off UNUSED */
module data_cache #(
    parameter DATA_WIDTH    = 32,
    parameter ADDRESS_WIDTH = 17,
    parameter BYTE_WIDTH    = 8
)(
    input  logic                  clk,
    input  logic                  WE,
    input  logic [2:0]            funct3,
    input  logic [DATA_WIDTH-1:0] A,     // byte address
    input  logic [DATA_WIDTH-1:0] WD,
    output logic [DATA_WIDTH-1:0] RD
);

    logic [BYTE_WIDTH-1:0] mem [2**ADDRESS_WIDTH-1:0];

    logic [ADDRESS_WIDTH-1:0] addr;
    assign addr = A[ADDRESS_WIDTH-1:0];

    logic [ADDRESS_WIDTH-1:0] addr_word_base;
    assign addr_word_base = {addr[ADDRESS_WIDTH-1:2], 2'b00};

    localparam int CACHE_BYTES = 4096;
    localparam int LINE_BYTES  = 4;         
    localparam int WAYS        = 2;
    localparam int SETS        = CACHE_BYTES / (WAYS * LINE_BYTES);

    localparam int OFFSET_BITS = 2;          // 4 bytes
    localparam int INDEX_BITS  = $clog2(SETS);
    localparam int TAG_BITS    = DATA_WIDTH - OFFSET_BITS - INDEX_BITS;

    logic [TAG_BITS-1:0]   cache_tag   [WAYS-1:0][SETS-1:0];
    logic [DATA_WIDTH-1:0] cache_data  [WAYS-1:0][SETS-1:0];
    logic                  cache_valid [WAYS-1:0][SETS-1:0];


    logic                  lru         [SETS-1:0];

    logic [TAG_BITS-1:0]    tag;
    logic [INDEX_BITS-1:0]  index;
    logic [OFFSET_BITS-1:0] byte_off;

    assign byte_off = A[OFFSET_BITS-1:0];
    assign index    = A[OFFSET_BITS+INDEX_BITS-1 : OFFSET_BITS];
    assign tag      = A[DATA_WIDTH-1 : OFFSET_BITS+INDEX_BITS];

    logic [31:0] mem_word_now;
    logic [31:0] old_word;
    logic [31:0] new_word;
    logic        hit_way0;
    logic        hit_way1;

    integer i, s, w;
    initial begin
        for (i = 0; i < 2**ADDRESS_WIDTH; i++) begin
            mem[i] = 8'b0;
        end

        for (s = 0; s < SETS; s++) begin
            lru[s] = 1'b0;
            for (w = 0; w < WAYS; w++) begin
                cache_tag  [w][s] = '0;
                cache_data [w][s] = '0;
                cache_valid[w][s] = 1'b0;
            end
        end

        $display("Loading gaussian.mem to address 0x10000...");
        $readmemh("reference/gaussian.mem", mem, 17'h10000);
    end


    logic hit0, hit1, cache_hit;
    logic [DATA_WIDTH-1:0] word_from_cache;
    logic [DATA_WIDTH-1:0] word_from_mem;
    logic [DATA_WIDTH-1:0] word_selected;
    logic [7:0]            byte_selected;
    logic                  repl_way;   

    always_comb begin
        hit0           = 1'b0;
        hit1           = 1'b0;
        cache_hit      = 1'b0;
        word_from_cache = '0;
        word_from_mem   = '0;
        word_selected   = '0;
        byte_selected   = '0;
        RD              = '0;
        repl_way        = 1'b0;

        if (cache_valid[0][index] && cache_tag[0][index] == tag) begin
            hit0           = 1'b1;
            word_from_cache = cache_data[0][index];
        end
        if (cache_valid[1][index] && cache_tag[1][index] == tag) begin
            hit1           = 1'b1;
            word_from_cache = cache_data[1][index];
        end

        cache_hit = hit0 | hit1;

        word_from_mem = {
            mem[addr_word_base + 3],
            mem[addr_word_base + 2],
            mem[addr_word_base + 1],
            mem[addr_word_base + 0]
        };

        word_selected = cache_hit ? word_from_cache : word_from_mem;

        if (hit0)
            repl_way = 1'b0;
        else if (hit1)
            repl_way = 1'b1;
        else
            repl_way = lru[index];

        unique case (funct3)
            3'b100: begin
                unique case (byte_off)
                    2'b00: byte_selected = word_selected[7:0];
                    2'b01: byte_selected = word_selected[15:8];
                    2'b10: byte_selected = word_selected[23:16];
                    2'b11: byte_selected = word_selected[31:24];
                endcase
                RD = {24'b0, byte_selected};
            end
            default: begin
                RD = word_selected;
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (WE) begin
            unique case (funct3)
                3'b000: begin
                    mem[addr] <= WD[7:0];
                end

                default: begin
                    mem[addr]     <= WD[7:0];
                    mem[addr+1]   <= WD[15:8];
                    mem[addr+2]   <= WD[23:16];
                    mem[addr+3]   <= WD[31:24];
                end
            endcase
        end

        mem_word_now = {
            mem[addr_word_base + 3],
            mem[addr_word_base + 2],
            mem[addr_word_base + 1],
            mem[addr_word_base + 0]
        };

        hit_way0 = cache_valid[0][index] && cache_tag[0][index] == tag;
        hit_way1 = cache_valid[1][index] && cache_tag[1][index] == tag;

        if (WE) begin
            if (hit_way0)
                old_word = cache_data[0][index];
            else if (hit_way1)
                old_word = cache_data[1][index];
            else
                old_word = mem_word_now;
            unique case (funct3)
                // SB
                3'b000: begin
                    new_word = old_word;
                    unique case (byte_off)
                        2'b00: new_word[7:0]   = WD[7:0];
                        2'b01: new_word[15:8]  = WD[7:0];
                        2'b10: new_word[23:16] = WD[7:0];
                        2'b11: new_word[31:24] = WD[7:0];
                    endcase
                end

                // SW
                default: begin
                    new_word = WD;
                end
            endcase

            cache_data [repl_way][index] <= new_word;
            cache_tag  [repl_way][index] <= tag;
            cache_valid[repl_way][index] <= 1'b1;
            lru[index] <= ~repl_way;

        end else begin
            if (!(hit_way0 || hit_way1)) begin
                cache_data [repl_way][index] <= mem_word_now;
                cache_tag  [repl_way][index] <= tag;
                cache_valid[repl_way][index] <= 1'b1;
                lru[index]                   <= ~repl_way;
            end else begin
                if (hit_way0)
                    lru[index] <= 1'b1;  
                else
                    lru[index] <= 1'b0;  
            end
        end
    end

endmodule
/* verilator lint_on UNUSED */

