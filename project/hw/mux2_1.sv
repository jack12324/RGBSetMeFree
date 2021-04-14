module mux2_1(in0, in1, sel, out);
    input [31:0] in0, in1;
    input [1:0] sel;
    output out;

    assign out = sel == 2'b0 ? in1 : in0;

endmodule
