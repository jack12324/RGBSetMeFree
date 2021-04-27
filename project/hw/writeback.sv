module writeback(
  // Input
  clk, rst_n,
  MeWb_out_alu_out,
  MeWb_out_mem_data,
  MeWb_out_PC_next,
  MeWb_out_result_sel,
  // Output
  reg_wrt_data
  );

  input clk, rst_n;
  // Data
  input [31:0] MeWb_out_alu_out;
  input [31:0] MeWb_out_mem_data;
  input [31:0] MeWb_out_PC_next;
  // Control
  input [1:0] MeWb_out_result_sel;

  output logic [31:0] reg_wrt_data;

  always_comb begin
    case (MeWb_out_result_sel)
      2'b00: reg_wrt_data = MeWb_out_alu_out;  
      2'b01: reg_wrt_data = MeWb_out_mem_data;
      2'b10: reg_wrt_data = MeWb_out_PC_next;
      default: reg_wrt_data = 32'b0;
    endcase
  end

endmodule