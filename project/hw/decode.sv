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
	// special register stuff
	output logic [31:0] LR;
	output logic [1:0] FL;
	// control for special registers
	output logic LR_read;
	output logic LR_write;
	output logic FL_read;
	output logic FL_write;

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
	// todo: update LR (register 30) and FL (register 31), always_ff block and _next and stuff
	// todo: R0 (register 0) should not be written to
	// register 29 is ESP (stack pointer for interrupts)

	// set all other outputs
	assign out_PC_next = in_PC_next;	
	always_comb begin
		// defaults
		imm = 32'd0;
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
		next_reg_wrt_sel = 0; // todo
		// control for special registers
		LR_read = 0; // todo, within certain instructions: (read1RegSel==29 || read2RegSel || other LR reads???);// todo
		LR_write = 0; // todo
		FL_read = 0; // todo, within certain instructions: (read1RegSel==29 || read2RegSel || other LR reads???);// todo
		FL_write = 0; // todo

		casex (instr)
			//ALU
			`ADD: begin
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22]; 
			end
			`ADDI: begin
				ALU_src = 2'd0;
				imm = {{20{instr[11]}, instr[10:0]}; // sign extend 12 bit immediate to 32 bits
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
			end
			`SUB: begin
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
			end
			`SUBI: begin
				ALU_src = 2'd0;
				imm = {{20{instr[11]}, instr[10:0]}; // sign extend 12 bit immediate to 32 bits
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
			end
			`AND: begin
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
			end
			`OR: begin
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
			end
			`XOR: begin
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
			end
			`NEG: begin
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
			end
			`SLL: begin
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
			end
			`SLR: begin
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
			end
			`SAR: begin
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
			end
			// mem stuff
			`LD: begin
				mem_en = 1;
				result_sel = 2'b01;
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
			end
			`LDI: begin
				ALU_src = 2'd0;
				imm = {{16{0}, instr[15:0]}; // 16 bit immediate to 32 bits, ignore top 16 bits anyway
				mem_en = 1;
				result_sel = 2'b01;
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
			end
			`ST: begin
				mem_en = 1;
				mem_wrt = 1;
			end
			`STI: begin
				ALU_src = 2'd0;
				imm = {{16{0}, instr[15:0]}; // 16 bit immediate to 32 bits, ignore top 16 bits anyway
				mem_en = 1;
				mem_wrt = 1;
			end
			// NOP
			`NOP: begin
				// nothing
			end
			// Control stuff
			`BEQ: begin
				Branch = 1;
				result_sel = 2'b10;
			end
			`BNE: begin
				Branch = 1;
				result_sel = 2'b10;
			end
			`BON: begin
				Branch = 1;
				result_sel = 2'b10;
			end
			`BNN: begin
				Branch = 1;
				result_sel = 2'b10;
			end
			`J: begin
				ALU_src = 2'd0;
				Jump = 1;
				imm = {16'h1000, instr[13:0], 2'b0}; // prefix where inst. mem. starts, postfix is byte addressable
				result_sel = 2'b10;
			end
			`JR: begin
				Jump = 1;
				result_sel = 2'b10;
			end
			`JAL: begin
				ALU_src = 2'd0;
				Jump = 1;
				imm = {16'h1000, instr[13:0], 2'b0}; // prefix where inst. mem. starts, postfix is byte addressable
				result_sel = 2'b10;
			end
			// RIN
			`RIN: begin
				// like a NOP, does nothing
			end

			// error
			default: begin
				// make all 1s to signal error
				imm = 32'hFFFFFFFF;
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
				// control for special registers
				LR_read = 1; 
				LR_write = 1;
				FL_read = 1; 
				FL_write = 1; 
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
