`timescale 1ns/1ps

module tb_maxpool2x2;

    reg signed [31:0] a;
    reg signed [31:0] b;
    reg signed [31:0] c;
    reg signed [31:0] d;

    wire signed [31:0] max_out;

    maxpool2x2 #(
        .DATA_WIDTH(32)
    ) uut (
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .max_out(max_out)
    );

    initial begin
        $display("--------------------------------------");
        $display("2x2 MaxPool Test");
        $display("--------------------------------------");

        // Test 1
        a = 32'sd3;
        b = 32'sd7;
        c = 32'sd2;
        d = 32'sd5;
        #10;

        $display("Inputs = %d, %d, %d, %d | Output = %d | Expected = 7", a, b, c, d, max_out);

        if (max_out !== 32'sd7) begin
            $display("TEST FAILED at Test 1");
            $stop;
        end

        // Test 2
        a = 32'sd10;
        b = 32'sd4;
        c = 32'sd6;
        d = 32'sd1;
        #10;

        $display("Inputs = %d, %d, %d, %d | Output = %d | Expected = 10", a, b, c, d, max_out);

        if (max_out !== 32'sd10) begin
            $display("TEST FAILED at Test 2");
            $stop;
        end

        // Test 3
        a = -32'sd3;
        b = -32'sd7;
        c = -32'sd2;
        d = -32'sd5;
        #10;

        $display("Inputs = %d, %d, %d, %d | Output = %d | Expected = -2", a, b, c, d, max_out);

        if (max_out !== -32'sd2) begin
            $display("TEST FAILED at Test 3");
            $stop;
        end

        // Test 4
        a = 32'sd0;
        b = 32'sd0;
        c = 32'sd0;
        d = 32'sd0;
        #10;

        $display("Inputs = %d, %d, %d, %d | Output = %d | Expected = 0", a, b, c, d, max_out);

        if (max_out !== 32'sd0) begin
            $display("TEST FAILED at Test 4");
            $stop;
        end

        // Test 5
        a = 32'sd8;
        b = 32'sd8;
        c = 32'sd4;
        d = 32'sd1;
        #10;

        $display("Inputs = %d, %d, %d, %d | Output = %d | Expected = 8", a, b, c, d, max_out);

        if (max_out !== 32'sd8) begin
            $display("TEST FAILED at Test 5");
            $stop;
        end

        $display("--------------------------------------");
        $display("TEST PASSED");
        $display("--------------------------------------");

        #20;
        $stop;
    end

endmodule