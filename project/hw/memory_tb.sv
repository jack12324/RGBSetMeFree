
// TODO: 
module memory_tb();
  // Input
  // Control
  logic clk, rst_n;

  // Data
  logic [31:0] ExMe_out_alu_out;
  logic [31:0] ExMe_out_reg_2;

  // Control
  logic ExMe_out_mem_wrt;
  logic ExMe_out_mem_en;

  // Output
  logic [31:0] mem_data;
  logic done;

  integer err;
  memory DUT(.*);

  initial begin
    err = 0;

    if (!err) begin
      $display("TEST PASSED!");
    end
  end

endmodule