//memory is here!
module memory(
    clk, rst_n,
    // Input
    ExMe_out_alu_out,
    ExMe_out_reg_2_data,
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
	op_host,
// jump start FPU
	startFPU

  // 
  );
  input clk, rst_n;

  // Data
  input [31:0] ExMe_out_alu_out;
  input [31:0] ExMe_out_reg_2_data;

  // Control
  input ExMe_out_mem_wrt;
  input ExMe_out_mem_en; 

  output [31:0] mem_data;
  output done;
  
//Wires to mem_ctrl
	input logic [511:0] DataIn_host;
	input logic tx_done_host;
	input logic rd_valid_host;

	output logic [511:0] DataOut_host;
	output logic [31:0] AddrOut_host;
	output logic [1:0] op_host;

// jump start FPU
	output logic startFPU;
  // TODO: add test bench
	///*
  mem_system dataMem(
    .clk(clk), .rst_n(rst_n), 
    .addr(ExMe_out_alu_out),
    .data_in(ExMe_out_reg_2),
    .wr(ExMe_out_mem_wrt),
    .en(ExMe_out_mem_en),
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
	.stall(memStall),
	.CacheHit()
    );
 //*/
  /*
  fake_mem_system #(.FILENAME("project/test_images/memory.h")) dataMem(
    .clk(clk), .rst_n(rst_n), 
    .addr(ExMe_out_alu_out),
    .data_in(ExMe_out_reg_2_data),
    .wr(ExMe_out_mem_wrt),
    .en(ExMe_out_mem_en),
    .done(done),
    .stall(),//none ig
    .data_out(mem_data)
    );
  */	
   // output logic done, different from data_valid?

	// jumpstart FPU
	// always_ff @(posedge clk, negedge rst_n) begin
	// 	if (!rst_n) 
	// 		startFPU <= 0;
	// 	else 
	// 		// if writing to start address, and the instruction is a store
	// 		startFPU <= (ExMe_out_alu_out == 32'h1000_0000 && ExMe_out_mem_wrt && ExMe_out_mem_en); // TODO check address, can I do combinational here?
	// end

	// Mayukh: This assign statement should be sufficient
	assign startFPU = (ExMe_out_alu_out == 32'h1000_0000 && ExMe_out_mem_wrt && ExMe_out_mem_en);

endmodule
