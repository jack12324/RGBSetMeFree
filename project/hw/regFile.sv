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

	input clk, rst_n;
   	input [2:0]  read1RegSel;
   	input [2:0]  read2RegSel;
   	input [2:0]  reg_wrt_sel;
   	input [N-1:0] reg_wrt_data;
   	input reg_wrt_en;

   	output reg [N-1:0] read1Data;
   	output reg [N-1:0] read2Data;

	// 32 N-bit registers
	reg [N-1:0] register[31:0];
 	wire [N-1:0] register_next[31:0];
	// N registers of N bits
	always_ff @(posedge clk) begin
		if (!rst_n)
			register = '0;
		else
			registeer = register_next;
	end 

	//genvar x;
	//generate for (x = 0; x < 16; x+=1)	
	//endgenerate
	
	
	// mux to select read1 output
	always @* begin
		case (read1RegSel)
			3'd0: read1Data = regOutputs[0];
			3'd1: read1Data = regOutputs[1];
			3'd2: read1Data = regOutputs[2];
			3'd3: read1Data = regOutputs[3];
			3'd4: read1Data = regOutputs[4];
			3'd5: read1Data = regOutputs[5];
			3'd6: read1Data = regOutputs[6];
			3'd7: read1Data = regOutputs[7];
		endcase
	end

	// mux to select read2 output
	always @* begin
		err = 0;
		case (read2RegSel)
			3'd0: read2Data = regOutputs[0];
			3'd1: read2Data = regOutputs[1];
			3'd2: read2Data = regOutputs[2];
			3'd3: read2Data = regOutputs[3];
			3'd4: read2Data = regOutputs[4];
			3'd5: read2Data = regOutputs[5];
			3'd6: read2Data = regOutputs[6];
			3'd7: read2Data = regOutputs[7];
			default: err = 1;
		endcase
	end


	// a decoder hooked up to 8 AND gates with writeEn as the other signal
	always @* begin
		writeEnSel = 8'd0;
		err = 0;
		case (writeRegSel)
			3'd0: writeEnSel[0] = writeEn;
			3'd1: writeEnSel[1] = writeEn;
			3'd2: writeEnSel[2] = writeEn;
			3'd3: writeEnSel[3] = writeEn;
			3'd4: writeEnSel[4] = writeEn;
			3'd5: writeEnSel[5] = writeEn;
			3'd6: writeEnSel[6] = writeEn;
			3'd7: writeEnSel[7] = writeEn;
			default: err = 1;
		endcase
	end

	
endmodule
