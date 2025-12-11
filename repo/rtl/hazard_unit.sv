module hazard_unit (
  
    input  logic [4:0] rs1_d, rs2_d,
    
    input  logic [4:0] rs1_e, rs2_e, rd_e,
    input  logic       pcsrc_e,        
    input  logic [1:0] resultsrc_e,     
    input  logic       regwrite_e,      
    
    //Memory 
    input  logic [4:0] rd_m,
    input  logic       regwrite_m,
    
    //Writeback
    input  logic [4:0] rd_w,
    input  logic       regwrite_w,
    
    output logic       stall_f,    
    output logic       stall_d,    
    output logic       flush_d,    
    output logic       flush_e,    
    output logic [1:0] forward_a, 
    output logic [1:0] forward_b   
);

    logic lwStall; 
    
    always_comb begin
        // Forward A (Rs1)
        if      ((rs1_e == rd_m) && regwrite_m && (rs1_e != 0)) forward_a = 2'b10; // Priority: MEM 
        else if ((rs1_e == rd_w) && regwrite_w && (rs1_e != 0)) forward_a = 2'b01; // Secondary: WB
        else                                                    forward_a = 2'b00;
        
        // Forward B ( Rs2)
        if      ((rs2_e == rd_m) && regwrite_m && (rs2_e != 0)) forward_b = 2'b10;
        else if ((rs2_e == rd_w) && regwrite_w && (rs2_e != 0)) forward_b = 2'b01;
        else                                                    forward_b = 2'b00;
    end

  
    // 2. Stalling Logic   
    always_comb begin
        // ResultSrcE == 2'b01 (check Load)
        if ((resultsrc_e == 2'b01) && ((rd_e == rs1_d) || (rd_e == rs2_d)) && (rd_e != 0)) 
            lwStall = 1'b1;
        else 
            lwStall = 1'b0;
    end
    
   
    // 3. Control Output Logic 
  
    
    // Stall F & D: 
    assign stall_f = lwStall;
    assign stall_d = lwStall;

    assign flush_d = pcsrc_e;
  
    assign flush_e = lwStall || pcsrc_e;

endmodule
