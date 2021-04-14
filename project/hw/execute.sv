module execute(clk, rst,
    // AluOp, AluOUT, read1data, read2data, ReadData1, ReadData2, AluSrc,
    //           Branch, Jump, Siic, RTI, NOP, ImmiAct, pcAdd2, PC, HALT_IN,
    //           instr_1_0, instr_10_8, instr_4_2, instr_7_5,
    //           WriteReg, RegDst, writeregsel, ForwardA, ForwardB,
    //           AluOUT_exmem, RegDataWrite, PC_Change, HALT_OUT);

    input clk, rst;

    input DeEx_out_mem_wrt;
    input DeEx_out_reg_wrt_en;
    input DeEx_out_reg_wrt_sel;
    input DeEx_out_mem_en;
    input DeEx_out_result_sel;
    input DeEx_out_Branch;
    input DeEx_out_Jump;
    input DeEx_out_PC_next;
    input DeEx_out_reg_1;
    input DeEx_out_reg_2;
    input DeEx_out_ALU_src;
    input DeEx_out_imm;
    input DeEx_out_ALU_op;
    input reg_wrt_data;
    input ExMe_out_alu_out;
    input forward1_sel, forward2_sel;


    output [31:0] ExMe_in_alu_out;


    logic [31:0] alu_1, alu_2;

    mux2_1 i_mux1 (.in0(reg_wrt_data), .in1(DeEx_out_reg_1), .sel(forward1_sel), .out(alu_1));
    mux2_1 i_mux2 (.in0(reg_wrt_data), .in1(DeEx_out_reg_2), .sel(forward2_sel), .out(ExMe_in_reg_2));
    mux2_1 i_mux3 (.in0(ExMe_in_reg_2), .in1(DeEx_out_imm), .sel(DeEx_out_ALU_src), .out(alu_2));

    logic [3:0] aluOP;
    logic [31:0] newPC;

    always @(posedge clk) begin
        newPC = (DeEx_out_imm << 2) + DeEx_out_PC_next;
        casex(DeEx_out_ALU_op)
            5'b0xxxx: aluOP = DeEx_out_ALU_op[3:0];
            default: aluOP = 4'b1111;// error
        endcase // DeEx_out_ALU_op
    end

    dsf

    alu i_alu (
        .A   (alu_1 ),
        .B   (alu_2 ),
        .Op  (aluOp ),
        .Out (AluOUT)
    );

endmodule
