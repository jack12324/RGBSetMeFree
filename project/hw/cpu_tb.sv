// testbench for cpu.sv
// NOTE: must change fetch.sv and memory.sv to use fake_mem_system (change comments around)
`define NOP 32'b01111xxxxxxxxxxxxxxxxxxxxxxxxxxx

module cpu_tb();
	// parameter ADDR_BITCOUNT = 64;
	// parameter WORD_SIZE = 32;
	// parameter CL_SIZE_WIDTH = 512;
	//integer itr;
	
	integer errors;
	// cpu signals
	logic clk;  // System clock 
    	logic rst_n; // Active low reset for the system
	// Interrupt Signals 
    	logic INT;
    	logic [31:0] INT_INSTR;
    	logic ACK;
	//Wires to Mem_ctrl from Fetch and Memory (inst and data memory)
	//Fetch
	logic [511:0] FeDataIn_host;
	logic Fetx_done_host;
	logic Ferd_valid_host;
	logic [511:0] FeDataOut_host;
	logic [31:0] FeAddrOut_host;
	logic [1:0] Feop_host;
	//Memory
	logic [511:0] MeDataIn_host;
	logic Metx_done_host;
	logic Merd_valid_host;
	logic [511:0] MeDataOut_host;
	logic [31:0] MeAddrOut_host;
	logic [1:0] Meop_host;
	logic startFPU;

	// Create clock signal
	always #5 clk = ~clk;
	
	cpu DUT(.*);

	initial begin
		integer errors;
		clk = 0;
		rst_n = 0; // rst is ON
		INT = 0;
		INT_INSTR = `NOP;
		// mayukh?
		FeDataIn_host = 512'b0;	
		Fetx_done_host = 0;
		Ferd_valid_host = 0;
		//Memory
		MeDataIn_host = 512'b0;	
		Metx_done_host = 0;
		Merd_valid_host = 0;

		repeat (2) @(posedge clk);
		rst_n = 1; // rst is OFF, begin
		
		// test cpu 
		// do something
		// check outputs
		// check interrupt output
		repeat (40) @(posedge clk);

		if(errors == 0)
			$display("YAHOO! All tests passed!");
		else
			$display("ARRR!!! Ye codes be blast! Get debugging!");
		// Stop simulation
		$stop;
	end

endmodule
