/*
   CS/ECE 552 Spring '20
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
module decode (instr, regWriteData, writeRegAddrIn, writeRegAddrOut, nextInstrIn, nextInstrOut, reg1Data, reg2Data, exImm, dstReg, sizeslc, extslc, err, clk, rst, writeEn);
	input clk, rst_n;
	input [31:0] instr;
	input [31:0] in_PC_next;
	input reg_wrt_en;
	input [4:0] reg_wrt_sel;
	input [31:0] reg_wrt_data;
	// control
	input flush;

	output [31:0] out_PC_next;
	output [31:0] reg_1_data;
	output [31:0] reg_2_data;
	output [31:0] imm;
	// control for Execute
	output [1:0] ALU_src;
	output [4:0] ALU_OP;
	output Branch;
	output Jump;
	// control for Memory
	output mem_wrt;
	output mem_en;
	// control for Writeback
	output [1:0] result_sel;
	output next_reg_wrt_en;
	output next_reg_wrt_sel;

// unused 552 stuff
/*
        input [15:0]nextInstrIn;
        input [1:0] sizeslc;
        input extslc;

	output [15:0]nextInstrOut;
	output err;
*/
	
	// todo: write this module
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
