module kernel_rom_3x3_hex #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 9
)(
    input  wire [3:0] addr,
    output reg signed [DATA_WIDTH-1:0] data
);

    reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];

    initial begin
        $readmemh("data/kernel_3x3.hex", memory);
    end

    always @(*) begin
        data = memory[addr];
    end

endmodule