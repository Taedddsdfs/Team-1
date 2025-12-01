module mux2 (
    input  logic [31:0] d0_i,       // Input 0 (e.g., PC + 4)
    input  logic [31:0] d1_i,       // Input 1 (e.g., Branch Target)
    input  logic        sel_i,      // Select signal
    output logic [31:0] y_o         // Output
);

    // If sel_i is 1, choose d1. Else choose d0.
    assign y_o = sel_i ? d1_i : d0_i;

endmodule