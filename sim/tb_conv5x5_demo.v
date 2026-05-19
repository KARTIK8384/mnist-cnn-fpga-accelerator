`timescale 1ns/1ps

module tb_conv5x5_demo;

    reg clk;
    reg reset;
    reg start;

    wire done;
    wire busy;

    wire signed [31:0] out0;
    wire signed [31:0] out1;
    wire signed [31:0] out2;
    wire signed [31:0] out3;
    wire signed [31:0] out4;
    wire signed [31:0] out5;
    wire signed [31:0] out6;
    wire signed [31:0] out7;
    wire signed [31:0] out8;

    conv5x5_demo uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .done(done),
        .busy(busy),
        .out0(out0),
        .out1(out1),
        .out2(out2),
        .out3(out3),
        .out4(out4),
        .out5(out5),
        .out6(out6),
        .out7(out7),
        .out8(out8)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        start = 0;

        #20;
        reset = 0;

        #20;
        start = 1;
        #10;
        start = 0;

        wait(done);

        #20;

        $display("--------------------------------------");
        $display("5x5 Conv + ReLU Demo Test");
        $display("--------------------------------------");
        $display("Output feature map:");
        $display("%d %d %d", out0, out1, out2);
        $display("%d %d %d", out3, out4, out5);
        $display("%d %d %d", out6, out7, out8);
        $display("--------------------------------------");

        $display("Expected ReLU output:");
        $display("0 0 1");
        $display("0 0 2");
        $display("2 2 0");
        $display("--------------------------------------");

        if (
            out0 === 32'sd0 &&
            out1 === 32'sd0 &&
            out2 === 32'sd1 &&
            out3 === 32'sd0 &&
            out4 === 32'sd0 &&
            out5 === 32'sd2 &&
            out6 === 32'sd2 &&
            out7 === 32'sd2 &&
            out8 === 32'sd0
        ) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $display("--------------------------------------");

        #20;
        $stop;
    end

endmodule