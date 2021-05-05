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
#include "mips.h"

namespace priscas
{
	int friendly_to_numerical(const char * fr_name)
	{
		int len = strlen(fr_name);
		if(len < 2) return INVALID;

		REGISTERS reg_val
			=
			// Can optimize based off of 
			fr_name[1] == 'r' ?
				!strcmp("$r1", fr_name) ? $r1 :
				!strcmp("$r2", fr_name) ? $r2 :
				!strcmp("$r3", fr_name) ? $r3 :
				!strcmp("$r4", fr_name) ? $r4 :
				!strcmp("$r5", fr_name) ? $r5 :
				!strcmp("$r6", fr_name) ? $r6 :
				!strcmp("$r7", fr_name) ? $r7 :
				!strcmp("$r8", fr_name) ? $r8 :
				!strcmp("$r9", fr_name) ? $r9 :
				!strcmp("$r10", fr_name) ? $r10 :
				!strcmp("$r11", fr_name) ? $r11 :
				!strcmp("$r12", fr_name) ? $r12 :
				!strcmp("$r13", fr_name) ? $r13 :
				!strcmp("$r14", fr_name) ? $r14 :
				!strcmp("$r15", fr_name) ? $r15 :
				!strcmp("$r16", fr_name) ? $r16 :
				!strcmp("$r17", fr_name) ? $r17 :
				!strcmp("$r18", fr_name) ? $r18 :
				!strcmp("$r19", fr_name) ? $r19 :
				!strcmp("$r20", fr_name) ? $r20 :
				!strcmp("$r21", fr_name) ? $r21 :
				!strcmp("$r22", fr_name) ? $r22 :
				!strcmp("$r23", fr_name) ? $r23 :
				!strcmp("$r24", fr_name) ? $r24 :
				!strcmp("$r25", fr_name) ? $r25 :
				!strcmp("$r26", fr_name) ? $r26 :
				!strcmp("$r27", fr_name) ? $r27 :
				!strcmp("$r28", fr_name) ? $r28 : INVALID
			:

			fr_name[1] == 'R' ?
				!strcmp("$R0", fr_name) ? $R0 : INVALID
			:

			fr_name[1] == 'E' ?
				!strcmp("$ESP", fr_name) ? $ESP : INVALID
			:

			fr_name[1] == 'L' ?
				!strcmp("$LR", fr_name) ? $LR : INVALID
			:

			fr_name[1] == 'F' ?
				!strcmp("$FL", fr_name) ? $FL : INVALID

			: INVALID;

		return reg_val;
	}

	std::string MIPS_32::get_reg_name(int id)
	{
		std::string name =
		    id == 0 ? "$R0" :
			id == 1 ? "$r1" :
			id == 2 ? "$r2" :
			id == 3 ? "$r3" :
			id == 4 ? "$r4" :
			id == 5 ? "$r5" :
			id == 6 ? "$r6" :
			id == 7 ? "$r7" :
			id == 8 ? "$r8" :
			id == 9 ? "$r9" :
			id == 10 ? "$r10" :
			id == 11 ? "$r11" :
			id == 12 ? "$r12" :
			id == 13 ? "$r13" :
			id == 14 ? "$r14" :
			id == 15 ? "$r15" :
			id == 16 ? "$r16" :
			id == 17 ? "$r17" :
			id == 18 ? "$r18" :
			id == 19 ? "$r19" :
			id == 20 ? "$r20" :
			id == 21 ? "$r21" :
			id == 22 ? "$r22" :
			id == 23 ? "$r23" :
			id == 24 ? "$r24" :
			id == 25 ? "$r25" :
			id == 26 ? "$r26" :
			id == 27 ? "$r27" :
			id == 28 ? "$r28" :
			id == 29 ? "$ESP" :
			id == 30 ? "$LR" :
			id == 31 ? "$FL" : "";
		
		if(name == "")
		{
			throw reg_oob_exception();
		}
		
		return name;
	}

	bool r_inst(opcode operation)
	{
		return
		
			operation == ADD ? true :
			operation == ADDI ? true :
			operation == SUB ? true :
			operation == SUBI ? true :
			operation == AND ? true :
			operation == OR ? true :
			operation == XOR ? true :
			operation == NEG ? true :
			operation == SLL ? true :
			operation == SLR ? true :
			operation == SAR ? true :
			operation == LD ? true :
			operation == ST ? true :
			operation == nop ? true :
			operation == BEQ ? true :
			operation == BEQ ? true :
			operation == BNE ? true :
			operation == BON ? true :
			operation == BNN ? true :
			operation == JR ? true :
			operation == RIN ? true :
			false ;
	}

	bool m_inst(opcode operation) 
	{
		return
			operation == LDI ? true :
			operation == STI ? true: false ;
	}

