module PRDE #(
    parameter DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst,
    input  logic                  clr,    

    input  logic                  regwrite_d,   
    input  logic [1:0]            resultsrc_d,  
    input  logic                  memwrite_d,  
    input  logic                  jump_d,       
    input  logic                  branch_d,     
    input  logic [3:0]            alucontrol_d, 
    input  logic                  alusrc_d,     
    input  logic                  alusrca_d,    
    input  logic [2:0]            funct3_d,      

    input  logic [DATA_WIDTH-1:0] rd1_d,        
    input  logic [DATA_WIDTH-1:0] rd2_d,        
    input  logic [DATA_WIDTH-1:0] pcd,          
    input  logic [4:0]            rs1_d,        
    input  logic [4:0]            rs2_d,       
    input  logic [4:0]            rd_d,        
    input  logic [DATA_WIDTH-1:0] immext_d,    
    input  logic [DATA_WIDTH-1:0] pcplus4_d,

    output logic                  regwrite_e,
    output logic [1:0]            resultsrc_e,
    output logic                  memwrite_e,
    output logic                  jump_e,
    output logic                  branch_e,
    output logic [3:0]            alucontrol_e,
    output logic                  alusrc_e,
    output logic                  alusrca_e,
    output logic [2:0]            funct3_e,

    output logic [DATA_WIDTH-1:0] rd1_e,
    output logic [DATA_WIDTH-1:0] rd2_e,
    output logic [DATA_WIDTH-1:0] pce,
    output logic [4:0]            rs1_e,
    output logic [4:0]            rs2_e,
    output logic [4:0]            rd_e,
    output logic [DATA_WIDTH-1:0] immext_e,
    output logic [DATA_WIDTH-1:0] pcplus4_e
);

    always_ff @(posedge clk) begin
        if (rst || clr) begin
            regwrite_e   <= 1'b0;
            resultsrc_e  <= 2'b0;
            memwrite_e   <= 1'b0;
            jump_e       <= 1'b0;
            branch_e     <= 1'b0;
            alucontrol_e <= 4'b0;
            alusrc_e     <= 1'b0;
            alusrca_e    <= 1'b0;
            funct3_e     <= 3'b0;
            
            rd1_e        <= '0;
            rd2_e        <= '0;
            pce          <= '0;
            rs1_e        <= '0;
            rs2_e        <= '0;
            rd_e         <= '0;
            immext_e     <= '0;
            pcplus4_e    <= '0;
        end
        else begin
            regwrite_e   <= regwrite_d;
            resultsrc_e  <= resultsrc_d;
            memwrite_e   <= memwrite_d;
            jump_e       <= jump_d;
            branch_e     <= branch_d;
            alucontrol_e <= alucontrol_d;
            alusrc_e     <= alusrc_d;
            alusrca_e    <= alusrca_d;
            funct3_e     <= funct3_d;

            rd1_e        <= rd1_d;
            rd2_e        <= rd2_d;
            pce          <= pcd;
            rs1_e        <= rs1_d;
            rs2_e        <= rs2_d;
            rd_e         <= rd_d;
            immext_e     <= immext_d;
            pcplus4_e    <= pcplus4_d;
        end
    end


endmodule
