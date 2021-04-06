/*
	ECE 554
	Project: RGB Set Me Free!
	Team: Who's Waldo
	Filename        : fetch.sv
	Description     : This is the module for the overall fetch stage of the processor.
*/

module fetch (nextAddr, nextInstrAddr, instr, err, clk, rst, halt, Done, Stall, flush, savedflush);
	input clk, rst_n;
	input [31:0] PC_next;
	input stall, flush;
	input INT;
	input [31:0] INT_INST;

	output [15:0] nextInstrAddr;
	output [15:0] instr;
	output err;
	output Done, Stall;

	wire [15:0] addr;
	wire [15:0] nextPC;

	wire flushedWhenStalled;

	cla_16b adder(.A(16'd2), .B(addr), .C_in(1'b0), .S(nextInstrAddr), .C_out());
	regDFF PC(.regQ(addr), .regD(nextPC), .clk(clk), .rst(rst), .writeEn(1'b1));

	// earlier perfect memory
	//memory2c instructionMem(.data_out(instr), .data_in(), .addr(addr), .enable(1'b1), .wr(1'b0), .createdump(halt), .clk(clk), .rst(rst));
	//assign Done = 1'b1;
	//assign Stall = 1'b0;
	// test with
//	stallmem instructionMem_good(.DataOut(instr), .Done(Done), .Stall(Stall), .CacheHit(), .err(err), .Addr(addr), 
//					.DataIn(), .Rd(1'b1), .Wr(1'b0), .createdump(halt), .clk(clk), .rst(rst));

	// change to 
	 mem_system instructionMem(.DataOut(instr), .Done(Done), .Stall(Stall), .CacheHit(), .err(err), .Addr(addr), 
					.DataIn(), .Rd(1'b1), .Wr(1'b0), .createdump(halt), .clk(clk), .rst(rst));

	// halt
	
	assign nextPC = ((halt & ~flush) | savedflush) ? addr : nextAddr;
endmodule
