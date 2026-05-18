`timescale 1ns/1ps

module tb_relu;

    reg  signed [31:0] data_in;
    wire signed [31:0] data_out;

    relu #(
        .DATA_WIDTH(32)
    ) uut (
        .data_in(data_in),
        .data_out(data_out)
    );

    initial begin
        $display("--------------------------------------");
        $display("ReLU Activation Test");
        $display("--------------------------------------");

        data_in = -32'sd10;
        #10;
        $display("Input = %d, Output = %d, Expected = 0", data_in, data_out);
        if (data_out !== 32'sd0) begin
            $display("TEST FAILED at input -10");
            $stop;
        end

        data_in = 32'sd0;
        #10;
        $display("Input = %d, Output = %d, Expected = 0", data_in, data_out);
        if (data_out !== 32'sd0) begin
            $display("TEST FAILED at input 0");
            $stop;
        end

        data_in = 32'sd25;
        #10;
        $display("Input = %d, Output = %d, Expected = 25", data_in, data_out);
        if (data_out !== 32'sd25) begin
            $display("TEST FAILED at input 25");
            $stop;
        end

        data_in = -32'sd1;
        #10;
        $display("Input = %d, Output = %d, Expected = 0", data_in, data_out);
        if (data_out !== 32'sd0) begin
            $display("TEST FAILED at input -1");
            $stop;
        end

        data_in = 32'sd100;
        #10;
        $display("Input = %d, Output = %d, Expected = 100", data_in, data_out);
        if (data_out !== 32'sd100) begin
            $display("TEST FAILED at input 100");
            $stop;
        end

        $display("--------------------------------------");
        $display("TEST PASSED");
        $display("--------------------------------------");

        #20;
        $stop;
    end

endmodule