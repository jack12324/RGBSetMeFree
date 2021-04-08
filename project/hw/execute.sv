module execute(clk, rst,
    // AluOp, AluOUT, read1data, read2data, ReadData1, ReadData2, AluSrc,
    //           Branch, Jump, Siic, RTI, NOP, ImmiAct, pcAdd2, PC, HALT_IN,
    //           instr_1_0, instr_10_8, instr_4_2, instr_7_5,
    //           WriteReg, RegDst, writeregsel, ForwardA, ForwardB,
    //           AluOUT_exmem, RegDataWrite, PC_Change, HALT_OUT);

    input clk, rst;

    input DeEx_out_mem_wrt;
    input DeEx_out_
    input DeEx_out_
    ...
    // input [4:0] aluOP;
    /*input Jump, Siic, RTI, NOP, HALT_IN;
    input [2:0] Branch;
    input [15:0] ImmiAct, pcAdd2;
    input [15:0] read1data, read2data;
    input [1:0] ReadData1;
    input ReadData2, AluSrc;
    // input invA, invB, Cin;
    input [2:0] instr_7_5, instr_4_2, instr_10_8;
    input [1:0] instr_1_0;
    input WriteReg;
    input [1:0] RegDst;
    input [4:0] AluOp;
    input [1:0] ForwardA, ForwardB;
    input [15:0] RegDataWrite, AluOUT_exmem;

    output [2:0] writeregsel;
    output [15:0] PC;
    output [15:0] AluOUT;
    output PC_Change, HALT_OUT;*/
    // output eq, ne, lt, geq;


    wire eq;
    wire ne;
    wire lt;
    wire geq;
    wire br;

    assign br = (Branch == 3'b100) ? eq :
                (Branch == 3'b101) ? ne :
                (Branch == 3'b110) ? lt :
                (Branch == 3'b111) ? geq : 1'b0;

    wire Sn;
    wire [15:0] S;
    wire Ofl;
    wire Cout;

    wire [15:0] ImmiAct;

    shl i_shl (.A(DeEx_out_imm),.B(2'b10),.Out(ImmiAct));
    add i_add (.A(pcAdd2), .B(ImmiAct), .Cin(1'b0), .Sn(1'b0), .S(S), .Ofl(Ofl), .Cout(Cout));

    wire [15:0] alu_1, alu_2_imm, alu_2;
    mux i_m1 (.A(DeEx_out_reg_1), .B(reg_wrt_data), .sel(forward1_sel), .Out(alu_1));
    mux i_m2a (.A(DeEx_out_reg_2), .B(reg_wrt_data), .sel(forward2_sel), .Out(alu_2_imm));
    mux i_m2b (.A(DeEx_out_imm), .B(alu_2_imm), .sel(DeEx_out_ALU_src), .Out(alu_2_imm));

    reg [4:0] aluOp;

    always @(*) begin
        case(AluOp)
            5'd10: begin
                aluOp = (instr_1_0 == 2'b00) ? 5'd1 :
                        (instr_1_0 == 2'b01) ? 5'd2 :
                        (instr_1_0 == 2'b10) ? 5'd3 : 5'd4;
            end
            5'd11: begin
                aluOp = (instr_1_0 == 2'b00) ? 5'd5 :
                        (instr_1_0 == 2'b01) ? 5'd6 :
                        (instr_1_0 == 2'b10) ? 5'd7 : 5'd8;
            end
            default: aluOp = AluOp;
        endcase
    end

    wire [15:0] A, B;
    wire Cin;
    wire invA;
    wire invB;
    wire sign;

    // wire [15:0] RD1, RD2;
    // AluOUT_exmem, RegDataWrite
    // assign RD1 = (ForwardA == 2'b00) ? read1data :
    //              (ForwardA == 2'b01) ? RegDataWrite : AluOUT_exmem;
    // assign RD2 = (ForwardB == 2'b00) ? read2data :
    //              (ForwardB == 2'b01) ? RegDataWrite : AluOUT_exmem;

    assign A = (ReadData1 == 2'b00) ? pcAdd2 :
               (ReadData1 == 2'b01) ? 16'b0 : ((ForwardA == 2'b00) ? read1data :
                 (ForwardA == 2'b01) ? RegDataWrite : AluOUT_exmem);
    assign B = (ReadData2 == 1'b0) ? 16'b0 :
               (AluSrc == 1'b0) ? ((ForwardB == 2'b00) ? read2data :
                 (ForwardB == 2'b01) ? RegDataWrite : AluOUT_exmem) : ImmiAct;
    assign invB = (((aluOp == 5'd4) | (aluOp == 5'd12) | (aluOp == 5'd13) | (aluOp == 5'd14)) == 1'b1) ? 1'b1 : 0;
    assign invA = (aluOp == 5'd2);
    assign Cin = invB | invA;


    // ALU Operations:

    alu i_alu (
        .A   (alu_1     ),
        .B   (alu_2     ),
        .Cin (Cin   ),
        .Op  (aluOp ),
        .invA(invA  ), .invB(invB),
        .sign(sign  ),
        .Out (AluOUT),
        // .Cout(Ofl   ),
        .eq  (eq    ),
        .ne  (ne    ),
        .lt  (lt    ),
        .geq (geq   )
    );

    assign writeregsel = (WriteReg == 1'b1) ? 3'b111 :
                         (RegDst == 2'b01) ? instr_10_8 :
                         (RegDst == 2'b10) ? instr_4_2 : instr_7_5;

    wire [15:0] EPC, prevEPC;

    assign prevEPC = (Siic == 1'b0) ? EPC : pcAdd2;

    dff dff0[15:0] (.q(EPC), .d(prevEPC), .clk(clk), .rst(rst));

    assign PC_Change = ((br == 1'b1) | (Jump == 1'b1) | (Siic == 1'b1) | (RTI == 1'b1));

    assign HALT_OUT = PC_Change ? 1'b0 : HALT_IN;

    assign PC = (br == 1'b1) ? S :
                (Jump == 1'b1) ? AluOUT :
                (Siic == 1'b1) ? 16'h0002 :
                (RTI == 1'b1 ) ? EPC : pcAdd2;


endmodule