	bool j_inst(opcode operation)
	{
		return
			operation == JMP ? true :
			operation == JAL ? true: false;
	}

	bool mem_inst(opcode operation)
	{
		return
			(mem_write_inst(operation) || mem_read_inst(operation))?
			true : false;
	}

	bool mem_write_inst(opcode operation)
	{
		return
			(operation == ST || operation == STI)?
			true : false;
	}

	bool mem_read_inst(opcode operation)
	{
		return
			(operation == LD || operation == LDI)?
			true : false;
	}

	bool reg_write_inst(opcode operation)
	{
		return
			(mem_read_inst(operation)) || (r_inst(operation)) || (operation == JAL); // todo JAL is special, does it count?
	}

	bool jorb_inst(opcode operation)
	{
		// First check jumps
		bool is_jump = j_inst(operation); // false if JR

		bool is_jr = operation == JR;

		bool is_branch =
			operation == BEQ ? true :
			operation == BNE ? true :
			operation == BON ? true :
			operation == BNN ? true : false;

		return is_jump || is_branch || is_jr;
	}

	BW_32 generic_mips32_encode(int rs, int rt, int rd, int imm, opcode op)
	{
		BW_32 w = 0;

		if(r_inst(op))
		{
			w = (w.AsUInt32() | ((imm & ((1 << 12) - 1) ) << 0 ));
			w = (w.AsUInt32() | ((rt & ((1 << 5) - 1) ) << 12 ));
			w = (w.AsUInt32() | ((rs & ((1 << 5) - 1) ) << 17 ));
			w = (w.AsUInt32() | ((rd & ((1 << 5) - 1) ) << 22 ));
			w = (w.AsUInt32() | ((op & ((1 << 5) - 1) ) << 27 ));
		}

		if(m_inst(op)) // LDI, STI
		{
			w = (w.AsUInt32() | (imm & ((1 << 16) - 1)));
			w = (w.AsUInt32() | ((rs & ((1 << 5) - 1) ) << 17 )); // note bit 16 is blank
			w = (w.AsUInt32() | ((rd & ((1 << 5) - 1) ) << 22 ));
			w = (w.AsUInt32() | ((op & ((1 << 6) - 1) ) << 27 ));
		}

		if(j_inst(op)) // J, JAL, not JR which is r_inst
		{
			w = (w.AsUInt32() | (imm & ((1 << 14) - 1)));
			w = (w.AsUInt32() | ((op & ((1 << 6) - 1) ) << 27 ));
		}

		return w;
	}

	BW_32 offset_to_address_br(BW_32 current, BW_32 target)
	{
		BW_32 ret = target.AsUInt32() - current.AsUInt32();
		ret = ret.AsUInt32() - 4;
		ret = (ret.AsUInt32() >> 2);
		return ret;
	}

