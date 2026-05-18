module argmax #(
    parameter DATA_WIDTH = 32
)(
    input wire signed [DATA_WIDTH-1:0] score_0,
    input wire signed [DATA_WIDTH-1:0] score_1,
    input wire signed [DATA_WIDTH-1:0] score_2,
    input wire signed [DATA_WIDTH-1:0] score_3,
    input wire signed [DATA_WIDTH-1:0] score_4,
    input wire signed [DATA_WIDTH-1:0] score_5,
    input wire signed [DATA_WIDTH-1:0] score_6,
    input wire signed [DATA_WIDTH-1:0] score_7,
    input wire signed [DATA_WIDTH-1:0] score_8,
    input wire signed [DATA_WIDTH-1:0] score_9,

    output reg [3:0] predicted_class,
    output reg signed [DATA_WIDTH-1:0] max_score
);

    always @(*) begin
        max_score = score_0;
        predicted_class = 4'd0;

        if (score_1 > max_score) begin
            max_score = score_1;
            predicted_class = 4'd1;
        end

        if (score_2 > max_score) begin
            max_score = score_2;
            predicted_class = 4'd2;
        end

        if (score_3 > max_score) begin
            max_score = score_3;
            predicted_class = 4'd3;
        end

        if (score_4 > max_score) begin
            max_score = score_4;
            predicted_class = 4'd4;
        end

        if (score_5 > max_score) begin
            max_score = score_5;
            predicted_class = 4'd5;
        end

        if (score_6 > max_score) begin
            max_score = score_6;
            predicted_class = 4'd6;
        end

        if (score_7 > max_score) begin
            max_score = score_7;
            predicted_class = 4'd7;
        end

        if (score_8 > max_score) begin
            max_score = score_8;
            predicted_class = 4'd8;
        end

        if (score_9 > max_score) begin
            max_score = score_9;
            predicted_class = 4'd9;
        end
    end

endmodule