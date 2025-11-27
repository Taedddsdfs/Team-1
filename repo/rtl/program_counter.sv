module program_counter (
    input  logic        clk,     // Clock signal
    input  logic        rst,     // Reset signal (Active high synchronous reset)
    input  logic        PCSrc,   // Control signal: 0 for PC+4, 1 for Branch
    input  logic [31:0] ImmOp,   // Immediate operand (Branch offset from Sign Extend)
    output logic [31:0] PC       // Current Program Counter (outputs to Instr Mem)
);

    // Internal signals
    logic [31:0] next_PC;    // Next PC value
    logic [31:0] branch_PC;  // Branch target address

    // ---------------------------------------------------------
    // 1. Next Address Logic (Combinational)
    // ---------------------------------------------------------
    
    // Calculate branch target: Current PC + ImmOp
    assign branch_PC = PC + ImmOp;

    // MUX: Select next_PC based on PCSrc.
    // If PCSrc = 1, choose branch_PC. If PCSrc = 0, choose PC + 4.
    assign next_PC = (PCSrc) ? branch_PC : (PC + 32'd4);


    // ---------------------------------------------------------
    // 2. PC Register Update (Sequential)
    // ---------------------------------------------------------
    
    // Update PC on the rising edge of the clock.
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            PC <= 32'd0;    // Reset PC to 0
        end else begin
            PC <= next_PC;  // Update PC to the calculated next address
        end
    end

endmodule
// End of program_counter.sv
