module program_counter #(
    parameter WIDTH = 32
)(
    input  logic             clk,
    input  logic             rst,
    input  logic             en,      
    input  logic [WIDTH-1:0] next_pc, 
    output logic [WIDTH-1:0] pc
);

    always_ff @(posedge clk) begin
        if (rst) begin
            pc <= 32'b0; 
        end 
        else if (en) begin 
            pc <= next_pc;
        end
    end

endmodule
