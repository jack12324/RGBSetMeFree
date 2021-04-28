module forwarding (
    // input
    clk, rst_n,
    ExMe_out_reg_write_en, ExMe_out_reg_wrt_sel,
    MeWb_out_reg_write_en, MeWb_out_reg_wrt_sel,
    DeEx_out_reg_1_sel, DeEx_out_reg_2_sel,
    ExMe_out_FL_write, DeEx_out_FL_write, MeWb_out_FL_write,
    ExMe_out_LR_write, DeEx_out_LR_write, MeWb_out_LR_write,
    DeEx_FL, ExMe_FL, MeWb_FL,
    DeEx_LR, ExMe_LR, MeWb_LR,
    // output
    forward_LR_sel,
    forward_FL_sel,
    forward1_sel, forward2_sel
);

    input clk, rst_n;
    input ExMe_out_reg_write_en;
    input [4:0] ExMe_out_reg_wrt_sel;
    input MeWb_out_reg_write_en;
    input [4:0] MeWb_out_reg_wrt_sel;
    input [4:0] DeEx_out_reg_1_sel, DeEx_out_reg_2_sel;
    input DeEx_out_FL_write, ExMe_out_FL_write, MeWb_out_FL_write;
    input DeEx_out_LR_write, ExMe_out_LR_write, MeWb_out_LR_write;
    input [1:0] DeEx_FL, ExMe_FL, MeWb_FL;
    input [31:0] DeEx_LR, ExMe_LR, MeWb_LR;

    output [1:0] forward1_sel, forward2_sel;
    output forward_LR_sel;
    output [1:0] forward_FL_sel;

    logic [1:0] forward1, forward2;
    logic forward_LR;
    logic [1:0] forward_FL;

    always_comb begin

        if((ExMe_out_LR_write | MeWb_out_LR_write) & ((DeEx_LR != ExMe_LR) || (DeEx_LR != MeWb_LR)))
            forward1 = 2'd3;
        if (ExMe_out_reg_write_en & (|ExMe_out_reg_wrt_sel) & (ExMe_out_reg_wrt_sel == DeEx_out_reg_1_sel))
            forward1 = 2'd2;
        else if (MeWb_out_reg_write_en & (!MeWb_out_reg_wrt_sel) & (MeWb_out_reg_wrt_sel == DeEx_out_reg_1_sel))
            forward1 = 2'd1;
        else
            forward1 = 2'd0;

        if (ExMe_out_reg_write_en & (|ExMe_out_reg_wrt_sel) & (ExMe_out_reg_wrt_sel == DeEx_out_reg_2_sel))
            forward2 = 2'd2;
        else if (MeWb_out_reg_write_en & (|MeWb_out_reg_wrt_sel) & (MeWb_out_reg_wrt_sel == DeEx_out_reg_2_sel))
            forward2 = 2'd1;
        else
            forward2 = 2'd0;


        // 0 => ExMe_FL, 1 => MeWb_FL
        forward_LR = ~ExMe_out_LR_write & MeWb_out_LR_write;

        // if (DeEx_FL != ExMe_FL)   // add write FL, add Mem/WB cond
        //     forward_FL = 1;   // don't go with value from DeEx
        // else
        //     forward_FL = 0;   // go with value from DeEx

        // if (DeEx_LR != ExMe_LR)   // add write FL
        //     forward_LR = 1;   // don't go with value from DeEx
        // else
        //     forward_LR = 0;   // go with value from DeEx

        if (ExMe_out_FL_write & (ExMe_FL != DeEx_FL))
            forward_FL = 2'd1;
        else if (MeWb_out_FL_write & (MeWb_FL != DeEx_FL))
            forward_FL = 2'd2;



    end

    assign forward1_sel = forward1;
    assign forward2_sel = forward2;
    assign forward_FL_sel = forward_FL;
    assign forward_LR_sel = forward_LR;

endmodule
