module registerfile(
    input logic          clk,
    input logic          rst
    input logic          WE3,
    input logic   [4:0]  AD1,
    input logic   [4:0]  AD2,
    input logic   [4:0]  AD3,
    input logic  [31:0]  WD3,
    output logic [31:0]  RD1,
    output logic [31:0]  RD2,
    output logic [31:0]  a0,
);

logic [31:0] registers [31:0];

initial begin
    for(int i = 0; i < 32; i++){
        registers[i] = 32'h0;
    }
end;

always_ff @(posedge clk)begin
    if(rst)begin
        for(int i = 0; i < 32; i++){
        registers[i] = 32'h0;
    }
    end;
    else if(WE3 && (AD3 != 5'b0))begin
        registers[AD3] <= WD3;
    end;
end;

    assign RD1 = (AD1 == 5'b0) ? 32'h0 : registers[AD1];
    assign RD2 = (AD2 == 5'b0) ? 32'h0 : registers[AD2];
    assign a0 = registers[10];

endmodule
