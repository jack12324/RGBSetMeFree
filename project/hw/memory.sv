module memory(
    clk, rst_n,
    // Input
    ExMe_out_alu_out,
    ExMe_out_reg_2,
    ExMe_out_mem_wrt,
    ExMe_out_mem_en,
    // Output
    mem_data,
    done
  );
  input clk, rst_n;

  // Data
  input [31:0] ExMe_out_alu_out;
  input [31:0] ExMe_out_reg_2;

  // Control
  input ExMe_out_mem_wrt;
  input ExMe_out_mem_en;

  output [31:0] mem_data;
  output done;

  // TODO: add test bench

  mem_system dataMem(
    .clk(clk), .rst_n(rst_n), 
    .addr(ExMe_out_alu_out),
    .data_in(ExMe_out_reg_2),
    .wr(ExMe_out_mem_wrt),
    .en(ExMe_out_mem_en),
    .data_valid(done),
    .data_out(mem_data)
  );

endmodule