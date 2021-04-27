module cpu(clk, rst_n);

    input clk;  // System clock 
    input rst_n; // Active low reset for the system

    // Insterrupt Signals 
    input INT;
    input [31:0] INT_INSTR;
    output ACK;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////// SIGNALS TO THE SYSTEM /////////////////////////////////////////
    logic flush; 

    /////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////// Fetch Signals ////////////////////////////
    // inputs 
	logic [31:0] in_PC_next;
	logic stall, flush;
    // outputs 
	logic [31:0] out_PC_next;
	logic [31:0] instr;
	logic Done;
    /////////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////////
    //////////////////// FeDe Pipeline Register Signals /////////////////////////

    // Outputs to the next stage in the pipeline 5
    logic [31:0] FeDe_out_PC_next;
	logic [31:0] FeDe_out_instr;
	
    /////////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////////
    ///////////////////////////// Decode Signals ////////////////////////////////
	logic [31:0] reg_wrt_data; // also used in write back 
    // All other signals are declared in DeEx
    /////////////////////////////////////////////////////////////////////////////
    

    /////////////////////////////////////////////////////////////////////////////
    //////////////////// DeEx Pipeline Register Signals /////////////////////////
    logic [31:0] DeEx_in_PC_next;
	logic [31:0] DeEx_in_reg_1_data;
	logic [31:0] DeEx_in_reg_2_data;
	logic [31:0] DeEx_in_imm;
	// special register stuff
	logic [31:0] DeEx_in_LR;
	logic [1:0] DeEx_in_FL;
	// control for special registers
	logic DeEx_in_LR_read;
	logic DeEx_in_LR_write;
	logic DeEx_in_FL_read;
	logic DeEx_in_FL_write;
	//control for forwarding 
	logic [4:0] DeEx_in_reg_1_sel;
	logic [4:0] DeEx_in_reg_2_sel;
	// control for Execute
	logic [1:0] DeEx_in_ALU_src;
	logic [4:0] DeEx_in_ALU_OP;
	logic DeEx_in_Branch;
	logic DeEx_in_Jump;
	// control for Memory
	logic DeEx_in_mem_wrt;
	logic DeEx_in_mem_en;
	// control for Writeback
	logic [1:0] DeEx_in_result_sel;
	logic DeEx_in_reg_wrt_en;
	logic [4:0] DeEx_in_reg_wrt_sel;

    /////////// Output to the next stage in the CPU //////////////////
    logic [31:0] DeEx_out_PC_next;
	logic [31:0] DeEx_out_reg_1_data;
	logic [31:0] DeEx_out_reg_2_data;
	logic [31:0] DeEx_out_imm;
	logic DeEx_flush;
	// special register stuff
	logic [31:0] DeEx_out_LR;
	logic [1:0] DeEx_out_FL;
	// control for special registers
	logic DeEx_out_LR_read;
	logic DeEx_out_LR_write;
	logic DeEx_out_FL_read;
	logic DeEx_out_FL_write;
	//control for forwarding 
	logic [4:0] DeEx_out_reg_1_sel;
	logic [4:0] DeEx_out_reg_2_sel;
	// control for Execute
	logic [1:0] DeEx_out_ALU_src;
	logic [4:0] DeEx_out_ALU_OP;
	logic DeEx_out_Branch;
	logic DeEx_out_Jump;
	// control for Memory
	logic DeEx_out_mem_wrt;
	logic DeEx_out_mem_en;
	// control for Writeback
	logic [1:0] DeEx_out_result_sel;
	logic DeEx_out_reg_wrt_en;
	logic [4:0] DeEx_out_reg_wrt_sel;
    /////////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////////
    //////////////////////////// Execute Signals ////////////////////////////////
    input [1:0] forward1_sel,
    input [1:0] forward2_sel, // Both from the forwarding unit 
    /////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////



    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// MODULE DECLARATIONS //////////////////////////////////////////

    /////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////// Fetch module /////////////////////////////
    fetch iFETCH (
        ////////// INPUTS ///////////
        .clk(clk), .rst_n(rst_n),
        .in_PC_next(in_PC_next), //[31:0]
        .stall(stall), .flush(flush),
        // for interrupts
        .INT(INT),
        .INT_INSTR(INT_INSTR), //[31:0]
        ////////// OUTPUTS //////////
        .out_PC_next(out_PC_next), //[31:0]
        .instr(instr), //[31:0]
        .Done(Done),
        // for interrupts
        .ACK(ACK)
    );
    /////////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////////
    /////////////////// Fetch - Decode Pipeline registers ///////////////////////
    FeDe iFEDE(
        ////////// INPUTS ///////////
        .clk(clk),
        .rst_n(rst_n),
        .out_PC_next(out_PC_next), //[31:0]
        .instr(instr), //[31:0]
        .flush(flush),

        ////////// OUTPUTS //////////
        .FeDe_out_PC_next(FeDe_in_PC_next), //[31:0]
        .FeDe_out_instr(FeDe_out_instr), //[31:0]
    );
    /////////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////////
    /////////////////////////// Decode Module /////////////////////////////////// 
    decode iDECODE(
        ////////////////// INPUTS /////////////////////
        .clk(clk), .rst_n(rst_n),
        .instr(FeDe_out_instr), //[31:0]
        .in_PC_next(FeDe_out_PC_next), //[31:0]
        .reg_wrt_en(MeWb_out_reg_write_en),
        .reg_wrt_sel(MeWb_out_reg_write_sel), //[4:0]
        .reg_wrt_data(reg_wrt_data), //[31:0]
        // special register stuff
        .in_LR_wrt_data(MeWb_out_LR_wrt_data), //[31:0]
        .in_FL_wrt_data(MeWb_out_FL_wrt_data), //[1:0]
        // control
        .flush(flush),
        // control for special register stuff
        .in_LR_write(MeWb_out_LR_write),
        .in_FL_write(MeWb_out_FL_write),

        //////////////////// OUTPUTS //////////////////
        .out_PC_next(DeEx_in_PC_next), //[31:0]
        .reg_1_data(DeEx_in_reg_1_data), //[31:0]
        .reg_2_data(DeEx_in_reg_2_data), //[31:0]
        .imm(DeEx_in_imm), //[31:0]
        // special register stuff
        .LR(DeEx_in_LR), //[31:0]
        .FL(DeEx_in_FL), //[1:0]
        // control for special registers
        .LR_read(DeEx_in_LR_read), 
        .LR_write(DeEx_in_LR_write),
        .FL_read(DeEx_in_FL_read),
        .FL_write(DeEx_in_FL_write),
        // control for Execute
        .ALU_src(DeEx_in_ALU_src), //[1:0]
        .ALU_OP(DeEx_ALU), //[4:0]
        .Branch(DeEx_in_Branch), 
        .Jump(DeEx_in_Jump),
        // control for Memory
        .mem_wrt(DeEx_in_mem_wrt),
        .mem_en(DeEx_in_mem_en),
        // control for Writeback
        .result_sel(DeEx_in_result_sel), //[1:0]
        .next_reg_wrt_en(DeEx_in_reg_wrt_en), 
        .next_reg_wrt_sel(DeEx_in_reg_wrt_sel)
	);
    /////////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////////
    ///////////////////// Decode - Execute Pipeline Regs ////////////////////////
    DeEx iDEEX(
        //////////////////////////// Inputs /////////////////////////////
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush),
        .DeEx_in_PC_next(DeEx_in_PC_next), // [31:0]
        .DeEx_in_reg_1_data(DeEx_in_reg_1_data), // [31:0]
        .DeEx_in_reg_2_data(DeEx_in_reg_1_data), // [31:0]
        .DeEx_in_imm(DeEx_in_imm), // [31:0]
        .flush(flush),
        // special register stuff
        .DeEx_in_LR(DeEx_in_LR), // [31:0]
        .DeEx_in_FL(DeEx_in_FL), // [1:0]
        // control for special registers
        .DeEx_in_LR_read(DeEx_in_LR_read),
        .DeEx_in_LR_write(DeEx_in_LR_write),
        .DeEx_in_FL_read(DeEx_in_FL_read),
        .DeEx_in_FL_write(DeEx_in_FL_write),
        //control for forwarding 
        .DeEx_in_reg_1_sel(DeEx_in_reg_1_sel), // [4:0]
        .DeEx_in_reg_2_sel(DeEx_in_reg_2_sel), // [4:0]
        // control for Execute
        .DeEx_in_ALU_src(DeEx_in_ALU_src), // [1:0]
        .DeEx_in_ALU_OP(DeEx_in_ALU_OP), // [4:0]
        .DeEx_in_Branch(DeEx_in_Branch),
        .DeEx_in_Jump(DeEx_in_Jump),
        // control for Memory
        .DeEx_in_mem_wrt(DeEx_in_mem_wrt),
        .DeEx_in_mem_en(DeEx_in_mem_en),
        // control for Writeback
        .DeEx_in_result_sel(DeEx_in_result_sel), // [1:0]
        .DeEx_in_reg_wrt_en(DeEx_in_reg_wrt_en),
        .DeEx_in_reg_wrt_sel(DeEx_in_reg_wrt_sel), // [4:0]

        /////////// Output to the next stage in the CPU //////////////////
        .DeEx_out_PC_next(DeEx_out_PC_next), // [31:0]
        .DeEx_out_reg_1_data(DeEx_out_reg_1_data), // [31:0]
        .DeEx_out_reg_2_data(DeEx_out_reg_2_data), // [31:0]
        .DeEx_out_imm(DeEx_out_imm), // [31:0]
        .DeEx_flush(DeEx_flush),
        // special register stuff
        .DeEx_out_LR(DeEx_out_LR), // [31:0]
        .DeEx_out_FL(DeEx_out_FL), // [1:0]
        // control for special registers
        .DeEx_out_LR_read(DeEx_out_LR_read),
        .DeEx_out_LR_write(DeEx_out_LR_write),
        .DeEx_out_FL_read(DeEx_out_FL_read),
        .DeEx_out_FL_write(DeEx_out_FL_write),
        //control for forwarding 
        .DeEx_out_reg_1_sel(DeEx_out_reg_1_sel), // [4:0]
        .DeEx_out_reg_2_sel(DeEx_out_reg_2_sel), // [4:0]
        // control for Execute
        .DeEx_out_ALU_src(DeEx_out_ALU_src), // [1:0]
        .DeEx_out_ALU_OP(DeEx_out_ALU_OP), // [4:0]
        .DeEx_out_Branch(DeEx_out_Branch),
        .DeEx_out_Jump(DeEx_out_Jump),
        // control for Memory
        .DeEx_out_mem_wrt(DeEx_out_mem_wrt),
        .DeEx_out_mem_en(DeEx_out_mem_en),
        // control for Writeback
        .DeEx_out_result_sel(DeEx_out_result_sel), // [1:0]
        .DeEx_out_reg_wrt_en(DeEx_out_reg_wrt_en),
        .DeEx_out_reg_wrt_sel(DeEx_out_reg_wrt_sel) // [4:0]
    );
    ///////////////////////////////////////////////////////////////////////////// 


    /////////////////////////////////////////////////////////////////////////////
    /////////////////////////// Execute Module ////////////////////////////////// 
    execute(
        .clk(clk),
        .rst_n(rst_n),

        // controls:
        input DeEx_out_Branch,
        input DeEx_out_Jump,
        input [4:0] DeEx_out_ALU_op,
        input [1:0] forward1_sel,
        input [1:0] forward2_sel, // forwarding

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
        input [31:0] DeEx_out_LR,
        input [31:0] reg_wrt_data,         // from WB
        input [31:0] ExMe_out_alu_out,

        output [31:0] ExMe_in_alu_out,
        output [31:0] ExMe_in_PC_next,
        output [31:0] ExMe_in_LR_wrt_data,
        output [31:0] ExMe_in_reg_2,
        output [1:0] ExMe_in_FL_wrt_data
    );
    /////////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////////
    ///////////////////// Execute - Memory Pipeline Regs ////////////////////////

    /////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////



endmodule