	// Main interpretation routine
	mBW MIPS_32::assemble(const Arg_Vec& args, const BW& baseAddress, syms_table& jump_syms) const
	{
		if(args.size() < 1)
			return std::shared_ptr<BW>(new BW_32());

		priscas::opcode current_op = priscas::SYS_RES;

		int rs = 0;
		int rt = 0;
		int rd = 0;
		int imm = 0;

		// Mnemonic resolution
		
		if("add" == args[0]) { current_op = priscas::ADD; }
		else if("addi" == args[0]) { current_op = priscas::ADDI; }
		else if("sub"== args[0]) { current_op = priscas::SUB; }
		else if("subi" == args[0]) { current_op = priscas::SUBI; }
		else if("and" == args[0]) { current_op = priscas::AND; }
		else if("or" == args[0]) { current_op = priscas::OR; }
		else if("xor" == args[0]) { current_op = priscas::XOR; }
		else if("neg" == args[0]) { current_op = priscas::NEG; }
		else if("sll" == args[0]) { current_op = priscas::SLL; }
		else if("slr" == args[0]) { current_op = priscas::SLR; }	
		else if("sar" == args[0]) { current_op = priscas::SAR; }	
		else if("ld" == args[0]) { current_op = priscas::LD; }	
		else if("ldi" ==  args[0]) { current_op = priscas::LDI; }
		else if("st" == args[0]) { current_op = priscas::ST; }
		else if("sti" == args[0]) { current_op = priscas::STI; }
		else if("nop" == args[0]) { current_op = priscas::nop; }
		else if("beq" == args[0]) { current_op = priscas::BEQ; }
		else if("bne" == args[0]) { current_op = priscas::BNE; }
		else if("bon" == args[0]) { current_op = priscas::BON; }
		else if("bnn" == args[0]) { current_op = priscas::BNN; }
		else if("jmp" == args[0]) { current_op = priscas::JMP; }
		else if("jr" == args[0]) { current_op = priscas::JR; }	
		else if("jal" == args[0]) { current_op = priscas::JAL;}
		else if("rin" == args[0]) { current_op = priscas::RIN; }	
		else
		{
			throw mt_bad_mnemonic();
		}

		if(args.size() > 1)
		{
			// Check for insufficient arguments	(not anymore)
			/*if	(
					(r_inst(current_op) && args.size() != 2 && current_op == priscas::JR) || // JR
					(m_inst(current_op) && args.size() != 3) || // LDI or STI
					(j_inst(current_op) && args.size() != 2) // JMP or JAL				
				)
			{
				throw priscas::mt_asm_bad_arg_count();
			}*/

			// Now first argument parsing
			if(r_inst(current_op))
			{
			        //ST, Branches, and JR start with Rs
					if(current_op == priscas::ST || 
					    current_op == priscas::BEQ || current_op == priscas::BNE || 
					    current_op == priscas::BON || current_op == priscas::BNN || 
					    current_op == priscas::JR)
					{
						if((rs = priscas::friendly_to_numerical(args[1].c_str())) <= priscas::INVALID)
						    rs = priscas::get_reg_num(args[1].c_str());
					}
					else
					{
						if((rd = priscas::friendly_to_numerical(args[1].c_str())) <= priscas::INVALID)
						    rd = priscas::get_reg_num(args[1].c_str());
					}
			}
			else if(m_inst(current_op)) // LDI and STI
			{
			    if (current_op==priscas::LDI) { //LDI
    				if((rd = priscas::friendly_to_numerical(args[1].c_str())) <= priscas::INVALID)
        				rd = priscas::get_reg_num(args[1].c_str());
			    }
			    else { //STI
			        if((rs = priscas::friendly_to_numerical(args[1].c_str())) <= priscas::INVALID)
        				rs = priscas::get_reg_num(args[1].c_str());
			    }
			}
			else if(j_inst(current_op)) // JMP and JAL
			{
			    imm = priscas::get_imm(args[1].c_str());
			}
			else
			{
				priscas::mt_bad_mnemonic();
			} 
		}
		// Second Argument Parsing
		if(args.size() > 2)
		{
			if(r_inst(current_op))
			{
			    if (current_op == priscas::ST) {
			        if((rt = priscas::friendly_to_numerical(args[2].c_str())) <= priscas::INVALID)
				    	rt = priscas::get_reg_num(args[2].c_str());
			    }
			    else {
				    if((rs = priscas::friendly_to_numerical(args[2].c_str())) <= priscas::INVALID)
				    	rs = priscas::get_reg_num(args[2].c_str());
			    }
			}
						
			else if(m_inst(current_op))
			{
				imm = priscas::get_imm(args[2].c_str());
			}
			else if(j_inst(current_op)){}
		}
		// Third Argument Parsing
		if(args.size() > 3)
		{
			// Third Argument Parsing
			if(r_inst(current_op))
			{
			    if (current_op == priscas::ADDI || current_op == priscas::SUBI) {
			        imm = priscas::get_imm(args[3].c_str());
			    }
			    else {
				    if((rt = priscas::friendly_to_numerical(args[3].c_str())) <= priscas::INVALID)
				    	rt = priscas::get_reg_num(args[3].c_str());
			    }
			}
			else if(m_inst(current_op)){}
			else if(j_inst(current_op)){}
		}
		
		// Pass the values of rs, rt, rd to the processor's encoding function
		BW_32 inst = generic_mips32_encode(rs, rt, rd, imm, current_op);

		return std::shared_ptr<BW>(new BW_32(inst));
	}

	// Returns register number corresponding with argument if any
	// Returns -1 if invalid or out of range
	int get_reg_num(const char * reg_str)
	{
		std::vector<char> numbers;
		int len = strlen(reg_str);
		if(len <= 1) throw priscas::mt_bad_imm();
		if(reg_str[0] != '$') throw priscas::mt_parse_unexpected("$", reg_str);
		for(int i = 1; i < len; i++)
		{
			if(reg_str[i] >= '0' && reg_str[i] <= '9')
			{
				numbers.push_back(reg_str[i]);
			}

			else throw priscas::mt_bad_reg_format();
		}

		int num = -1;

		if(numbers.empty()) throw priscas::mt_bad_reg_format();
		else
		{
			char * num_str = new char[numbers.size()];

			int k = 0;
			for(std::vector<char>::iterator itr = numbers.begin(); itr < numbers.end(); itr++)
			{
				num_str[k] = *itr;
				k++;
			}
			num = atoi(num_str);
			delete[] num_str;
		}

		return num;
	}

	// Returns immediate value if valid
	int get_imm(const char * str)
	{
		return StrOp::StrToUInt32(UPString(str));
	}
}
