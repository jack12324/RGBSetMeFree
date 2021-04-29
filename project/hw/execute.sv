module execute(
    input clk,
    input rst_n,

    // controls:
    input DeEx_out_Branch,
    input DeEx_out_Jump,
    input [4:0] DeEx_out_ALU_op,
    input [1:0] forward1_sel,
    input [1:0] forward2_sel, // forwarding
    input forward_LR_sel,
    input [1:0] forward_FL_sel,

    // From ID/EX:

    input DeEx_out_mem_wrt,
    input DeEx_out_reg_wrt_en,
    input DeEx_out_mem_en,
    input [1:0] DeEx_out_result_sel,
    input [31:0] DeEx_out_PC_next,     // just the current PC
    input [31:0] DeEx_out_reg_1,
    input [31:0] DeEx_out_reg_2,
    input [1:0] DeEx_out_ALU_src,      // 0 => immi
    input [31:0] DeEx_out_imm,
    input [1:0] DeEx_out_FL,
    input [1:0] ExMe_out_FL,
    input [1:0] MeWb_out_FL,
    input [31:0] DeEx_out_LR,
    input [31:0] reg_wrt_data,         // from WB
    input [31:0] ExMe_out_alu_out,
    input [31:0] ExMe_out_LR,
    input [31:0] MeWb_out_LR,

    output [31:0] ExMe_in_alu_out,
    output [31:0] ExMe_in_PC_next,
    output [31:0] ExMe_in_reg_2,
    output [31:0] ExMe_in_LR_wrt_data,
    output [1:0] ExMe_in_FL_wrt_data
    );

    logic [31:0] alu_1, alu_2;

    logic [31:0] forwarded_LR;
    logic [1:0] forwarded_FL;

    mux2_1 i_mux_2_0(.in0(ExMe_out_LR),.in1(MeWb_out_LR), .sel({1'b0,forward_LR_sel}), .out(forwarded_LR));

    mux4_1 i_mux3_1 (.in_reg(DeEx_out_reg_1), .in_alu(ExMe_out_alu_out), .in_wb(reg_wrt_data), .in_LR(forwarded_LR), .sel(forward1_sel), .out(alu_1));
    mux4_1 i_mux3_2 (.in_reg(DeEx_out_reg_2), .in_alu(ExMe_out_alu_out), .in_wb(reg_wrt_data), .in_LR(32'd0), .sel(forward2_sel), .out(ExMe_in_reg_2));

    mux2_1 i_mux2_1 (.in0(DeEx_out_imm), .in1(ExMe_in_reg_2), .sel(DeEx_out_ALU_src), .out(alu_2));

    //FL
    //0, 1, 2, 3
    mux3_1_fl i_mux3_fl (.in_reg(DeEx_out_FL), .in_alu(ExMe_out_FL), .in_wb(MeWb_out_FL), .sel(forward_FL_sel), .out(forwarded_FL));




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

    Branch_Jump i_Branch_Jump (
        .clk         (clk                 ),
        .rst_n       (rst_n               ),
        .branch      (DeEx_out_Branch     ),
        .jump        (DeEx_out_Jump       ),
        .FL          (forwarded_FL        ),
        .pc_4        (pc_4                ),
        .pc_immi     (pc_immi             ),
        .immi        (DeEx_out_imm        ),
        .reg_a       (alu_1               ),
        .PC          (newPC               ),
        .LR_write_val(ExMe_in_LR_wrt_data ),
        .op_code     (DeEx_out_ALU_op[1:0])
    );


    alu i_alu (
        .A   (alu_1           ),
        .B   (alu_2           ),
        .Op  (aluOP           ),
        .Out (ExMe_in_alu_out )
    );
    assign ExMe_in_FL_wrt_data[0] = !(|ExMe_in_alu_out);
    assign ExMe_in_FL_wrt_data[1] = ExMe_in_alu_out[31];


endmodule
