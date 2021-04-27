
/*
	ECE 554
	Project: RGB Set Me Free!
	Team: Who's Waldo
	Filename        : fetch.sv
	Description     : This is the module for the overall fetch stage of the processor.
*/


`define NOP 32'b01111xxxxxxxxxxxxxxxxxxxxxxxxxxx

module fetch (clk, rst_n, in_PC_next, stall, flush, INT, INT_INSTR, out_PC_next, instr, Done, ACK);
	input clk, rst_n;
	input [31:0] in_PC_next;
	input stall, flush;
	// for interrupts
	input INT;
	input [31:0] INT_INSTR;

	output [31:0] out_PC_next;
	output [31:0] instr;
	output Done;
	// for interrupts
	output ACK;

	// todo: interrupts

	reg [31:0] PC;
	wire [31:0] PC_next;
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) 
			PC <= 32'h10002000; // this is where our instruction memory starts
		else 
			PC <= PC_next;
	end

	assign PC_next = (stall && ~flush) ? PC : in_PC_next; 
	// flush and stall updating PC register truth table 
	// FLUSH	STALL 		UPDATE PC?
	//   0		  0		    1
	//   0	 	  1		    0
	//   1		  0		    1
	//   1	 	  1		    1
	// when flushing, it's cause we branched, and we need the PC to update, so 
	// PC_next should update even when stalling

	// if flushing, everything becomes NOP
	assign out_PC_next = flush ? `NOP : PC;

	// instruction memory access
	mem_system instructionMem(.clk(clk), .rst_n(rst_n), .addr(PC), .data_in(), .wr(1'b0), .en(1'b1), .data_valid(Done), .data_out(instr));

	// 552 mem
	//mem_system instructionMem(.DataOut(instr), .Done(Done), .Stall(Stall), .CacheHit(), .err(err), .Addr(addr), 
	//				.DataIn(), .Rd(1'b1), .Wr(1'b0), .createdump(halt), .clk(clk), .rst(rst));

endmodule
