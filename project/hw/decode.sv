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
`define ST	32'b01101xxxxxxxxxxxxxxxxxxxxxxxxxxx
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
		in_LR_wrt_data,
		in_FL_wrt_data,
		flush,
		in_LR_write,
		in_FL_write,
		// outputs
		out_PC_next,
		reg_1_data, reg_2_data, imm,
		LR, FL,
		LR_read, LR_write, FL_read, FL_write,
		ALU_src, ALU_OP, Branch, Jump,
		mem_wrt, mem_en,
		result_sel, next_reg_wrt_en, next_reg_wrt_sel,
		DeEx_in_reg_1_sel,
		DeEx_in_reg_2_sel,
		// interrupts 
		restore, LR_before_int, FL_before_int
		);
	input logic clk, rst_n;
	input logic [31:0] instr;
	input logic [31:0] in_PC_next;
	input logic reg_wrt_en;
	input logic [4:0] reg_wrt_sel;
	input logic [31:0] reg_wrt_data;
	// special register stuff
	input logic [31:0] in_LR_wrt_data;
	input logic [1:0]  in_FL_wrt_data;
	// control
	input logic flush;
	// control for special register stuff
	input logic in_LR_write;
	input logic in_FL_write;

	// interrupt signals
	input logic restore;
	input logic [31:0] LR_before_int;
	input logic [1:0] FL_before_int;

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
	output logic [4:0] next_reg_wrt_sel;
	// control for forwarding
	output logic [4:0] DeEx_in_reg_1_sel;
	output logic [4:0] DeEx_in_reg_2_sel;

	//assign 


	// read/write registers
	regFile_bypass registers(.clk(clk), .rst_n(rst_n), .read1Data(reg_1_data), .read2Data(reg_2_data), 
				.read1RegSel(instr[21:17]), .read2RegSel(instr[16:12]), 
				.reg_wrt_sel(reg_wrt_sel), .reg_wrt_data(reg_wrt_data), .reg_wrt_en(legal_en));
	// R0, LR, and FL (register 0, 30, 31) cannot be written to (NOP trying to)
	assign legal_en = (reg_wrt_sel==0 || reg_wrt_sel==30 || reg_wrt_sel==31) ? 0 : reg_wrt_en;
	// ESP (register 29) is stack pointer for interrupts, acts like normal register
	
	//  update LR (register 30) and FL (register 31)
	logic [31:0] LR_next;
	logic [1:0]  FL_next;
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin 
			LR <= 32'd0;
			FL <= 2'd0;
		end
		else begin 
			LR <= LR_next;
			FL <= FL_next;
		end
	end
	assign LR_next = (restore == 1'b1) ? (LR_before_int) : ( in_LR_write ? in_LR_wrt_data : LR );
	assign FL_next = (restore == 1'b1) ? (FL_before_int) : ( in_FL_write ? in_FL_wrt_data : FL );
	

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
		next_reg_wrt_sel = 0;
		// control for special registers
		LR_read = 0; 
		LR_write = 0;
		FL_read = 0; 
		FL_write = 1; // most do
		// control for forwarding
		DeEx_in_reg_1_sel = instr[21:17];
		DeEx_in_reg_2_sel = instr[16:12];

		casex (instr)
			//ALU
			`ADD: begin
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22]; 
				LR_read = instr[21:17]==30 || instr[16:12]==30;
				FL_read = instr[21:17]==31 || instr[16:12]==31;
			end
			`ADDI: begin
				ALU_src = 2'd0;
				imm[31:0] = {{20{instr[11]}}, instr[10:0]}; // sign extend 12 bit immediate to 32 bits
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
				LR_read = instr[21:17]==30;
				FL_read = instr[21:17]==31;
			end
			`SUB: begin
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
				LR_read = instr[21:17]==30 || instr[16:12]==30;
				FL_read = instr[21:17]==31 || instr[16:12]==31;
			end
			`SUBI: begin
				ALU_src = 2'd0;
				imm[31:0] = {{20{instr[11]}}, instr[10:0]}; // sign extend 12 bit immediate to 32 bits
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
				LR_read = instr[21:17]==30;
				FL_read = instr[21:17]==31;
			end
			`AND: begin
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
				LR_read = instr[21:17]==30 || instr[16:12]==30;
				FL_read = instr[21:17]==31 || instr[16:12]==31;
			end
			`OR: begin
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
				LR_read = instr[21:17]==30 || instr[16:12]==30;
				FL_read = instr[21:17]==31 || instr[16:12]==31;
			end
			`XOR: begin
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
				LR_read = instr[21:17]==30 || instr[16:12]==30;
				FL_read = instr[21:17]==31 || instr[16:12]==31;
			end
			`NEG: begin
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
				LR_read = instr[21:17]==30;
				FL_read = instr[21:17]==31;
			end
			`SLL: begin
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
				LR_read = instr[21:17]==30 || instr[16:12]==309;
				FL_read = instr[21:17]==31 || instr[16:12]==31;
			end
			`SLR: begin
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
				LR_read = instr[21:17]==30 || instr[16:12]==30;
				FL_read = instr[21:17]==31 || instr[16:12]==31;
			end
			`SAR: begin
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
				LR_read = instr[21:17]==30 || instr[16:12]==30;
				FL_read = instr[21:17]==31 || instr[16:12]==31;
			end
			// mem stuff
			`LD: begin
				mem_en = 1;
				result_sel = 2'b01;
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
				LR_read = instr[21:17]==30;
				FL_read = instr[21:17]==31;
			end
			`LDI: begin
				ALU_src = 2'd0;
				imm[31:0] = {{16{0}}, instr[15:0]}; // 16 bit immediate to 32 bits, ignore top 16 bits anyway
				mem_en = 1;
				result_sel = 2'b01;
				next_reg_wrt_en = 1;
				next_reg_wrt_sel = instr[26:22];
			end
			`ST: begin
				mem_en = 1;
				mem_wrt = 1;
				LR_read = instr[21:17]==30;
				FL_read = instr[21:17]==31;
				FL_write = 0;
			end
			`STI: begin
				ALU_src = 2'd0;
				imm[31:0] = {{16{0}}, instr[15:0]}; // 16 bit immediate to 32 bits, ignore top 16 bits anyway
				mem_en = 1;
				mem_wrt = 1;
				LR_read = instr[21:17]==30;
				FL_read = instr[21:17]==31;
				FL_write = 0;
			end
			// NOP
			`NOP: begin
				// nothing
				FL_write = 0;
			end
			// Control stuff
			`BEQ: begin
				Branch = 1;
				result_sel = 2'b10;
				LR_read = instr[21:17]==30;
				FL_read = 1;
				FL_write = 0;
			end
			`BNE: begin
				Branch = 1;
				result_sel = 2'b10;
				LR_read = instr[21:17]==30;
				FL_read = 1;
				FL_write = 0;
			end
			`BON: begin
				Branch = 1;
				result_sel = 2'b10;
				LR_read = instr[21:17]==30;
				FL_read = 1;
				FL_write = 0;
			end
			`BNN: begin
				Branch = 1;
				result_sel = 2'b10;
				LR_read = instr[21:17]==30;
				FL_read = 1;
				FL_write = 0;
			end
			`J: begin
				ALU_src = 2'd0;
				Jump = 1;
				imm = {16'h0600, instr[13:0], 2'b0}; // prefix where inst. mem. starts, postfix is byte addressable
				result_sel = 2'b10;
				FL_write = 0;
			end
			`JR: begin
				Jump = 1;
				result_sel = 2'b10;
				LR_read = instr[21:17]==30;
				FL_read = instr[21:17]==31;
				FL_write = 0;
			end
			`JAL: begin
				ALU_src = 2'd0;
				Jump = 1;
				imm = {16'h0600, instr[13:0], 2'b0}; // prefix where inst. mem. starts, postfix is byte addressable
				result_sel = 2'b10;
				LR_write = 1; 
				FL_write = 0;
			end
			// RIN
			`RIN: begin
				// like a NOP, does nothing
				FL_write = 0;
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
				next_reg_wrt_sel = 5'b11111;
				// control for special registers
				LR_read = 1; 
				LR_write = 1;
				FL_read = 1; 
				FL_write = 1; 
				// control for forwarding
				DeEx_in_reg_1_sel = 5'b11111;
				DeEx_in_reg_2_sel = 5'b11111;

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
