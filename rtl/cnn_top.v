module cnn_top (
    input  wire CLOCK_50,
    input  wire [1:0] KEY,
    input  wire [3:0] SW,
    output wire [7:0] LED
);

    wire reset;
    reg start;

    reg signed [7:0] pixel_in;
    reg signed [7:0] weight_in;
    reg signed [31:0] bias_in;

    wire signed [31:0] result_out;
    wire done;
    wire busy;
    wire [3:0] index;

    assign reset = ~KEY[0];

    conv3x3_serial uut (
        .clk(CLOCK_50),
        .reset(reset),
        .start(start),
        .pixel_in(pixel_in),
        .weight_in(weight_in),
        .bias_in(bias_in),
        .result_out(result_out),
        .done(done),
        .busy(busy),
        .index(index)
    );

    always @(posedge CLOCK_50 or posedge reset) begin
        if (reset) begin
            start     <= 1'b0;
            pixel_in  <= 8'sd1;
            weight_in <= 8'sd1;
            bias_in   <= 32'sd0;
        end else begin
            start     <= SW[0];
            pixel_in  <= 8'sd1;
            weight_in <= 8'sd1;
            bias_in   <= 32'sd0;
        end
    end

    assign LED[0] = done;
    assign LED[1] = busy;
    assign LED[5:2] = index;
    assign LED[7:6] = result_out[1:0];

endmodule