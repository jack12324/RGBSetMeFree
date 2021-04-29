module FeDe(
    // Inputs 
    input clk,
    input rst_n,
    input [31:0] FeDe_in_PC_next,
	input [31:0] FeDe_in_instr,
	input flush,
    input stall,
    // Outputs to the next stage in the pipeline 
    	output [31:0] FeDe_out_PC_next,
	output [31:0] FeDe_out_instr
	
    );

    dff  #(.WIDTH(32)) PC_next_FF (.clk(clk), .rst_n(rst_n | ~flush), .d(FeDe_in_PC_next), .q(FeDe_out_PC_next), .we(stall));
    dff_nop  #(.WIDTH(32)) instr_FF (.clk(clk), .rst_n(rst_n | ~flush), .d(FeDe_in_instr), .q(FeDe_out_instr), .we(stall));
    //dff  #(.WIDTH(1)) Done_FF (.clk(clk), .rst_n(rst_n | ~flush), .d(Done), .q(FeDe_out_Done));

endmodule 