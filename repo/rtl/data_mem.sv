/* verilator lint_off UNUSED */
module data_mem #(
    parameter DATA_WIDTH = 32,
    parameter ADDRESS_WIDTH = 17, 
    parameter BYTE_WIDTH = 8
)(
    input  logic                  clk,
    input  logic                  WE,
    input  logic [2:0]            funct3,
    input  logic [DATA_WIDTH-1:0] A,
    input  logic [DATA_WIDTH-1:0] WD,
    output logic [DATA_WIDTH-1:0] RD
);

    logic [BYTE_WIDTH-1:0] mem [2**ADDRESS_WIDTH-1:0]; 
    
    logic [ADDRESS_WIDTH-1:0] addr;
    assign addr = A[ADDRESS_WIDTH-1:0];

    initial begin
        // 1. 清零
        for (int i = 0; i < 2**ADDRESS_WIDTH; i++) begin
            mem[i] = 8'b0;
        end


        $display("Loading gaussian.mem to address 0x10000...");
        $readmemh("tests/gaussian.mem", mem, 17'h10000); 
    end


    always_comb begin
        case (funct3)
            3'b100:  RD = {24'b0, mem[addr]}; // LBU
            default: RD = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]}; // LW
        endcase
    end

    always_ff @(posedge clk) begin
        if (WE) begin
            case (funct3)
                3'b000: mem[addr] <= WD[7:0]; // SB
                default: begin // SW
                    mem[addr]   <= WD[7:0];
                    mem[addr+1] <= WD[15:8];
                    mem[addr+2] <= WD[23:16];
                    mem[addr+3] <= WD[31:24];
                end
            endcase
        end
    end

endmodule
/* verilator lint_on UNUSED */

