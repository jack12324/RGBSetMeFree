module Branch_Jump(clk, rst_n, branch, jump, pc, pc_2, pc_immi, PC);

    input clk, rst_n;
    input branch, jump;
    input [31:0] pc, pc_2, pc_immi;

    output [31:0] PC;

    logic [31:0] readN_Z;
    // logic [31:0] readZ;

    regFile_bypass i_regFile_bypass (
        .clk         (clk         ),
        .rst_n       (rst_n       ),
        .read1RegSel (read1RegSel ),    // set to FL
        .read2RegSel (read2RegSel ),    // set to FL
        .reg_wrt_sel (5'd0        ),
        .reg_wrt_data(32'd0       ),
        .reg_wrt_en  (1'b0        ),
        .read1Data   (readN_Z     ),
        .read2Data   (            )
    );

    PC =

endmodule
