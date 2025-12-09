module hazard_unit (
    input  logic [4:0] rs1_d, rs2_d,
    input  logic [4:0] rs1_e, rs2_e, rd_e,
    input  logic       pcsrc_e,         
    input  logic [1:0] resultsrc_e,    
    input  logic       regwrite_e,     
    
    input  logic [4:0] rd_m,
    input  logic       regwrite_m,
    
    input  logic [4:0] rd_w,
    input  logic       regwrite_w,
    
    output logic       stall_f,    
    output logic       stall_d,    
    output logic       flush_d,    
    output logic       flush_e,    
    output logic [1:0] forward_a,  
    output logic [1:0] forward_b   
);

    logic lwStall; // Load-Use Hazard 
    // 00: No Forwarding (use RegFile output)
    // 01: Forward from WB Stage (ResultW)
    // 10: Forward from MEM Stage (ALUResultM)
    
    always_comb begin
        // Forward A 
        if      ((rs1_e == rd_m) && regwrite_m && (rs1_e != 0)) forward_a = 2'b10; // Priority: MEM 
        else if ((rs1_e == rd_w) && regwrite_w && (rs1_e != 0)) forward_a = 2'b01; // Secondary: WB
        else                                                    forward_a = 2'b00;
        
        // Forward B
        if      ((rs2_e == rd_m) && regwrite_m && (rs2_e != 0)) forward_b = 2'b10;
        else if ((rs2_e == rd_w) && regwrite_w && (rs2_e != 0)) forward_b = 2'b01;
        else                                                    forward_b = 2'b00;
    end

    always_comb begin
        if ((resultsrc_e == 2'b01) && ((rd_e == rs1_d) || (rd_e == rs2_d)) && (rd_e != 0)) 
            lwStall = 1'b1;
        else 
            lwStall = 1'b0;
    end
    

    assign stall_f = lwStall;
    assign stall_d = lwStall;

    assign flush_d = pcsrc_e;
    
    assign flush_e = lwStall || pcsrc_e;


endmodule
