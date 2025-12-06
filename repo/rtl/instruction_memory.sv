module instruction_memory #(
    parameter DATA_WIDTH = 32,
    parameter BYTE_WIDTH = 8
)(
    input logic [DATA_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] dout
);

    logic [BYTE_WIDTH-1:0] rom_array [4095:0];    //Memory map from 0xBFC00000 to 0xBFC00FFF

    initial begin
    $display("Loading rom from tests/f1.hex");
    $readmemh("tests/f1.hex", rom_array);
    end

    always_comb begin
        // output is  asynchronous
        dout = {rom_array[addr+3],rom_array[addr + 2],rom_array[addr + 1],rom_array[addr]};  //little endian
    end

endmodule
