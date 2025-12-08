module mux2 #(
    parameter WIDTH = 32
) (
    input  logic [WIDTH-1:0] d0, // Input 0 (Default)
    input  logic [WIDTH-1:0] d1, // Input 1 (Selected when s = 1)
    input  logic             s,  // Select signal
    output logic [WIDTH-1:0] y   // Output result
);

    // If s is 1, output d1; otherwise output d0
    assign y = s ? d1 : d0;

endmodule
