/*
	This is the module for the overall decode stage of the processor.
	Much control logic here!
*/

// OP CODE defines
//ALU stuff
`define ADD 	32'b00000xxxxxxxxxxxxxxxxxxxxxxxxxxx
`define ADDI 	32'b00001xxxxxxxxxxxxxxxxxxxxxxxxxxx
`define SUB 	32'b00010xxxxxxxxxxxxxxxxxxxxxxxxxxx
`define SUBI 	32'b00011xxxxxxxxxxxxxxxxxxxxxxxxxxx
`define AND 	32'b00100xxxxxxxxxxxxxxxxxxxxxxxxxxx
`define OR 	32'b00101xxxxxxxxxxxxxxxxxxxxxxxxxxx
`define XOR 	32'b00110xxxxxxxxxxxxxxxxxxxxxxxxxxx
`define NEG 	32'b00111xxxxxxxxxxxxxxxxxxxxxxxxxxx
`define SLL 	32'b01000xxxxxxxxxxxxxxxxxxxxxxxxxxx
`define SLR 	32'b01001xxxxxxxxxxxxxxxxxxxxxxxxxxx
`define SAR 	32'b01010xxxxxxxxxxxxxxxxxxxxxxxxxxx
// Mem stuff
`define LD 	32'b01011xxxxxxxxxxxxxxxxxxxxxxxxxxx
`define LDI 	32'b01100xxxxxxxxxxxxxxxxxxxxxxxxxxx
`define ST 	32'b01101xxxxxxxxxxxxxxxxxxxxxxxxxxx
`define STI 	32'b01110xxxxxxxxxxxxxxxxxxxxxxxxxxx
// NOP
`define NOP 	32'b01111xxxxxxxxxxxxxxxxxxxxxxxxxxx
// Control stuff
`define BEQ 	32'b10000xxxxxxxxxxxxxxxxxxxxxxxxxxx
`define BNE 	32'b10001xxxxxxxxxxxxxxxxxxxxxxxxxxx
`define BON 	32'b10010xxxxxxxxxxxxxxxxxxxxxxxxxxx
`define BNN 	32'b10011xxxxxxxxxxxxxxxxxxxxxxxxxxx
`define J 	32'b10100xxxxxxxxxxxxxxxxxxxxxxxxxxx
`define JR 	32'b10101xxxxxxxxxxxxxxxxxxxxxxxxxxx
`define JAL 	32'b10110xxxxxxxxxxxxxxxxxxxxxxxxxxx
// RIN, note the OP skips to last value
`define RIN 	32'b11111xxxxxxxxxxxxxxxxxxxxxxxxxxx


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

	// todo: finish this module
	// read/write registers
	regFile_bypass registers(.clk(clk), .rst(rst_n), .read1Data(reg_1_data), .read2Data(reg_2_data), 
				.read1RegSel(instr[21:17]), .read2RegSel(instr[16:12]), 
				.reg_wrt_sel(reg_wrt_sel), .reg_wrt_data(reg_wrt_data), .reg_wrt_en(reg_wrt_en));
	
	// todo: handle immediate (output 32 bits)
	signextender extender(.maxImm(instr[10:0]), .sizeSlc(sizeslc), .extSlc(extslc), .exImm(exImm));
	assign imm = ???;

	// set all other outputs
	assign out_PC_next = in_PC_next;	
	always_comb @(*) begin
		// defaults for control is all off/0
		// control for Execute
		output [1:0] ALU_src; // ALU_SRC IS JUST THE OP_CODE
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
			
		casex (instr)
			`JAL: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				dstReg = 2'd3;
				sizeslc = 2'd2;
				extslc = 1'b1;
				//DeEx_inPCSrc1 = 1'b1; old PCSrc1 version				
				DeEx_inPCSrc2Code = 3'd5;
				//DeEx_inPCSrc2 = 1'b1;
				DeEx_inMemAddrSrc = 1'b1;
				DeEx_inBranchOrJump = 1'b1;
			end
			`JALR: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				dstReg = 2'd3;
				sizeslc = 2'd1;
				extslc = 1'b1;
				DeEx_inPCSrc1 = 1'b1;				
				DeEx_inPCSrc2Code = 3'd5;
				DeEx_inALUSrc2 = 2'd1;
				DeEx_inALUCtrl = 3'd4;
				DeEx_inMemAddrSrc = 1'b1;
				DeEx_inBranchOrJump = 1'b1;
			end
			default: begin
				// keep all at 0 for clear error
				end
		endcase
	end


	/* 552 stuff for reference
	always@(*) begin
		case(dstReg)
			2'b00: writeRegAddrOut = instr[4:2];
			2'b01: writeRegAddrOut = instr[7:5];
			2'b10: writeRegAddrOut = instr[10:8];
			2'b11: writeRegAddrOut = 3'b111;
			default: writeRegAddrOut = instr[4:2];
		endcase
	end
	*/
endmodule
