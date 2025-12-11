module hazard_unit (
    input  logic [4:0] rs1_d,
    input  logic [4:0] rs2_d,
    input  logic [4:0] rs1_e,
    input  logic [4:0] rs2_e,

    input  logic [4:0] rd_e,
    input  logic [4:0] rd_m,
    input  logic [4:0] rd_w,

    input  logic       regwrite_e,
    input  logic       regwrite_m,
    input  logic       regwrite_w,

    input  logic [1:0] resultsrc_e,   
    input  logic       pcsrc_e,

    // Outputs
    output logic       stall_f,
    output logic       stall_d,
    output logic       flush_d,
    output logic       flush_e,
    output logic [1:0] forward_a,
    output logic [1:0] forward_b
);

    logic load_use_hazard;

    logic use_rs1_d, use_rs2_d;
    assign use_rs1_d = (rs1_d != 5'd0);
    assign use_rs2_d = (rs2_d != 5'd0);

    assign load_use_hazard =
        (resultsrc_e == 2'b01) && regwrite_e && (rd_e != 5'd0) && (
            (use_rs1_d && (rs1_d == rd_e)) ||
            (use_rs2_d && (rs2_d == rd_e))
        );


    assign stall_f = load_use_hazard;
    assign stall_d = load_use_hazard;

    assign flush_e = load_use_hazard | pcsrc_e;
    assign flush_d = pcsrc_e;

    always_comb begin
        if (regwrite_m && (rd_m != 5'd0) && (rd_m == rs1_e)) begin
            forward_a = 2'b10;      // from M
        end else if (regwrite_w && (rd_w != 5'd0) && (rd_w == rs1_e)) begin
            forward_a = 2'b01;      // from W
        end else begin
            forward_a = 2'b00;      // no forwarding
        end
    end

    always_comb begin
        if (regwrite_m && (rd_m != 5'd0) && (rd_m == rs2_e)) begin
            forward_b = 2'b10;
        end else if (regwrite_w && (rd_w != 5'd0) && (rd_w == rs2_e)) begin
            forward_b = 2'b01;
        end else begin
            forward_b = 2'b00;
        end
    end

endmodule


