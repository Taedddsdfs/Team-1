module registerfile #(
    parameter ADDRESS_WIDTH = 5,
              DATA_WIDTH = 32
) (
    input  logic                   clk,
    input  logic                   WE3,
    input  logic [ADDRESS_WIDTH-1:0] AD1,
    input  logic [ADDRESS_WIDTH-1:0] AD2,
    input  logic [ADDRESS_WIDTH-1:0] AD3,
    input  logic [DATA_WIDTH-1:0]    WD3,
    output logic [DATA_WIDTH-1:0]    RD1,
    output logic [DATA_WIDTH-1:0]    RD2,
    output logic [DATA_WIDTH-1:0]    a0
);

 
    logic [DATA_WIDTH-1:0] registers [2**ADDRESS_WIDTH-1:0];

    always_comb begin
        
        RD1 = (AD1 == 5'd0) ? 32'd0 : registers[AD1];
        RD2 = (AD2 == 5'd0) ? 32'd0 : registers[AD2];
        
        
        a0 = registers[10];
    end

    always_ff @(posedge clk) begin
        if (WE3 && (AD3 != 5'd0)) begin
            registers[AD3] <= WD3;
        end
    end

endmodule
