
/*
	ECE 554
	Project: RGB Set Me Free!
	Team: Who's Waldo
	Filename        : fetch.sv
	Description     : This is the module for the overall fetch stage of the processor.
*/
//todo fix definition
`define NOP 16'b00001xxxxxxxxxxx

module fetch (clk, rst_n, in_PC_next, stall, flush, INT, INT_INST, out_PC_next, instr, Done, ACK);
	input clk, rst_n;
	input [31:0] in_PC_next;
	input stall, flush;
	// for interrupts
	input INT;
	input [31:0] INT_INST;

	output [31:0] out_PC_next;
	output [31:0] instr;
	output Done;
	// for interrupts
	output ACK;

	// todo: interrupts and flush, and Done out of mem_system

	reg [31:0] PC;
	wire [31:0] PC_next;
	always_ff @(posedge clk) begin
		if (!rst_n) 
			PC <= 32'h2000; //this is where our instruction memory starts
		else 
			PC <= PC_next;
	end

	assign PC_next = stall ? PC : in_PC_next; 
	// todo flush in logic? 
	// when flushing its cause we branched, and want the PC to update, so 
	// PC_next should update even when flush is true
	// perhaps need (stall && ~flush), not sure

	assign out_PC_next = flush ? `NOP : PC;

	// final mem
	memsystem instructionMem(.clk(clk), .rst_n(rst_n), .addr(PC), .data_in(), .wr(1'b0), .en(1'b1), .data_valid(Done), .data_out(instr));

	// 552 mem
	//mem_system instructionMem(.DataOut(instr), .Done(Done), .Stall(Stall), .CacheHit(), .err(err), .Addr(addr), 
	//				.DataIn(), .Rd(1'b1), .Wr(1'b0), .createdump(halt), .clk(clk), .rst(rst));

endmodule
