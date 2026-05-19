`timescale 1ns/1ps

module tb_conv_relu;

    reg clk;
    reg reset;
    reg start;

    reg signed [7:0] pixel_in;
    reg signed [7:0] weight_in;
    reg signed [31:0] bias_in;

    wire signed [31:0] conv_result;
    wire signed [31:0] relu_result;
    wire done;
    wire busy;
    wire [3:0] index;

    reg signed [7:0] pixels  [0:8];
    reg signed [7:0] weights [0:8];

    integer i;

    conv_relu #(
        .DATA_WIDTH(8),
        .ACC_WIDTH(32)
    ) uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .pixel_in(pixel_in),
        .weight_in(weight_in),
        .bias_in(bias_in),
        .conv_result(conv_result),
        .relu_result(relu_result),
        .done(done),
        .busy(busy),
        .index(index)
    );

    always #5 clk = ~clk;

    initial begin
        clk       = 0;
        reset     = 1;
        start     = 0;
        pixel_in  = 0;
        weight_in = 0;
        bias_in   = 0;

        // 3x3 input image window:
        //
        // 1 2 0
        // 0 1 2
        // 1 0 1

        pixels[0] = 8'sd1;
        pixels[1] = 8'sd2;
        pixels[2] = 8'sd0;
        pixels[3] = 8'sd0;
        pixels[4] = 8'sd1;
        pixels[5] = 8'sd2;
        pixels[6] = 8'sd1;
        pixels[7] = 8'sd0;
        pixels[8] = 8'sd1;

        // 3x3 kernel:
        //
        //  1  0 -1
        //  1  0 -1
        //  1  0 -1

        weights[0] =  8'sd1;
        weights[1] =  8'sd0;
        weights[2] = -8'sd1;
        weights[3] =  8'sd1;
        weights[4] =  8'sd0;
        weights[5] = -8'sd1;
        weights[6] =  8'sd1;
        weights[7] =  8'sd0;
        weights[8] = -8'sd1;

        bias_in = 32'sd0;

        #20;
        reset = 0;

        #10;
        start = 1;
        #10;
        start = 0;

        for (i = 0; i < 9; i = i + 1) begin
            pixel_in  = pixels[i];
            weight_in = weights[i];
            #10;
        end

        wait(done);

        #10;

        $display("--------------------------------------");
        $display("Step 5: Conv + ReLU Integration Test");
        $display("--------------------------------------");
        $display("Convolution result = %d", conv_result);
        $display("Expected conv      = -1");
        $display("ReLU result        = %d", relu_result);
        $display("Expected ReLU      = 0");
        $display("--------------------------------------");

        if (conv_result !== -32'sd1) begin
            $display("TEST FAILED: convolution result mismatch");
            $stop;
        end

        if (relu_result !== 32'sd0) begin
            $display("TEST FAILED: ReLU result mismatch");
            $stop;
        end

        $display("TEST PASSED");
        $display("--------------------------------------");

        #20;
        $stop;
    end

endmodule