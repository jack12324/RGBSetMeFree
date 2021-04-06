/*
   CS/ECE 552 Spring '20
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
module decode (instr, regWriteData, writeRegAddrIn, writeRegAddrOut, nextInstrIn, nextInstrOut, reg1Data, reg2Data, exImm, dstReg, sizeslc, extslc, err, clk, rst, writeEn);

	input [15:0]instr;
	input [15:0]regWriteData;
	input [15:0]nextInstrIn;
	input [1:0] dstReg;
	input [1:0] sizeslc;
	input writeEn;
	input extslc;
	input clk;
	input rst;
	

	output [15:0]nextInstrOut;
	output err;
	output [15:0]reg1Data;
	output [15:0]reg2Data;
	output [15:0]exImm;
	input [2:0] writeRegAddrIn;
	output reg [2:0] writeRegAddrOut;

	
	regFile_bypass registers(.read1Data(reg1Data), .read2Data(reg2Data), .err(err), .clk(clk), .rst(rst), 
.read1RegSel(instr[10:8]), .read2RegSel(instr[7:5]), .writeRegSel(writeRegAddrIn), .writeData(regWriteData), .writeEn(writeEn));
	signextender extender(.maxImm(instr[10:0]), .sizeSlc(sizeslc), .extSlc(extslc), .exImm(exImm));
	
	always@(*) begin
		case(dstReg)
			2'b00: writeRegAddrOut = instr[4:2];
			2'b01: writeRegAddrOut = instr[7:5];
			2'b10: writeRegAddrOut = instr[10:8];
			2'b11: writeRegAddrOut = 3'b111;
			default: writeRegAddrOut = instr[4:2];
		endcase
	end

  	assign nextInstrOut = nextInstrIn; 

endmodule
