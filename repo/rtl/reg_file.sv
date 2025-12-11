module reg_file #(
    parameter ADDRESS_WIDTH = 5,
    parameter DATA_WIDTH = 32
) (
    input  logic                   clk,
    input  logic                   we3, 
    input  logic [ADDRESS_WIDTH-1:0] a1,  
    input  logic [ADDRESS_WIDTH-1:0] a2,  
    input  logic [ADDRESS_WIDTH-1:0] a3,  
    input  logic [DATA_WIDTH-1:0]    wd3, 
    output logic [DATA_WIDTH-1:0]    rd1, 
    output logic [DATA_WIDTH-1:0]    rd2,  
    output logic [DATA_WIDTH-1:0]    a0  
);
    logic [DATA_WIDTH-1:0] registers [2**ADDRESS_WIDTH-1:0];

    always_comb begin
        rd1 = (a1 == 5'd0) ? 32'd0 : registers[a1];
        rd2 = (a2 == 5'd0) ? 32'd0 : registers[a2];
    end
    
    always_ff @(negedge clk) begin 
        if (we3 && (a3 != 5'd0)) begin
            registers[a3] <= wd3;
        end
    end
    assign a0 = registers[10];

endmodule
