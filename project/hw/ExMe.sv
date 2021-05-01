module ExMe(

    input clk,
    input rst_n,
    input stall, 
    // Inputs to the pipeline registers 
    // Data signals 
    input logic [31:0] ExMe_in_PC_next,
    input logic DeEx_out_Branch, // for flush
	input logic DeEx_out_Jump, // for flush
    input logic [4:0] DeEx_out_ALU_OP, // for flush
    

    input logic [31:0] ExMe_in_alu_out,
    input logic [31:0] ExMe_in_reg_2_data,
    input logic [31:0] ExMe_in_LR,
    input logic [1:0] ExMe_in_FL,
    input logic [31:0] ExMe_in_LR_wrt_data,
    input logic [1:0] ExMe_in_FL_wrt_data,
    // Control Signals 
    input logic DeEx_out_mem_wrt,
    input logic DeEx_out_mem_en,
    input logic DeEx_out_reg_wrt_en,
    input logic [4:0] DeEx_out_reg_wrt_sel,
    input logic [1:0] DeEx_out_result_sel,
    input logic DeEx_out_LR_read,
    input logic DeEx_out_LR_write,
    input logic DeEx_out_FL_read,
    input logic DeEx_out_FL_write,

    // Ouputs to the next pipeline stage 
    // Data signals 
    output logic [31:0] ExMe_out_PC_next,
    output logic ExMe_out_Branch, // for flush
	output logic ExMe_out_Jump, // for flush
    output logic [4:0] ExMe_out_ALU_OP, // for flush
    

    output logic [31:0] ExMe_out_alu_out,
    output logic [31:0] ExMe_out_reg_2_data,
    output logic [31:0] ExMe_out_LR,
    output logic [1:0] ExMe_out_FL,
    output logic [31:0] ExMe_out_LR_wrt_data,
    output logic [1:0] ExMe_out_FL_wrt_data,
    // Control Signals 
    output logic ExMe_out_mem_wrt,
    output logic ExMe_out_mem_en,
    output logic ExMe_out_reg_wrt_en,
    output logic [4:0] ExMe_out_reg_wrt_sel,
    output logic [1:0] ExMe_out_result_sel,
    output logic ExMe_out_LR_read,
    output logic ExMe_out_LR_write,
    output logic ExMe_out_FL_read,
    output logic ExMe_out_FL_write

);

    dff  #(.WIDTH(32)) PC_next_ff (.clk(clk), .rst_n(rst_n), .d(ExMe_in_PC_next), .q(ExMe_out_PC_next), .we(stall));
    dff  #(.WIDTH(1)) Branch_ff (.clk(clk), .rst_n(rst_n), .d(DeEx_out_Branch), .q(ExMe_out_Branch), .we(stall));
    dff  #(.WIDTH(1)) Jump_ff (.clk(clk), .rst_n(rst_n), .d(DeEx_out_Jump), .q(ExMe_out_Jump), .we(stall));
    dff  #(.WIDTH(5)) ALU_OP_ff (.clk(clk), .rst_n(rst_n), .d(DeEx_out_ALU_OP), .q(ExMe_out_ALU_OP), .we(stall));

    dff  #(.WIDTH(32)) alu_out_ff (.clk(clk), .rst_n(rst_n), .d(ExMe_in_alu_out), .q(ExMe_out_alu_out), .we(stall));
    dff  #(.WIDTH(32)) reg_2_ff (.clk(clk), .rst_n(rst_n), .d(ExMe_in_reg_2_data), .q(ExMe_out_reg_2_data), .we(stall));
    dff  #(.WIDTH(32)) LR_ff (.clk(clk), .rst_n(rst_n), .d(ExMe_in_LR), .q(ExMe_out_LR), .we(stall));
    dff  #(.WIDTH(2)) FL_ff (.clk(clk), .rst_n(rst_n), .d(ExMe_in_FL), .q(ExMe_out_FL), .we(stall));
    dff  #(.WIDTH(32)) LR_wrt_data_ff (.clk(clk), .rst_n(rst_n), .d(ExMe_in_LR_wrt_data), .q(ExMe_out_LR_wrt_data), .we(stall));
    dff  #(.WIDTH(2)) FL_wrt_data_ff (.clk(clk), .rst_n(rst_n), .d(ExMe_in_FL_wrt_data), .q(ExMe_out_FL_wrt_data), .we(stall));

    dff  #(.WIDTH(1)) mem_wrt_ff (.clk(clk), .rst_n(rst_n), .d(DeEx_out_mem_wrt), .q(ExMe_out_mem_wrt), .we(stall));
    dff  #(.WIDTH(1)) mem_en_ff (.clk(clk), .rst_n(rst_n), .d(DeEx_out_mem_en), .q(ExMe_out_mem_en), .we(stall));
    dff  #(.WIDTH(1)) reg_wrt_en_ff (.clk(clk), .rst_n(rst_n), .d(DeEx_out_reg_wrt_en), .q(ExMe_out_reg_wrt_en), .we(stall));
    dff  #(.WIDTH(5)) reg_wrt_sel_ff (.clk(clk), .rst_n(rst_n), .d(ExMe_out_reg_wrt_sel), .q(ExMe_out_reg_wrt_sel), .we(stall));
    dff  #(.WIDTH(2)) result_sel_ff (.clk(clk), .rst_n(rst_n), .d(DeEx_out_result_sel), .q(ExMe_out_result_sel), .we(stall));
    dff  #(.WIDTH(1)) LR_read_ff (.clk(clk), .rst_n(rst_n), .d(DeEx_out_LR_read), .q(ExMe_out_LR_read), .we(stall));
    dff  #(.WIDTH(1)) LR_write_ff (.clk(clk), .rst_n(rst_n), .d(DeEx_out_LR_write), .q(ExMe_out_LR_write), .we(stall));
    dff  #(.WIDTH(1)) FL_read_ff (.clk(clk), .rst_n(rst_n), .d(DeEx_out_FL_read), .q(ExMe_out_FL_read), .we(stall));
    dff  #(.WIDTH(1)) FL_write_ff (.clk(clk), .rst_n(rst_n), .d(DeEx_out_FL_write), .q(ExMe_out_FL_write), .we(stall));




endmodule 