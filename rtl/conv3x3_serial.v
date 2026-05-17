module conv3x3_serial #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire clk,
    input  wire reset,
    input  wire start,

    input  wire signed [DATA_WIDTH-1:0] pixel_in,
    input  wire signed [DATA_WIDTH-1:0] weight_in,
    input  wire signed [ACC_WIDTH-1:0]  bias_in,

    output reg  signed [ACC_WIDTH-1:0] result_out,
    output reg  done,
    output reg  busy,
    output reg  [3:0] index
);

    reg signed [ACC_WIDTH-1:0] acc;
    wire signed [2*DATA_WIDTH-1:0] mult_result;

    assign mult_result = pixel_in * weight_in;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            acc        <= 0;
            result_out <= 0;
            done       <= 0;
            busy       <= 0;
            index      <= 0;
        end else begin
            if (start && !busy) begin
                acc   <= 0;
                done  <= 0;
                busy  <= 1;
                index <= 0;
            end else if (busy) begin
                if (index < 9) begin
                    acc   <= acc + mult_result;
                    index <= index + 1;
                    done  <= 0;
                end else begin
                    result_out <= acc + bias_in;
                    done       <= 1;
                    busy       <= 0;
                end
            end else begin
                done <= 0;
            end
        end
    end

endmodule