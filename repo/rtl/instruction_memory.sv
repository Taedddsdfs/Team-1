/* verilator lint_off UNUSED */
module instruction_memory #(
    parameter ADDR_WIDTH = 32,    
    parameter DATA_WIDTH = 32,    
    parameter BYTE_WIDTH = 8
)(
    input  logic [ADDR_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] dout
);

    logic [BYTE_WIDTH-1:0] rom_array [4095:0]; 

    initial begin
        $readmemh("program.hex", rom_array);
    end

    always_comb begin
        //  (2^12 = 4096)
        dout = {
            rom_array[addr[11:0] + 3],
            rom_array[addr[11:0] + 2],
            rom_array[addr[11:0] + 1],
            rom_array[addr[11:0]]
        };
    end

endmodule
/* verilator lint_on UNUSED */
