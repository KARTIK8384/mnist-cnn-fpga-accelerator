`timescale 1ns/1ps

module tb_argmax;

    reg signed [31:0] score_0;
    reg signed [31:0] score_1;
    reg signed [31:0] score_2;
    reg signed [31:0] score_3;
    reg signed [31:0] score_4;
    reg signed [31:0] score_5;
    reg signed [31:0] score_6;
    reg signed [31:0] score_7;
    reg signed [31:0] score_8;
    reg signed [31:0] score_9;

    wire [3:0] predicted_class;
    wire signed [31:0] max_score;

    argmax #(
        .DATA_WIDTH(32)
    ) uut (
        .score_0(score_0),
        .score_1(score_1),
        .score_2(score_2),
        .score_3(score_3),
        .score_4(score_4),
        .score_5(score_5),
        .score_6(score_6),
        .score_7(score_7),
        .score_8(score_8),
        .score_9(score_9),
        .predicted_class(predicted_class),
        .max_score(max_score)
    );

    initial begin
        $display("--------------------------------------");
        $display("Argmax Classifier Test");
        $display("--------------------------------------");

        // Test 1: class 3 should win
        score_0 = -32'sd5;
        score_1 =  32'sd12;
        score_2 =  32'sd3;
        score_3 =  32'sd40;
        score_4 =  32'sd7;
        score_5 =  32'sd9;
        score_6 =  32'sd1;
        score_7 =  32'sd2;
        score_8 =  32'sd15;
        score_9 =  32'sd6;
        #10;

        $display("Test 1: predicted = %d, max_score = %d, expected_class = 3", predicted_class, max_score);

        if (predicted_class !== 4'd3 || max_score !== 32'sd40) begin
            $display("TEST FAILED at Test 1");
            $stop;
        end

        // Test 2: class 0 should win
        score_0 =  32'sd100;
        score_1 =  32'sd12;
        score_2 =  32'sd3;
        score_3 =  32'sd40;
        score_4 =  32'sd7;
        score_5 =  32'sd9;
        score_6 =  32'sd1;
        score_7 =  32'sd2;
        score_8 =  32'sd15;
        score_9 =  32'sd6;
        #10;

        $display("Test 2: predicted = %d, max_score = %d, expected_class = 0", predicted_class, max_score);

        if (predicted_class !== 4'd0 || max_score !== 32'sd100) begin
            $display("TEST FAILED at Test 2");
            $stop;
        end

        // Test 3: class 9 should win
        score_0 = -32'sd10;
        score_1 = -32'sd20;
        score_2 = -32'sd30;
        score_3 = -32'sd40;
        score_4 = -32'sd50;
        score_5 = -32'sd60;
        score_6 = -32'sd70;
        score_7 = -32'sd80;
        score_8 = -32'sd90;
        score_9 = -32'sd1;
        #10;

        $display("Test 3: predicted = %d, max_score = %d, expected_class = 9", predicted_class, max_score);

        if (predicted_class !== 4'd9 || max_score !== -32'sd1) begin
            $display("TEST FAILED at Test 3");
            $stop;
        end

        // Test 4: tie case, first max should win
        score_0 =  32'sd5;
        score_1 =  32'sd20;
        score_2 =  32'sd20;
        score_3 =  32'sd10;
        score_4 =  32'sd3;
        score_5 =  32'sd2;
        score_6 =  32'sd1;
        score_7 =  32'sd0;
        score_8 = -32'sd5;
        score_9 = -32'sd10;
        #10;

        $display("Test 4: predicted = %d, max_score = %d, expected_class = 1", predicted_class, max_score);

        if (predicted_class !== 4'd1 || max_score !== 32'sd20) begin
            $display("TEST FAILED at Test 4");
            $stop;
        end

        $display("--------------------------------------");
        $display("TEST PASSED");
        $display("--------------------------------------");

        #20;
        $stop;
    end

endmodule