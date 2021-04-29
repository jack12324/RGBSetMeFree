module execute_tb();

    logic clk;                                  // make
    logic rst_n;                                  // make

    logic DeEx_out_Branch;              // assign
    logic DeEx_out_Jump;                // assign
    logic [4:0] DeEx_out_ALU_op;        // assign
    logic [1:0] DeEx_out_ALU_src;       // assign
    logic [1:0] forward1_sel;           // assign
    logic [1:0] forward2_sel;           // assign
    logic DeEx_out_mem_wrt;             // xyz
    logic DeEx_out_reg_wrt_en;          // xyz
    logic DeEx_out_mem_en;              // xyz
    logic [1:0] DeEx_out_result_sel;    // xyz
    logic [31:0] DeEx_out_PC_next;      // assign
    logic [31:0] DeEx_out_reg_1;        // assign
    logic [31:0] DeEx_out_reg_2;        // assign
    logic [31:0] DeEx_out_imm;          // assign
    logic [1:0] DeEx_out_FL;            // assign
    logic [31:0] DeEx_out_LR;           // assign
    logic [31:0] reg_wrt_data;          // assign
    logic [31:0] ExMe_out_alu_out;      // assign - xyz
    logic [31:0] ExMe_in_alu_out;       // test
    logic [31:0] ExMe_in_PC_next;       // test
    logic [31:0] ExMe_in_LR_wrt_data;   // test
    logic [31:0] ExMe_in_reg_2;         // test
    logic [1:0] ExMe_in_FL_wrt_data;    // test


    initial begin
        clk = 0;
        rst_n = 0;
        DeEx_out_Branch = 0;
        DeEx_out_Jump = 0;
        DeEx_out_ALU_op = 5'd0;
        DeEx_out_ALU_src = 2'd0;
        forward1_sel = 2'b0;
        forward2_sel = 2'b0;
        DeEx_out_PC_next = 32'd0;
        DeEx_out_reg_1 = 32'd0;
        DeEx_out_reg_2 = 32'd0;
        DeEx_out_imm = 32'd0;
        DeEx_out_FL = 2'b0;
        reg_wrt_data = 32'd0;
        ExMe_out_alu_out = 32'd0;

        repeat(5) @(posedge clk);
        rst_n = 1;
        repeat(5) @(posedge clk);
        DeEx_out_Branch = 0;
        DeEx_out_Jump = 0;
        DeEx_out_ALU_op = 5'd0;
        DeEx_out_ALU_src = 2'd1;
        forward1_sel = 2'b0;
        forward2_sel = 2'b0;
        DeEx_out_PC_next = 32'd8;
        DeEx_out_reg_1 = 32'd10;
        DeEx_out_reg_2 = 32'd5;
        DeEx_out_imm = 32'd50;
        DeEx_out_FL = 2'b00;
        reg_wrt_data = 32'd100;
        ExMe_out_alu_out = 32'd200;

        repeat(1) @(posedge clk);
        $stop();

    end

    execute i_execute (
        .clk                (clk                ),
        .rst_n              (rst_n              ),
        .DeEx_out_Branch    (DeEx_out_Branch    ),
        .DeEx_out_Jump      (DeEx_out_Jump      ),
        .DeEx_out_ALU_op    (DeEx_out_ALU_op    ),
        .DeEx_out_ALU_src   (DeEx_out_ALU_src   ),
        .forward1_sel       (forward1_sel       ),
        .forward2_sel       (forward2_sel       ),
        .DeEx_out_mem_wrt   (DeEx_out_mem_wrt   ),
        .DeEx_out_reg_wrt_en(DeEx_out_reg_wrt_en),
        .DeEx_out_mem_en    (DeEx_out_mem_en    ),
        .DeEx_out_result_sel(DeEx_out_result_sel),
        .DeEx_out_PC_next   (DeEx_out_PC_next   ),
        .DeEx_out_reg_1     (DeEx_out_reg_1     ),
        .DeEx_out_reg_2     (DeEx_out_reg_2     ),
        .DeEx_out_imm       (DeEx_out_imm       ),
        .DeEx_out_FL        (DeEx_out_FL        ),
        .DeEx_out_LR        (DeEx_out_LR        ),
        .reg_wrt_data       (reg_wrt_data       ),
        .ExMe_out_alu_out   (ExMe_out_alu_out   ),
        .ExMe_in_alu_out    (ExMe_in_alu_out    ),
        .ExMe_in_PC_next    (ExMe_in_PC_next    ),
        .ExMe_in_LR_wrt_data(ExMe_in_LR_wrt_data),
        .ExMe_in_reg_2      (ExMe_in_reg_2      ),
        .ExMe_in_FL_wrt_data(ExMe_in_FL_wrt_data)
    );

    always
        #5 clk = ~clk;

endmodule
