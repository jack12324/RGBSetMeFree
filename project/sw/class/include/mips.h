//////////////////////////////////////////////////////////////////////////////
//
//    CLASS - Cloud Loader and ASsembler System
//    Copyright (C) 2021 Winor Chen
//
//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 2 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License along
//    with this program; if not, write to the Free Software Foundation, Inc.,
//    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//////////////////////////////////////////////////////////////////////////////
#ifndef __MIPS_H__
#define __MIPS_H__


/* A header for mips specifc details
 * such as register name mappings
 * and a jump list for functional routines
 *
 * Instruction Formats:
 * R - 5 opcode, 5 rd, 5 rs, 5 rt, 12 Imm. includes imm instructions, NEGate, mem instructions without imm, branch instructions, JR, and NOP and RIN
 * M - 5 opcode, 5 rd, 5 rs, 1 blank, 16  Imm. includes mem imm instructions
 * J - 5 opcode, 13 blank, 14 Imm. includes JMP and JAL but not JR
 *
 * wchen329 and Christian Henke
 */
#include <cstring>
#include <cstddef>
#include <memory>
#include "ISA.h"
#include "mt_exception.h"
#include "primitives.h"
#include "priscas_global.h"
#include "syms_table.h"
#include "ustrop.h"

namespace priscas
{

	// Friendly Register Names -> Numerical Assignments
	enum REGISTERS
	{
		$R0 = 0,
		$r1 = 1,
		$r2 = 2,
		$r3 = 3,
		$r4 = 4,
		$r5 = 5,
		$r6 = 6,
		$r7 = 7,
		$r8 = 8,
		$r9 = 9,
		$r10 = 10,
		$r11 = 11,
		$r12 = 12,
		$r13 = 13,
		$r14 = 14,
		$r15 = 15,
		$r16 = 16,
		$r17 = 17,
		$r18 = 18,
		$r19 = 19,
		$r20 = 20,
		$r21 = 21,
		$r22 = 22,
		$r23 = 23,
		$r24 = 24,
		$r25 = 25,
		$r26 = 26,
		$r27 = 27,
		$r28 = 28,
		$ESP = 29,
		$LR = 30,
		$FL = 31,
		INVALID = -1
	};

	// instruction formats
	enum format
	{
		R, M, J	
	};

	// MIPS Processor Opcodes
	enum opcode
	{
	    // ALU
		ADD = 0,
		ADDI = 1,
		SUB = 2,
		SUBI = 3,
		AND = 4,
		OR = 5,
		XOR = 6,
		NEG = 7,
		SLL =  8,
		SLR = 9,
		SAR = 10,
		// Mem
		LD = 11,
		LDI = 12,
		ST = 13,
		STI = 14,
		// NOP
		NOP = 15,
		// Control
		BEQ = 16,
		BNE = 17,
		BON = 18,
		BNN = 19,
		JMP = 20,
		JR = 21,
		JAL = 22,
		// RIN
		RIN = 31,
		SYS_RES = -1	// system reserved for shell interpreter
	};

	int friendly_to_numerical(const char *);

	// From a register specifier, i.e. %so get an integer representation
	int get_reg_num(const char *);

	// From a immediate string, get an immediate value.
	int get_imm(const char *);

	// Format check functions
	/* Checks if an instruction is M formatted.
	 */
	bool m_inst(opcode operation);

	/* Checks if an instruction is R formatted.
	 */
	bool r_inst(opcode operation);

	/* Checks if an instruction is J formatted.
	 */
	bool j_inst(opcode operation);

	/* Checks if an instruction performs
	 * memory access
	 */
	bool mem_inst(opcode operation);

	/* Checks if an instruction performs
	 * memory write
	 */
	bool mem_write_inst(opcode operation);

	/* Checks if an instruction performs
	 * memory read
	 */
	bool mem_read_inst(opcode operation);

	/* Checks if an instruction performs
	 * a register write
	 */
	bool reg_write_inst(opcode operation);

	/* Check if a Jump or
	 * Branch Instruction
	 */
	bool jorb_inst(opcode operation);

	/* "Generic" MIPS-32 architecture
	 * encoding function asm -> binary
	 */
	BW_32 generic_mips32_encode(int rs, int rt, int rd, int imm_shamt_jaddr, opcode op);

	/* For calculating a label offset in branches
	 */
	BW_32 offset_to_address_br(BW_32 current, BW_32 target);

	/* MIPS_32 ISA
	 *
	 */
	class MIPS_32 : public ISA
	{
		
		public:
			virtual std::string get_reg_name(int id);
			virtual int get_reg_id(std::string& fr) { return friendly_to_numerical(fr.c_str()); }
			virtual ISA_Attrib::endian get_endian() { return ISA_Attrib::CPU_BIG_ENDIAN; }
			virtual mBW assemble(const Arg_Vec& args, const BW& baseAddress, syms_table& jump_syms) const;
		private:
			static const unsigned REG_COUNT = 32;
			static const unsigned PC_BIT_WIDTH = 32;
			static const unsigned UNIVERSAL_REG_BW = 32;
	};
}

#endif
