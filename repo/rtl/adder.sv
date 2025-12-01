module adder (
    input  logic [31:0] a_i,        // Input operand A
    input  logic [31:0] b_i,        // Input operand B
    output logic [31:0] sum_o       // Output sum (A + B)
);

    assign sum_o = a_i + b_i;

endmodule