module mux3_1(in_reg, in_alu, in_wb, sel, out);
    input [31:0] in_reg, in_alu, in_wb;
    input [1:0] sel;
    output [31:0] out;

    assign out = (sel == 2'd0) ? in_reg :
                 (sel == 2'd1) ? in_alu :
                 (sel == 2'd2) ? in_wb  : 32'hxxxx : 32'hxxxx;
endmodule

module mux2_1(in0, in1, sel, out);
    input [31:0] in0, in1;
    input sel;
    output [31:0] out;

    assign out = (sel == 1'b1) ? in1 : in0;
endmodule
