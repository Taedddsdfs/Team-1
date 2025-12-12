module registerfile #(
    parameter ADDRESS_WIDTH = 5,
              DATA_WIDTH = 32
) (
    input logic          clk,
    input logic          WE3,
    input logic   [ADDRESS_WIDTH-1:0]  AD1,
    input logic   [ADDRESS_WIDTH-1:0]  AD2,
    input logic   [ADDRESS_WIDTH-1:0]  AD3,
    input logic  [DATA_WIDTH-1:0]  WD3,
    output logic [DATA_WIDTH-1:0]  RD1,
    output logic [DATA_WIDTH-1:0]  RD2,
    output logic [DATA_WIDTH-1:0]  a0
);
// Array of 32 registers, each 32-bit wide
logic [DATA_WIDTH-1:0] registers [2**ADDRESS_WIDTH-1:0];

assign registers[0] = 0;
// Combinational Logic for Reading
// RISC-V registers are read asynchronously.
always_comb begin
    a0 = registers[10];
    RD1 = registers[AD1];
    RD2 = registers[AD2];
end

always_ff @(posedge clk)
    if (WE3 && (AD3 != 5'd0))       registers[AD3] <= WD3;
// Note: Depending on the synthesizer, explicit assignment 
    // to registers[0] might be needed if read logic doesn't handle x0 explicitly.
    // However, the write condition (AD3 != 0) effectively protects x0.
endmodule
