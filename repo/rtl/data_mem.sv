module data_mem #(
    parameter DATA_WIDTH = 32,
              ADDRESS_WIDTH = 16,
              BYTE_WIDTH = 8
)(
    input logic                  clk,
    input logic                  WE,
    input logic [DATA_WIDTH-1:0] A,
    input logic [DATA_WIDTH-1:0] WD,
    output logic [DATA_WIDTH-1:0] RD
);

logic [BYTE_WIDTH-1:0] mem [2**ADDRESS_WIDTH-1:0]; // Data memory from 0x00010000 to 0x0001FFFF
logic [ADDRESS_WIDTH-1:0] addr;

assign addr = A[ADDRESS_WIDTH-1:0];

// LBU (load byte)
always_comb begin
    if ((A >= 32'h0000_1000) && (A <= 32'h0001_FFFF)) //if not in the interval, return 0
        RD = {24'b0, mem[addr]};
    else
        RD = 32'h0;
end

// SB (store byte)
always_ff @(posedge clk)
    if (WE && (A >= 32'h0000_1000) && (A <= 32'h0001_FFFF))
        mem[addr] <= WD[7:0];

endmodule


