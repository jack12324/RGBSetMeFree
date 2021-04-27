
module writeback_tb();
  logic clk, rst_n;
  logic [31:0] MeWb_out_alu_out;
  logic [31:0] MeWb_out_mem_data;
  logic [31:0] MeWb_out_PC_next;
  // Control
  logic [1:0] MeWb_out_result_sel;
  logic [31:0] reg_wrt_data;

  integer err;
  writeback DUT(.*);

  initial begin
    err = 0;
    MeWb_out_alu_out = 32'd10; 
    MeWb_out_mem_data = 32'd20; 
    MeWb_out_PC_next= 32'd30; 

    MeWb_out_result_sel = 2'b00;
    #1;
    if (reg_wrt_data !== MeWb_out_alu_out) begin
      err++;
      $display("reg_wrt_data should be alu_out");
    end

    MeWb_out_result_sel = 2'b01;
    #1;
    if (reg_wrt_data !== MeWb_out_mem_data) begin
      err++;
      $display("reg_wrt_data should be mem_data");
    end

    MeWb_out_result_sel = 2'b10;
    #1;
    if (reg_wrt_data !== MeWb_out_PC_next) begin
      err++;
      $display("reg_wrt_data should be pc next");
    end

    if (!err) begin
      $display("TEST PASSED!");
    end
  end

endmodule