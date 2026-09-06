module image_rom_5x5_hex #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 25
)(
    input  wire [4:0] addr,
    output reg signed [DATA_WIDTH-1:0] data
);

    reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];

    initial begin
        $readmemh("data/image_5x5.hex", memory);
    end

    always @(*) begin
        data = memory[addr];
    end

endmodule