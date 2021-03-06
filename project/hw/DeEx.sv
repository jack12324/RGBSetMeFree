module DeEx(

    //////////////////////////// Inputs /////////////////////////////
    input clk,
    input rst_n,
	input stall,
    
    input logic [31:0] DeEx_in_PC_next,
	input logic [31:0] DeEx_in_reg_1_data,
	input logic [31:0] DeEx_in_reg_2_data,
	input logic [31:0] DeEx_in_imm,
	input logic flush,
	// special register stuff
	input logic [31:0] DeEx_in_LR,
	input logic [1:0] DeEx_in_FL,
	// control for special registers
	input logic DeEx_in_LR_read,
	input logic DeEx_in_LR_write,
	input logic DeEx_in_FL_read,
	input logic DeEx_in_FL_write,
	//control for forwarding 
	input logic [4:0] DeEx_in_reg_1_sel,
	input logic [4:0] DeEx_in_reg_2_sel,
	// control for Execute
	input logic [1:0] DeEx_in_ALU_src,
	input logic [4:0] DeEx_in_ALU_OP,
	input logic DeEx_in_Branch,
	input logic DeEx_in_Jump,
	// control for Memory
	input logic DeEx_in_mem_wrt,
	input logic DeEx_in_mem_en,
	// control for Writeback
	input logic [1:0] DeEx_in_result_sel,
	input logic DeEx_in_reg_wrt_en,
	input logic [4:0] DeEx_in_reg_wrt_sel,
    //////////////////////////////////////////////////////////////////

    /////////// Output to the next stage in the CPU //////////////////
    output logic [31:0] DeEx_out_PC_next,
	output logic [31:0] DeEx_out_reg_1_data,
	output logic [31:0] DeEx_out_reg_2_data,
	output logic [31:0] DeEx_out_imm,
	// special register stuff
	output logic [31:0] DeEx_out_LR,
	output logic [1:0] DeEx_out_FL,
	// control for special registers
	output logic DeEx_out_LR_read,
	output logic DeEx_out_LR_write,
	output logic DeEx_out_FL_read,
	output logic DeEx_out_FL_write,
	//control for forwarding 
	output logic [4:0] DeEx_out_reg_1_sel,
	output logic [4:0] DeEx_out_reg_2_sel,
	// control for Execute
	output logic [1:0] DeEx_out_ALU_src,
	output logic [4:0] DeEx_out_ALU_OP,
	output logic DeEx_out_Branch,
	output logic DeEx_out_Jump,
	// control for Memory
	output logic DeEx_out_mem_wrt,
	output logic DeEx_out_mem_en,
	// control for Writeback
	output logic [1:0] DeEx_out_result_sel,
	output logic DeEx_out_reg_wrt_en,
	output logic [4:0] DeEx_out_reg_wrt_sel
    //////////////////////////////////////////////////////////////
    );

    dfflop  #(.WIDTH(32)) out_PC_next_ff (.clk(clk), .rst_n(rst_n & ~flush), .d(DeEx_in_PC_next), .q(DeEx_out_PC_next), .we(stall));
    dfflop  #(.WIDTH(32)) reg_1_data_ff (.clk(clk), .rst_n(rst_n & ~flush), .d(DeEx_in_reg_1_data), .q(DeEx_out_reg_1_data), .we(stall));
    dfflop  #(.WIDTH(32)) reg_2_data_ff (.clk(clk), .rst_n(rst_n & ~flush), .d(DeEx_in_reg_2_data), .q(DeEx_out_reg_2_data), .we(stall));
    dfflop  #(.WIDTH(32)) imm_ff (.clk(clk), .rst_n(rst_n & ~flush), .d(DeEx_in_imm), .q(DeEx_out_imm), .we(stall));
       
    dfflop  #(.WIDTH(32)) LR_ff (.clk(clk), .rst_n(rst_n & ~flush), .d(DeEx_in_LR), .q(DeEx_out_LR), .we(stall));
    dfflop  #(.WIDTH(2)) FL_ff (.clk(clk), .rst_n(rst_n & ~flush), .d(DeEx_in_FL), .q(DeEx_out_FL), .we(stall));
       
    dfflop  #(.WIDTH(1)) LR_read_ff (.clk(clk), .rst_n(rst_n & ~flush), .d(DeEx_in_LR_read), .q(DeEx_out_LR_read), .we(stall));
    dfflop  #(.WIDTH(1)) LR_write_ff (.clk(clk), .rst_n(rst_n & ~flush), .d(DeEx_in_LR_write), .q(DeEx_out_LR_write), .we(stall));
    dfflop  #(.WIDTH(1)) FL_read_ff (.clk(clk), .rst_n(rst_n & ~flush), .d(DeEx_in_FL_read), .q(DeEx_out_FL_read), .we(stall));
    dfflop  #(.WIDTH(1)) FL_write_ff (.clk(clk), .rst_n(rst_n & ~flush), .d(DeEx_in_FL_write), .q(DeEx_out_FL_write), .we(stall));
       
    dfflop  #(.WIDTH(5)) reg_1_sel (.clk(clk), .rst_n(rst_n & ~flush), .d(DeEx_in_reg_1_sel), .q(DeEx_out_reg_1_sel), .we(stall));
    dfflop  #(.WIDTH(5)) reg_2_sel (.clk(clk), .rst_n(rst_n & ~flush), .d(DeEx_in_reg_2_sel), .q(DeEx_out_reg_2_sel), .we(stall));
       
    dfflop  #(.WIDTH(2)) ALU_src_ff (.clk(clk), .rst_n(rst_n & ~flush), .d(DeEx_in_ALU_src), .q(DeEx_out_ALU_src), .we(stall));
    dff_nop  #(.WIDTH(5)) ALU_OP_ff (.clk(clk), .rst_n(rst_n & ~flush), .d(DeEx_in_ALU_OP), .q(DeEx_out_ALU_OP), .we(stall));
    dfflop  #(.WIDTH(1)) Branch_ff (.clk(clk), .rst_n(rst_n & ~flush), .d(DeEx_in_Branch), .q(DeEx_out_Branch), .we(stall));
    dfflop  #(.WIDTH(1)) Jump_ff (.clk(clk), .rst_n(rst_n & ~flush), .d(DeEx_in_Jump), .q(DeEx_out_Jump), .we(stall));
       
    dfflop  #(.WIDTH(1)) mem_wrt_ff (.clk(clk), .rst_n(rst_n & ~flush), .d(DeEx_in_mem_wrt), .q(DeEx_out_mem_wrt), .we(stall));
    dfflop  #(.WIDTH(1)) mem_en_ff (.clk(clk), .rst_n(rst_n & ~flush), .d(DeEx_in_mem_en), .q(DeEx_out_mem_en), .we(stall));
       
    dfflop  #(.WIDTH(2)) result_sel_ff (.clk(clk), .rst_n(rst_n & ~flush), .d(DeEx_in_result_sel), .q(DeEx_out_result_sel), .we(stall));
    dfflop  #(.WIDTH(1)) next_reg_wrt_en_ff (.clk(clk), .rst_n(rst_n & ~flush), .d(DeEx_in_reg_wrt_en), .q(DeEx_out_reg_wrt_en), .we(stall));
    dfflop  #(.WIDTH(5)) next_reg_wrt_sel_ff (.clk(clk), .rst_n(rst_n & ~flush), .d(DeEx_in_reg_wrt_sel), .q(DeEx_out_reg_wrt_sel), .we(stall));
endmodule
