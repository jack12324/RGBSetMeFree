
/*
	ECE 554
	Project: RGB Set Me Free!
	Team: Who's Waldo
	Filename        : fetch.sv
	Description     : This is the module for the overall fetch stage of the processor.
*/


`define NOP 32'b01111xxxxxxxxxxxxxxxxxxxxxxxxxxx

module fetch (clk, rst_n, 
	in_PC_next, stall, flush, 
	INT_INSTR, 
	out_PC_next, 
	instr, 
	Done, 
	restore, 
	use_cpu_injection, 
	use_INT_INSTR, 
	cpu_injection, 
	current_PC, 
	PC_before_int, 

	ExMe_out_Branch, 
	ExMe_out_Jump, 
    ExMe_out_ALU_OP,
	ExMe_out_LR, 
	ExMe_out_FL,


	// Wires to mem_ctrl
	DataIn_host,
	tx_done_host,
	rd_valid_host,
	DataOut_host,
	AddrOut_host,
	op_host
);
	input clk, rst_n;
	input [31:0] in_PC_next;
	input stall, flush;
	// for interrupts
	//input INT;
	input [31:0] PC_before_int;
	input [31:0] INT_INSTR;
	input restore;
	input use_cpu_injection; // signal to use the injected instructions from this FSM 
    input [31:0] cpu_injection; // Injection from this state machine 
	input use_INT_INSTR; // signal to use the injected instructions from the interrupt controller

	// inputs for the pc fix
	input logic ExMe_out_Branch; // for flush
	input logic ExMe_out_Jump; // for flush
    input logic [4:0] ExMe_out_ALU_OP; // for flush
	input logic [31:0] ExMe_out_LR;
    input logic [1:0] ExMe_out_FL;

	output [31:0] out_PC_next;
	output [31:0] instr;
	output Done;
	// for interrupts
	//output ACK;
	output [31:0] current_PC;


	//Wires to Mem_ctrl
	input logic [511:0] DataIn_host;
	input logic tx_done_host;
	input logic rd_valid_host;

	output logic [511:0] DataOut_host;
	output logic [31:0] AddrOut_host;
	output logic [1:0] op_host;

	logic [31:0] pc_fix;
	logic [31:0] pc_4;

	logic [31:0] instr_mem; // instruction read from memory 
							// usually used unless interrupt controller 
							// or the cpu interrupt fsm are injecting instructions 

	reg [31:0] PC;
	wire [31:0] PC_next;
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) 
			PC <= 32'h00000000; // for testing
			//PC <= 32'h06002000; // this is where our instruction memory starts
		else 
			PC <= PC_next;
	end

	assign PC_next = restore ? PC_before_int : ( ( (stall & ~flush) | use_cpu_injection | use_INT_INSTR) ? PC : pc_fix); 

	// Fix for PC not updating fast enough


	assign pc_4 = PC + 3'h4;

	// Inputs necessary
	// ExMe_out_Branch
	// ExMe_out_Jump
	// ExMe_out_ALU_OP
	// ExMe_out_LR 
	// ExMe_out_FL
	// N = ExMe_out_FL[1]
    	// Z = ExMe_out_FL[0]
	assign pc_fix = (ExMe_out_Branch && ~ExMe_out_Jump) ? ((ExMe_out_ALU_OP[1:0] == 2'd0 && ExMe_out_FL[0] == 1) ? (in_PC_next)
						:  (ExMe_out_ALU_OP[1:0] == 2'd1 && ExMe_out_FL[0] == 0) ? (in_PC_next)
							: (ExMe_out_ALU_OP[1:0] == 2'd2 && ExMe_out_FL[1] == 1) ? (in_PC_next)
								: (ExMe_out_ALU_OP[1:0] == 2'd3 && ExMe_out_FL[1] == 0) ? (in_PC_next) : pc_4)
			: (ExMe_out_Jump ? ((ExMe_out_ALU_OP[1:0] == 2'd0 || ExMe_out_ALU_OP[1:0] == 2'd2) ? (in_PC_next)
						: ((ExMe_out_ALU_OP[1:0] == 2'd1) ? (in_PC_next)
							: pc_4))  : pc_4);

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
	/*
	mem_system instructionMem(
		.clk(clk), 
		.rst_n(rst_n), 
		.addr(PC), 
		.data_in(), 
		.wr(1'b0), 
		.en(1'b1),
		.done(Done), 
		.data_out(instr_mem),
		//Wires to mem_ctrl
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
	*/
  	fake_mem_system #(.FILENAME("project/test_images/interrupts.h")) dataMem(
    	.clk(clk), .rst_n(rst_n), 
    	.addr(PC),
    	.data_in(),
    	.wr(1'b0),
    	.en(1'b1),
	.stall(),
    	.done(Done),
    	.data_out(instr_mem)
    	);

	// Assign the instruction to be executed 
	assign instr = (use_cpu_injection == 1'b1) ? (cpu_injection) : ( (use_INT_INSTR == 1'b1) ? (INT_INSTR) : (instr_mem) ); 

	// Assign the signals used in the interrupt fsm 
	assign current_PC = PC;


	// 552 mem
	//mem_system instructionMem(.DataOut(instr), .Done(Done), .Stall(Stall), .CacheHit(), .err(err), .Addr(addr), 
	//				.DataIn(), .Rd(1'b1), .Wr(1'b0), .createdump(halt), .clk(clk), .rst(rst));

endmodule
