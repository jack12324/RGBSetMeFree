module MeWb(
    // inputs to the pipeline register
    // data signals  
    input logic [31:0] ExMe_out_alu_out,
    input logic [31:0] mem_data,
    input logic [31:0] ExMe_out_PC_next, 
    input logic [31:0] MeWb_in_LR,
    input logic [1:0] MeWb_in_FL,
    input logic [31:0] MeWb_in_LR_wrt_data,
    input logic [1:0] MeWb_in_FL_wrt_data,
    // control signals 
    input logic [1:0] ExMe_out_result_sel,
    input logic ExMe_out_reg_write_en,
    input logic [4:0] ExMe_out_reg_write_sel, 
    input logic ExMe_out_LR_read,
    input logic ExMe_out_LR_write,
    input logic ExMe_out_FL_read,
    input logic ExMe_out_FL_write,
    
    // outputs to the pipeline register 
    output logic [31:0] MeWb_out_alu_out,
    output logic [31:0] MeWb_out_mem_data,
    output logic [31:0] MeWb_out_PC_next,
    output logic [31:0] MeWb_out_LR,
    output logic [1:0] MeWb_out_FL,
    output logic [31:0] MeWb_out_LR_wrt_data,
    output logic [1:0] MeWb_out_FL_wrt_data,
    // control signals 
    output logic [1:0] MeWb_out_result_sel,
    output logic MeWb_out_reg_write_sel,
    output logic [4:0] MeWb_out_reg_write_en,
    output logic MeWb_out_LR_read,
    output logic MeWb_out_LR_write,
    output logic MeWb_out_FL_read,
    output logic MeWb_out_FL_write
);

    dff  #(.WIDTH(32)) alu_out_ff (.clk(clk), .rst_n(rst_n), .d(ExMe_out_alu_out), .q(MeWb_out_alu_out));
    dff  #(.WIDTH(32)) mem_data_ff (.clk(clk), .rst_n(rst_n), .d(mem_data), .q(MeWb_out_mem_data));
    dff  #(.WIDTH(32)) PC_next_ff (.clk(clk), .rst_n(rst_n), .d(ExMe_out_PC_next), .q(MeWb_out_PC_next));
    dff  #(.WIDTH(32)) LR_ff (.clk(clk), .rst_n(rst_n), .d(MeWb_in_LR), .q(MeWb_out_LR));
    dff  #(.WIDTH(2)) FL_ff (.clk(clk), .rst_n(rst_n), .d(MeWb_in_FL), .q(MeWb_out_FL));
    dff  #(.WIDTH(32)) LR_wrt_data_ff (.clk(clk), .rst_n(rst_n), .d(MeWb_in_LR_wrt_data), .q(MeWb_out_LR_wrt_data));
    dff  #(.WIDTH(2)) FL_wrt_data_ff (.clk(clk), .rst_n(rst_n), .d(MeWb_in_FL_wrt_data), .q(MeWb_out_FL_wrt_data));

    dff  #(.WIDTH(2)) result_sel_ff (.clk(clk), .rst_n(rst_n), .d(ExMe_out_result_sel), .q(MeWb_out_result_sel));
    dff  #(.WIDTH(1)) reg_write_en_ff (.clk(clk), .rst_n(rst_n), .d(ExMe_out_reg_write_en), .q(MeWb_out_reg_write_sel));
    dff  #(.WIDTH(5)) reg_write_sel_ff (.clk(clk), .rst_n(rst_n), .d(ExMe_out_reg_write_sel), .q(MeWb_out_reg_write_en));
    dff  #(.WIDTH(1)) LR_read_ff (.clk(clk), .rst_n(rst_n), .d(ExMe_out_LR_read), .q(MeWb_out_LR_read));
    dff  #(.WIDTH(1)) LR_write_ff (.clk(clk), .rst_n(rst_n), .d(ExMe_out_LR_write), .q(MeWb_out_LR_write));
    dff  #(.WIDTH(1)) FL_read_ff (.clk(clk), .rst_n(rst_n), .d(ExMe_out_FL_read), .q(MeWb_out_FL_read));
    dff  #(.WIDTH(1)) FL_write_ff (.clk(clk), .rst_n(rst_n), .d(ExMe_out_FL_write), .q(MeWb_out_FL_write));

endmodule