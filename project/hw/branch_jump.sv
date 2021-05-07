module Branch_Jump(clk, rst_n,
                    branch, jump, op_code,
                    FL,
                    pc_4, pc_immi, reg_a, immi,
                    PC, LR_write_val);

    input clk, rst_n;
    input branch, jump;
    input [1:0] FL;
    input [1:0] op_code;
    input [31:0] pc_4, pc_immi, reg_a, immi;

    output [31:0] PC, LR_write_val;
    logic LR_write;

    logic [31:0] newPC;
    logic N, Z;

    assign N = FL[1];
    assign Z = FL[0];

    assign PC = (branch && ~jump) ? ((op_code == 2'd0 && Z == 1) ? (pc_4 + reg_a)
                            :  (op_code == 2'd1 && Z == 0) ? (pc_4 + reg_a)
                                : (op_code == 2'd2 && N == 1) ? (pc_4 + reg_a)
                                    : (op_code == 2'd3 && N == 0) ? (pc_4 + reg_a) : pc_4)
                : (jump ? ((op_code == 2'd0 || op_code == 2'd2) ? immi // (immi << 2) Decode already does this 
                            : ((op_code == 2'd1) ? (reg_a << 2)
                                : pc_4))  : pc_4);

    assign LR_write = jump && (op_code == 2'd2); // if JAL
    assign LR_write_val = LR_write ? pc_4 : 32'hFFFFFFFF; // if JAL, LR = PC+4
endmodule


// if(branch){
//     if(op_code == 2'd0 && Z == 1){
//         newPC = pc_4 + reg_a;
//     }
//     else if (op_code == 2'd1 && Z == 0){
//         newPC = pc_4 + reg_a;
//     }
//     else if (op_code == 2'd2 && N == 1){
//         newPC = pc_4 + reg_a;
//     } else if (op_code == 2'd3 && N == 0){
//         newPC = pc_4 + reg_a;
//     } else
//         newPC = pc_4;
// }
