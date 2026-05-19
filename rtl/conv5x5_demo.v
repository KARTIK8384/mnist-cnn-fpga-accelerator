module conv5x5_demo #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire clk,
    input  wire reset,
    input  wire start,

    output reg  done,
    output reg  busy,

    output reg signed [ACC_WIDTH-1:0] out0,
    output reg signed [ACC_WIDTH-1:0] out1,
    output reg signed [ACC_WIDTH-1:0] out2,
    output reg signed [ACC_WIDTH-1:0] out3,
    output reg signed [ACC_WIDTH-1:0] out4,
    output reg signed [ACC_WIDTH-1:0] out5,
    output reg signed [ACC_WIDTH-1:0] out6,
    output reg signed [ACC_WIDTH-1:0] out7,
    output reg signed [ACC_WIDTH-1:0] out8
);

    reg signed [DATA_WIDTH-1:0] image  [0:24];
    reg signed [DATA_WIDTH-1:0] kernel [0:8];

    reg signed [ACC_WIDTH-1:0] acc;
    reg signed [ACC_WIDTH-1:0] raw_result;
    wire signed [ACC_WIDTH-1:0] relu_result;

    reg [3:0] kernel_index;
    reg [3:0] output_index;
    reg [1:0] out_row;
    reg [1:0] out_col;

    wire [4:0] base_index;
    reg  [4:0] image_index;

    assign base_index = (out_row * 5) + out_col;

    relu #(
        .DATA_WIDTH(ACC_WIDTH)
    ) relu_inst (
        .data_in(raw_result),
        .data_out(relu_result)
    );

    localparam IDLE       = 3'd0;
    localparam INIT_MAC   = 3'd1;
    localparam MAC        = 3'd2;
    localparam STORE      = 3'd3;
    localparam NEXT       = 3'd4;
    localparam DONE_STATE = 3'd5;

    reg [2:0] state;

    always @(*) begin
        case (kernel_index)
            4'd0: image_index = base_index;
            4'd1: image_index = base_index + 5'd1;
            4'd2: image_index = base_index + 5'd2;
            4'd3: image_index = base_index + 5'd5;
            4'd4: image_index = base_index + 5'd6;
            4'd5: image_index = base_index + 5'd7;
            4'd6: image_index = base_index + 5'd10;
            4'd7: image_index = base_index + 5'd11;
            4'd8: image_index = base_index + 5'd12;
            default: image_index = base_index;
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            image[0]  <= 8'sd1;
            image[1]  <= 8'sd2;
            image[2]  <= 8'sd0;
            image[3]  <= 8'sd1;
            image[4]  <= 8'sd1;

            image[5]  <= 8'sd0;
            image[6]  <= 8'sd1;
            image[7]  <= 8'sd2;
            image[8]  <= 8'sd2;
            image[9]  <= 8'sd0;

            image[10] <= 8'sd1;
            image[11] <= 8'sd0;
            image[12] <= 8'sd1;
            image[13] <= 8'sd0;
            image[14] <= 8'sd1;

            image[15] <= 8'sd2;
            image[16] <= 8'sd1;
            image[17] <= 8'sd0;
            image[18] <= 8'sd1;
            image[19] <= 8'sd0;

            image[20] <= 8'sd1;
            image[21] <= 8'sd2;
            image[22] <= 8'sd1;
            image[23] <= 8'sd0;
            image[24] <= 8'sd1;

            kernel[0] <=  8'sd1;
            kernel[1] <=  8'sd0;
            kernel[2] <= -8'sd1;
            kernel[3] <=  8'sd1;
            kernel[4] <=  8'sd0;
            kernel[5] <= -8'sd1;
            kernel[6] <=  8'sd1;
            kernel[7] <=  8'sd0;
            kernel[8] <= -8'sd1;

            done         <= 1'b0;
            busy         <= 1'b0;
            acc          <= 0;
            raw_result   <= 0;
            kernel_index <= 0;
            output_index <= 0;
            out_row      <= 0;
            out_col      <= 0;
            state        <= IDLE;

            out0 <= 0;
            out1 <= 0;
            out2 <= 0;
            out3 <= 0;
            out4 <= 0;
            out5 <= 0;
            out6 <= 0;
            out7 <= 0;
            out8 <= 0;
        end else begin
            case (state)

                IDLE: begin
                    done <= 1'b0;
                    busy <= 1'b0;

                    if (start) begin
                        busy         <= 1'b1;
                        output_index <= 4'd0;
                        out_row      <= 2'd0;
                        out_col      <= 2'd0;
                        state        <= INIT_MAC;
                    end
                end

                INIT_MAC: begin
                    acc          <= 0;
                    raw_result   <= 0;
                    kernel_index <= 4'd0;
                    state        <= MAC;
                end

                MAC: begin
                    if (kernel_index < 4'd8) begin
                        acc <= acc + image[image_index] * kernel[kernel_index];
                        kernel_index <= kernel_index + 4'd1;
                    end else begin
                        raw_result <= acc + image[image_index] * kernel[kernel_index];
                        state <= STORE;
                    end
                end

                STORE: begin
                    case (output_index)
                        4'd0: out0 <= relu_result;
                        4'd1: out1 <= relu_result;
                        4'd2: out2 <= relu_result;
                        4'd3: out3 <= relu_result;
                        4'd4: out4 <= relu_result;
                        4'd5: out5 <= relu_result;
                        4'd6: out6 <= relu_result;
                        4'd7: out7 <= relu_result;
                        4'd8: out8 <= relu_result;
                    endcase

                    state <= NEXT;
                end

                NEXT: begin
                    if (output_index == 4'd8) begin
                        state <= DONE_STATE;
                    end else begin
                        output_index <= output_index + 4'd1;

                        if (out_col == 2'd2) begin
                            out_col <= 2'd0;
                            out_row <= out_row + 2'd1;
                        end else begin
                            out_col <= out_col + 2'd1;
                        end

                        state <= INIT_MAC;
                    end
                end

                DONE_STATE: begin
                    done <= 1'b1;
                    busy <= 1'b0;
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule