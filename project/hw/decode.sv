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
// RIN, note the OP skips to last value, not the next value
`define RIN 	32'b11111xxxxxxxxxxxxxxxxxxxxxxxxxxx


module decode (
		// inputs
		clk, rst_n,
		instr, in_PC_next,
		reg_wrt_en, reg_wrt_sel, reg_wrt_data,
		flush,
		// outputs
		out_PC_next,
		reg_1_data, reg_2_data, imm,
		ALU_src, ALU_OP, Branch, Jump,
		mem_wrt, mem_en,
		result_sel, next_reg_wrt_en, next_reg_wrt_sel
		);
	input logic clk, rst_n;
	input logic [31:0] instr;
	input logic [31:0] in_PC_next;
	input logic reg_wrt_en;
	input logic [4:0] reg_wrt_sel;
	input logic [31:0] reg_wrt_data;
	// control
	input logic flush;

	output logic [31:0] out_PC_next;
	output logic [31:0] reg_1_data;
	output logic [31:0] reg_2_data;
	output logic [31:0] imm;
	// control for Execute
	output logic [1:0] ALU_src;
	output logic [4:0] ALU_OP;
	output logic Branch;
	output logic Jump;
	// control for Memory
	output logic mem_wrt;
	output logic mem_en;
	// control for Writeback
	output logic [1:0] result_sel;
	output logic next_reg_wrt_en;
	output logic next_reg_wrt_sel;

	// read/write registers
	regFile_bypass registers(.clk(clk), .rst(rst_n), .read1Data(reg_1_data), .read2Data(reg_2_data), 
				.read1RegSel(instr[21:17]), .read2RegSel(instr[16:12]), 
				.reg_wrt_sel(reg_wrt_sel), .reg_wrt_data(reg_wrt_data), .reg_wrt_en(reg_wrt_en));
	
	// todo: handle immediate (output 32 bits)
	assign imm = 32'd0;//?

	// set all other outputs
	assign out_PC_next = in_PC_next;	
	always_comb begin
		// defaults for control
		// control for Execute
		ALU_src = 2'd1;  // use immediate=0, doesn't use immediate=1
		ALU_OP = instr[31:27]; // just the op code
		Branch = 0;
		Jump = 0;
		// control for Memory
		mem_wrt = 0;
		mem_en = 0;
		// control for Writeback
		result_sel = 2'd0;
		next_reg_wrt_en = 0;
		next_reg_wrt_sel = 0;

		casex (instr)
			//ALU
			`ADD: begin
			end
			`ADDI: begin
				ALU_src = 2'd0;
			end
			`SUB: begin
			end
			`SUBI: begin
				ALU_src = 2'd0;
			end
			`AND: begin
			end
			`OR: begin
			end
			`XOR: begin
			end
			`NEG: begin
			end
			`SLL: begin
			end
			`SLR: begin
			end
			`SAR: begin
			end
			// mem stuff
			`LD: begin
			end
			`LDI: begin
				ALU_src = 2'd0;
			end
			`ST: begin
			end
			`STI: begin
				ALU_src = 2'd0;
			end
			// NOP
			`NOP: begin
				// nothing
			end
			// Control stuff
			`BEQ: begin
				Branch = 1;
			end
			`BNE: begin
				Branch = 1;
			end
			`BON: begin
				Branch = 1;
			end
			`BNN: begin
				Branch = 1;
			end
			`J: begin
				ALU_src = 2'd0;
				Jump = 1;
			end
			`JR: begin
				Jump = 1;
			end
			`JAL: begin
				ALU_src = 2'd0;
				Jump = 1;
			end
			// RIN
			`RIN: begin
				// like a NOP, does nothing
			end

			// error
			default: begin
				// make all control 1 to signal error
				// control for Execute
				ALU_src = 2'b11;  
				ALU_OP = 5'b11111; 
				Branch = 1;
				Jump = 1;
				// control for Memory
				mem_wrt = 1;
				mem_en = 1;
				// control for Writeback
				result_sel = 2'b11;
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = 1;
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
