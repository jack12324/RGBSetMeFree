// testbench for fetch.sv
`define NOP 32'b01111xxxxxxxxxxxxxxxxxxxxxxxxxxx

module fetch_tb();
	// parameter ADDR_BITCOUNT = 64;
	// parameter WORD_SIZE = 32;
	// parameter CL_SIZE_WIDTH = 512;
	//integer itr;
	
	integer errors;
	logic clk, rst_n;
	logic [31:0] in_PC_next;
	logic stall, flush;
	logic [31:0] out_PC_next;
	logic [31:0] instr;
	logic Done;
	// for interrupts
	logic INT;
	logic [31:0] INT_INST;
	logic ACK;


	// Create clock signal
	always #5 assign clk = ~clk;
	
	fetch DUT(.*);

	initial begin
		errors = '0;
		clk = 0;
		rst_n = 0; // active low reset is on
		in_PC_next = 0;
		stall = 0;
		flush = 0;
		INT = 0;
		INT_INST = `NOP;

		repeat (2) @(posedge clk);
		rst_n = 1; // reset is off, begin
		
		// test fetch 
		// check outputs
		out_PC_next;
		instr;
		Done;
		// check output interrupts
		ACK;
		repeat (40) @(posedge clk);

		if(errors == 0)
			$display("YAHOO! All tests passed!");
		else
			$display("ARRR!!! Ye codes be blast! Get debugging!");
		// Stop simulation
		$stop;
	end

endmodule
