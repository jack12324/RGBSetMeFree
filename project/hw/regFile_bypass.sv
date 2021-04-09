/*
   This module creates a wrapper around the 32x32b register file, to do
   do the bypassing logic for RF bypassing.
*/
module regFile_bypass (
                       // Outputs
                       read1Data, read2Data, 
                       // Inputs
                       clk, rst_n, read1RegSel, read2RegSel, reg_wrt_sel, reg_wrt_data, reg_wrt_en
                       );
   	input logic clk, rst_n;
   	input logic [4:0]  read1RegSel;
   	input logic [4:0]  read2RegSel;
   	input logic [4:0]  reg_wrt_sel;
   	input logic [31:0] reg_wrt_data;
   	input logic        reg_wrt_en;

   	output logic [31:0] read1Data;
   	output logic [31:0] read2Data;

	wire [31:0] noBypassRead1, noBypassRead2;
	regFile registersNoBypass(.read1Data(noBypassRead1), .read2Data(noBypassRead2), .err(err), 
					.clk(clk), .rst(rst), .read1RegSel(read1RegSel), .read2RegSel(read2RegSel), 
					.writeRegSel(writeRegSel), .writeData(writeData), .writeEn(writeEn));
	
	assign read1Data = (writeEn & (read1RegSel==writeRegSel)) ? writeData : noBypassRead1;
	assign read2Data = (writeEn & (read2RegSel==writeRegSel)) ? writeData : noBypassRead2;

endmodule
