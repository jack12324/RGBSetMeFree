// testbench for decode.sv
`define NOP 32'b01111xxxxxxxxxxxxxxxxxxxxxxxxxxx

module decode_tb();
	// parameter ADDR_BITCOUNT = 64;
	// parameter WORD_SIZE = 32;
	// parameter CL_SIZE_WIDTH = 512;
	//integer itr;
	

	integer errors;
	// Inputs
	logic clk, rst_n;
	logic [31:0] instr;
	logic [31:0] in_PC_next;
	logic reg_wrt_en;
	logic [4:0] reg_wrt_sel;
	logic [31:0] reg_wrt_data;
	// control
	logic flush;

	// Outputs
	logic [31:0] out_PC_next;
	logic [31:0] reg_1_data;
	logic [31:0] reg_2_data;
	logic [31:0] imm;
	// control for Execute
	logic [1:0] ALU_src;
	logic [4:0] ALU_OP;
	logic Branch;
	logic Jump;
	// control for Memory
	logic mem_wrt;
	logic mem_en;
	// control for Writeback
	logic [1:0] result_sel;
	logic next_reg_wrt_en;
	logic next_reg_wrt_sel;

	// Create clock signal
	always #5 assign clk = ~clk;
	
	decode DUT(.*);



	initial begin
		errors = '0;
		clk = 0;
		rst_n = 0; // active low reset is on
		instr = 32'd0; // todo
		in_PC_next = 32'h2000;
		reg_wrt_en = 0;
		reg_wrt_sel = 5'd0;
		reg_wrt_data = 32'hdeadbeef; // ahaha
		flush = 0;

		repeat (2) @(posedge clk);
		rst_n = 1; // reset is off, begin


		// todo: test decode somehow
		repeat (40) @(posedge clk);

		if(errors == 0)
			$display("YAHOO! All tests passed!");
		else
			$display("ARRR!!! Ye codes be blast! Get debugging!");
		// Stop simulation
		$stop;
	end

endmodule
