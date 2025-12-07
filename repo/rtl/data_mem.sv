module data_mem #(
    parameter DATA_WIDTH = 32,
    parameter BYTE_WIDTH = 8
)(
    input   logic                       clk,
    input   logic                       WE,
    input   logic   [DATA_WIDTH-1:0]    A,
    input   logic   [DATA_WIDTH-1:0]    WD,
    output  logic   [DATA_WIDTH-1:0]    RD

);
    logic [BYTE_WIDTH-1:0]  data_rom_array [131071:0];      //Memory map from 0x00000000 to 0x0001FFFF

    initial begin
        $display("Loading rom.");
        $readmemh("tests/gaussian.mem", data_rom_array, 65536);
    end

    always_ff @(posedge clk)
        // output is synchronous
        if(WE)    begin
            data_rom_array[A] <= WD;
        end
    
    always_comb
    if (!WE) 
        RD = {data_rom_array[A]};

endmodule


