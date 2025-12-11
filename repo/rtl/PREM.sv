module PREM #(
    parameter DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst,

    input  logic                  regwrite_e,
    input  logic [1:0]            resultsrc_e,
    input  logic                  memwrite_e,
    input  logic [2:0]            funct3_e, 

    input  logic [DATA_WIDTH-1:0] aluresult_e, 
    input  logic [DATA_WIDTH-1:0] writedata_e, 
    input  logic [4:0]            rd_e,        
    input  logic [DATA_WIDTH-1:0] pcplus4_e,   

    output logic                  regwrite_m,
    output logic [1:0]            resultsrc_m,
    output logic                  memwrite_m,
    output logic [2:0]            funct3_m,    

    output logic [DATA_WIDTH-1:0] aluresult_m,
    output logic [DATA_WIDTH-1:0] writedata_m,
    output logic [4:0]            rd_m,
    output logic [DATA_WIDTH-1:0] pcplus4_m
);

    always_ff @(posedge clk) begin
        if (rst) begin
            regwrite_m   <= 1'b0;
            resultsrc_m  <= 2'b0;
            memwrite_m   <= 1'b0;
            funct3_m     <= 3'b0;
            
            aluresult_m  <= '0;
            writedata_m  <= '0;
            rd_m         <= '0;
            pcplus4_m    <= '0;
        end
        else begin
            regwrite_m   <= regwrite_e;
            resultsrc_m  <= resultsrc_e;
            memwrite_m   <= memwrite_e;
            funct3_m     <= funct3_e;

            aluresult_m  <= aluresult_e;
            writedata_m  <= writedata_e;
            rd_m         <= rd_e;
            pcplus4_m    <= pcplus4_e;
        end
    end


endmodule
