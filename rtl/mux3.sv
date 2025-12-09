module mux3 #(
    parameter WIDTH = 32
) (
    input  logic [WIDTH-1:0] d0, 
    input  logic [WIDTH-1:0] d1, 
    input  logic [WIDTH-1:0] d2,
    input  logic [1:0]       s,
    output logic [WIDTH-1:0] y
);
    always_comb begin
        case(s)
            2'b00: y = d0; // ALU Result
            2'b01: y = d1; // Read Data
            2'b10: y = d2; // PC + 4
            default: y = 32'bx;
        endcase
    end
endmodule
