module conv_relu #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire clk,
    input  wire reset,
    input  wire start,

    input  wire signed [DATA_WIDTH-1:0] pixel_in,
    input  wire signed [DATA_WIDTH-1:0] weight_in,
    input  wire signed [ACC_WIDTH-1:0]  bias_in,

    output wire signed [ACC_WIDTH-1:0] conv_result,
    output wire signed [ACC_WIDTH-1:0] relu_result,
    output wire done,
    output wire busy,
    output wire [3:0] index
);

    conv3x3_serial #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) conv_inst (
        .clk(clk),
        .reset(reset),
        .start(start),
        .pixel_in(pixel_in),
        .weight_in(weight_in),
        .bias_in(bias_in),
        .result_out(conv_result),
        .done(done),
        .busy(busy),
        .index(index)
    );

    relu #(
        .DATA_WIDTH(ACC_WIDTH)
    ) relu_inst (
        .data_in(conv_result),
        .data_out(relu_result)
    );

endmodule