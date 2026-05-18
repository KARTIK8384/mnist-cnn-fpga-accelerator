module maxpool2x2 #(
    parameter DATA_WIDTH = 32
)(
    input  wire signed [DATA_WIDTH-1:0] a,
    input  wire signed [DATA_WIDTH-1:0] b,
    input  wire signed [DATA_WIDTH-1:0] c,
    input  wire signed [DATA_WIDTH-1:0] d,

    output wire signed [DATA_WIDTH-1:0] max_out
);

    wire signed [DATA_WIDTH-1:0] max_ab;
    wire signed [DATA_WIDTH-1:0] max_cd;

    assign max_ab  = (a > b) ? a : b;
    assign max_cd  = (c > d) ? c : d;
    assign max_out = ((max_ab > max_cd) ? max_ab : max_cd);

endmodule