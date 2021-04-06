/*
	ECE 554
	Project: RGB Set Me Free!
	Team: Who's Waldo
	Filename        : fetch.sv
	Description     : This is the module for the overall fetch stage of the processor.
*/

module fetch (clk, rst, in_PC_next, stall, flush, INT, INT_INST, out_PC_next, instr, ACK);
	input clk, rst_n;
	input [31:0] in_PC_next;
	input stall, flush;
	// for interrupts
	input INT;
	input [31:0] INT_INST;

	output [15:0] out_PC_next;
	output [15:0] instr;
	// for interrupts
	output ACK;

	wire [15:0] addr;
	wire [15:0] PC_next;

	cla_16b adder(.A(32'd4), .B(addr), .C_in(1'b0), .S(nextInstrAddr), .C_out(PC_next));
	regDFF PC(.regQ(addr), .regD(), .clk(clk), .rst(rst), .writeEn(1'b1));
	
	

	// using perfect memory
	//memory2c instructionMem(.data_out(instr), .data_in(), .addr(addr), .enable(1'b1), .wr(1'b0), .createdump(halt), .clk(clk), .rst(rst));
	//assign Done = 1'b1;
	//assign Stall = 1'b0;
	// test with stalling mem
//	stallmem instructionMem_good(.DataOut(instr), .Done(Done), .Stall(Stall), .CacheHit(), .err(err), .Addr(addr), 
//					.DataIn(), .Rd(1'b1), .Wr(1'b0), .createdump(halt), .clk(clk), .rst(rst));

	// final mem
	 mem_system instructionMem(.DataOut(instr), .Done(Done), .Stall(Stall), .CacheHit(), .err(err), .Addr(addr), 
					.DataIn(), .Rd(1'b1), .Wr(1'b0), .createdump(halt), .clk(clk), .rst(rst));

	// halt
	
	assign nextPC = ((halt & ~flush) | savedflush) ? addr : nextAddr;
endmodule
