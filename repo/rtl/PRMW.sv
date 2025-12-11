module PRMW #(
    parameter DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst,

    input  logic                  regwrite_m,
    input  logic [1:0]            resultsrc_m,

    input  logic [DATA_WIDTH-1:0] aluresult_m,
    input  logic [DATA_WIDTH-1:0] readdata_m,  
    input  logic [4:0]            rd_m,        
    input  logic [DATA_WIDTH-1:0] pcplus4_m,

    output logic                  regwrite_w,
    output logic [1:0]            resultsrc_w,

    output logic [DATA_WIDTH-1:0] aluresult_w,
    output logic [DATA_WIDTH-1:0] readdata_w,
    output logic [4:0]            rd_w,
    output logic [DATA_WIDTH-1:0] pcplus4_w
);

    always_ff @(posedge clk) begin
        if (rst) begin
            regwrite_w   <= 1'b0;
            resultsrc_w  <= 2'b0;
            
            aluresult_w  <= '0;
            readdata_w   <= '0;
            rd_w         <= '0;
            pcplus4_w    <= '0;
        end
        else begin
            regwrite_w   <= regwrite_m;
            resultsrc_w  <= resultsrc_m;

            aluresult_w  <= aluresult_m;
            readdata_w   <= readdata_m;
            rd_w         <= rd_m;
            pcplus4_w    <= pcplus4_m;
        end
    end


endmodule
