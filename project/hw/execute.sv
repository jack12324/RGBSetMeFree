module execute(
    input clk, rst;

    // controls:
    input DeEx_out_Branch;
    input DeEx_out_Jump;
    input [4:0] DeEx_out_ALU_op;
    input [1:0] DeEx_out_ALU_src;
    input [1:0] forward1_sel, forward2_sel; // forwarding

    // From ID/EX:

    input DeEx_out_mem_wrt;
    input DeEx_out_reg_wrt_en;
    input DeEx_out_mem_en;
    input [1:0] DeEx_out_result_sel;
    input [31:0] DeEx_out_PC_next;     // just the current PC
    input [31:0] DeEx_out_reg_1;
    input [31:0] DeEx_out_reg_2;
    input [1:0] DeEx_out_ALU_src;      // 0 => immi
    input [31:0] DeEx_out_imm;
    input [1:0] DeEx_out_FL;
    input [31:0] DeEx_out_LR;
    input [31:0] reg_wrt_data;         // from WB
    input [31:0] ExMe_out_alu_out;
    input [31:0] ExMe_out_alu_out;

    output [31:0] ExMe_in_alu_out;
    output [31:0] ExMe_in_PC_next;
    output [31:0] ExMe_in_LR_wrt_data;
    output [1:0] ExMe_in_FL_wrt_data;
    );

    logic [31:0] alu_1, alu_2;

    mux3_1 i_mux3_1 (.in_reg(DeEx_out_reg_1), .in_alu(ExMe_out_alu_out), .in_wb(reg_wrt_data), .sel(forward1_sel), .out(alu_1));
    mux3_1 i_mux3_2 (.in_reg(DeEx_out_reg_1), .in_alu(ExMe_out_alu_out), .in_wb(reg_wrt_data), .sel(forward2_sel), .out(ExMe_in_reg_2));
    mux2_1 i_mux2_1 (.in0(DeEx_out_imm), .in1(ExMe_in_reg_2), .sel(DeEx_out_ALU_src), .out(alu_2));

    logic [3:0] aluOP;
    logic [31:0] newPC, pc_immi, pc_4;

    assign pc_immi = DeEx_out_imm + DeEx_out_PC_next + 4;
    assign pc_4 = DeEx_out_PC_next + 4;
    // do pc + 4

    always @(posedge clk) begin
        casex(DeEx_out_ALU_op)
            5'b0xxxx: aluOP = DeEx_out_ALU_op[3:0];
            default: aluOP = 4'b1111;// error
        endcase // DeEx_out_ALU_op
    end

    logic [31:0] LR_write_val;
    logic LR_write;

    Branch_Jump i_Branch_Jump (
        .clk         (clk             ),
        .rst_n       (rst_n           ),
        .branch      (DeEx_out_Branch ),
        .jump        (DeEx_out_Jump   ),
        .FL          (DeEx_out_FL     ),
        .pc_4        (pc_4            ),
        .pc_immi     (pc_immi         ),
        .immi        (DeEx_out_imm    ),
        .reg_a       (alu_1           ),
        .PC          (newPC           ),
        .LR_write_val(ExMe_in_LR_wrt_data    ),     // doubts
        .LR_write    (ExMe_in_LR_wrt_data        )
    );


    // Branch_Jump i_Branch_Jump (
    //     .clk    (clk             ),
    //     .rst_n  (rst_n           ),
    //     .branch (DeEx_out_Branch ),
    //     .jump   (DeEx_out_Jump   ),
    //     .pc_4   (pc_4            ),
    //     .pc_immi(pc_immi         ),
    //     .reg_a  (alu_1           ),
    //     .PC     (newPC           )
    // );

    alu i_alu (
        .A   (alu_1  ),
        .B   (alu_2  ),
        .Op  (aluOp  ),
        .Out (AluOUT )
    );

endmodule
