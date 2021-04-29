module memory(
    clk, rst_n,
    // Input
    ExMe_out_alu_out,
    ExMe_out_reg_2,
    ExMe_out_mem_wrt,
    ExMe_out_mem_en,
    // Output
    mem_data,
    done,
	// Wires to mem_ctrl
	DataIn_host,
	tx_done_host,
	rd_valid_host,
	DataOut_host,
	AddrOut_host,
	op_host

  // 
  );
  input clk, rst_n;

  // Data
  input [31:0] ExMe_out_alu_out;
  input [31:0] ExMe_out_reg_2;

  // Control
  input ExMe_out_mem_wrt;
  input ExMe_out_mem_en; // unused LOL

  output [31:0] mem_data;
  output done;
  
//Wires to mem_ctrl
	input logic [511:0] DataIn_host;
	input logic tx_done_host;
	input logic rd_valid_host;

	output logic [511:0] DataOut_host;
	output logic [31:0] AddrOut_host;
	output logic [1:0] op_host;

  // TODO: add test bench

  mem_system dataMem(
    .clk(clk), .rst_n(rst_n), 
    .addr(ExMe_out_alu_out),
    .data_in(ExMe_out_reg_2),
    .wr(ExMe_out_mem_wrt),
    .done(done),
    .data_out(mem_data),
	// Wires to mem_ctrl
	.DataIn_host(DataIn_host),
	.tx_done_host(tx_done_host),
	.rd_valid_host(rd_valid_host),
	.DataOut_host(DataOut_host),
	.AddrOut_host(AddrOut_host),
	.op_host(op_host),
	// extras unused
	.data_valid(),
	.CacheHit()
    );
   // output logic done, different from data_valid?


endmodule