`timescale 1ns/1ps

module tb_conv3x3_serial;

    reg clk;
    reg reset;
    reg start;

    reg signed [7:0] pixel_in;
    reg signed [7:0] weight_in;
    reg signed [31:0] bias_in;

    wire signed [31:0] result_out;
    wire done;
    wire busy;
    wire [3:0] index;

    reg signed [7:0] pixels  [0:8];
    reg signed [7:0] weights [0:8];

    integer i;

    conv3x3_serial uut (
        .clk(clk),
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

    // 100 MHz simulation clock: 10 ns period
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

        // 3x3 convolution kernel:
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

        // Hold reset for a short time
        #20;
        reset = 0;

        // Start convolution
        #10;
        start = 1;
        #10;
        start = 0;

        // Feed 9 pixel-weight pairs, one per clock cycle
        for (i = 0; i < 9; i = i + 1) begin
            pixel_in  = pixels[i];
            weight_in = weights[i];
            #10;
        end

        // Wait for result
        wait(done);

        #10;

        $display("--------------------------------------");
        $display("3x3 Serial Convolution");
        $display("--------------------------------------");
        $display("Convolution result = %d", result_out);
        $display("Expected result    = -1");
        $display("--------------------------------------");

        if (result_out == -1)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $display("--------------------------------------");

        #20;
        $stop;
    end

endmodule