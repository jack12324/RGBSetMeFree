/*
   This module creates 32 32-bit registers.  It has 1 write port, 2 read
   ports, 3 register select inputs, a write enable, a reset, and a clock
   input.  All register state changes occur on the rising edge of the
   clock. 
*/
module regFile (
                // Outputs
                read1Data, read2Data,
                // Inputs
                clk, rst_n, read1RegSel, read2RegSel, reg_wrt_sel, reg_wrt_data, reg_wrt_en
                );

	// register width
	parameter N = 32;

	input logic clk, rst_n;
   	input logic [4:0]  read1RegSel;
   	input logic [4:0]  read2RegSel;
   	input logic [4:0]  reg_wrt_sel;
   	input logic [N-1:0] reg_wrt_data;
   	input logic reg_wrt_en;

   	output logic [N-1:0] read1Data;
   	output logic [N-1:0] read2Data;

	// 32 N-bit registers
	logic [N-1:0] register[31:0];
 	logic [N-1:0] register_next[31:0];
	int i;
	// N registers of N bits
	always_ff @(posedge clk) begin
		if (!rst_n)
			for (i = 0; i < 32; i+=1)
				register[i] = 0;
		else
			for (i = 0; i < 32; i+=1)
				register[i] = register_next[i];
	end 

	genvar x;
	generate for (x = 0; x < 32; x+=1)	
		assign register_next[x] = (x==reg_wrt_sel && reg_wrt_en) ? reg_wrt_data : register[x];
	endgenerate
	
	assign read1Data = register[read1RegSel];
	assign read2Data = register[read2RegSel];

endmodule
