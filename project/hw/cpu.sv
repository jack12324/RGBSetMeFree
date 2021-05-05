module cpu(
	clk, rst_n, 
	INT, INT_INSTR, ACK,
	// Wires to mem_ctrl
	FeDataIn_host,
	Fetx_done_host,
	Ferd_valid_host,
	FeDataOut_host,
	FeAddrOut_host,
	Feop_host,
	MeDataIn_host,
	Metx_done_host,
	Merd_valid_host,
	MeDataOut_host,
	MeAddrOut_host,
	Meop_host,
	//jumpstart
	startFPU
	);

    input clk;  // System clock 
    input rst_n; // Active low reset for the system
	
    // Interrupt Signals 
    input INT;
    input [31:0] INT_INSTR;
    output ACK;

	//Wires to Mem_ctrl from Fetch and Memory (inst and data memory)
	//Fetch
	input logic [511:0] FeDataIn_host;
	input logic Fetx_done_host;
	input logic Ferd_valid_host;
	output logic [511:0] FeDataOut_host;
	output logic [31:0] FeAddrOut_host;
	output logic [1:0] Feop_host;
	//Memory
	input logic [511:0] MeDataIn_host;
	input logic Metx_done_host;
	input logic Merd_valid_host;
	output logic [511:0] MeDataOut_host;
	output logic [31:0] MeAddrOut_host;
	output logic [1:0] Meop_host;
	
	//jumpstartFPU
	output logic startFPU;

    /////////////////////////////////////////////////////////////////////////////
    ///////////////////////// Interrupts FSM Signals ////////////////////////////

    ///////////// Inputs /////////////
    //input clk,
    //input rst_n,
    //input INT,
    //input [31:0] INT_INSTR,
    // logic [31:0] cpu_intr; --> FeDe_in_instr

    logic [31:0] current_PC; // the PC that is currently 
                                // stored in the Fetch stage 
    // logic [31:0] current_LR; --> DeEx_in_LR
    // logic [1:0] current_FL; --> DeEx_in_FL

    ///////////// Outputs /////////////
    //output logic ACK,
    // This inputs are stored when servicing an interrupt 
    logic [31:0] PC_before_int;
    logic [31:0] LR_before_int;
    logic [1:0] FL_before_int;

    logic use_INT_INSTR; // signal to use the injected instructions
                            // from the interrupt controller 
    logic use_cpu_injection; // signal to use the injected 
                                //instructions from this FSM 
    logic [31:0] cpu_injection; // Injection from this state machine 

    logic restore; // signal to restore the special regs
    /////////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////// Fetch Signals ////////////////////////////
    // inputs 
	logic [31:0] ExMe_out_PC_next;
	logic stall, flush;
	// also the Interrupt signals
    // outputs 
	logic [31:0] FeDe_in_PC_next;
	logic [31:0] FeDe_in_instr;
	logic FeDone;
	// also the Interrupt signals
    /////////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////////
    //////////////////// FeDe Pipeline Register Signals /////////////////////////

    // Outputs to the next stage in the pipeline
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
        // control
        //logic DeEx_out_Branch; // commented means already declared
        //logic DeEx_out_Jump;
        //logic [4:0] DeEx_out_ALU_OP;
        logic [1:0] forward1_sel;
        logic [1:0] forward2_sel;

        // From ID/EX:
        //logic DeEx_out_mem_wrt;
        //logic DeEx_out_reg_wrt_en;
        //logic DeEx_out_mem_en;
        //logic [1:0] DeEx_out_result_sel;
        //logic [31:0] DeEx_out_PC_next;
        //logic [31:0] DeEx_out_reg_1_data; // note _data
        //logic [31:0] DeEx_out_reg_2_data; // note _data
        //logic [1:0] DeEx_out_ALU_src;
        //logic [31:0] DeEx_out_imm;
        //logic [1:0] DeEx_out_FL;
        //logic [31:0] DeEx_out_LR; 
        //logic [31:0] reg_wrt_data;
        //logic [31:0] ExMe_out_alu_out;

        //logic [31:0] ExMe_in_alu_out;
        //logic [31:0] ExMe_in_PC_next;
        //logic [31:0] ExMe_in_LR_wrt_data;
        logic [31:0] ExMe_in_reg_2_data;
        //logic [1:0] ExMe_in_FL_wrt_data;
    /////////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////////
    ///////////////////////// Forwarding Signals ////////////////////////////////
    // input clk, rst_n;
    // input ExMe_out_reg_wrt_en;
    // input [4:0] ExMe_out_reg_wrt_sel;
    // input MeWb_out_reg_wrt_en;
    // input [4:0] MeWb_out_reg_wrt_sel; 
    // input [4:0] DeEx_out_reg_1_sel, DeEx_out_reg_2_sel;
    // input DeEx_out_FL_write, ExMe_out_FL_write, MeWb_out_FL_write;
    // input DeEx_out_LR_write, ExMe_out_LR_write, MeWb_out_LR_write;
    // input [1:0] DeEx_FL, ExMe_FL, MeWb_FL; ---------> DeEx_out_FL, ExMe_out_FL, MeWb_out_FL
    // input [31:0] DeEx_LR, ExMe_LR, MeWb_LR; --------> DeEx_out_LR, ExMe_out_LR, MeWb_out_LR

    // output [1:0] forward1_sel, forward2_sel;
    logic forward_LR_sel;
    logic [1:0] forward_FL_sel;
    /////////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////////
    //////////////////// ExMe Pipeline Register Signals /////////////////////////
    // Inputs to the pipeline registers 
    // Data signals 
    	logic [31:0] ExMe_in_PC_next;
    	logic [31:0] ExMe_in_alu_out;
    	//logic [31:0] DeEx_out_reg_2_data;
    	logic [31:0] ExMe_in_LR; 
    	logic [1:0] ExMe_in_FL; 
    	logic [31:0] ExMe_in_LR_wrt_data;
    	logic [1:0] ExMe_in_FL_wrt_data;
    // Control Signals 
    	//logic DeEx_out_mem_wrt;
    	//logic DeEx_out_mem_en;
    	//logic DeEx_out_reg_wrt_en;
    	//logic [4:0] DeEx_out_reg_wrt_sel;
    	//logic [1:0] DeEx_out_result_sel;
    	//logic DeEx_out_LR_read;
    	//logic DeEx_out_LR_write;
    	//logic DeEx_out_FL_read;
    	//logic DeEx_out_FL_write;
    // Ouputs to the next pipeline stage 
    // Data signals 
    	//logic [31:0] ExMe_out_PC_next;
    	logic [31:0] ExMe_out_alu_out;
        logic ExMe_out_Branch;
	    logic ExMe_out_Jump;
        logic [4:0] ExMe_out_ALU_OP;
    	logic [31:0] ExMe_out_reg_2_data;
    	logic [31:0] ExMe_out_LR;
    	logic [1:0] ExMe_out_FL;
    	logic [31:0] ExMe_out_LR_wrt_data;
    	logic [1:0] ExMe_out_FL_wrt_data;
    // Control Signals 
    	logic ExMe_out_mem_wrt;
    	logic ExMe_out_mem_en;
    	logic ExMe_out_reg_wrt_en;
    	logic [4:0] ExMe_out_reg_wrt_sel;
    	logic [1:0] ExMe_out_result_sel;
    	logic ExMe_out_LR_read;
    	logic ExMe_out_LR_write;
    	logic ExMe_out_FL_read;
    	logic ExMe_out_FL_write;
    /////////////////////////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////////////////////////
    //////////////////////////// Memory Signals ////////////////////////////////
    // Data
  	//logic [31:0] ExMe_out_alu_out;
  	//logic [31:0] ExMe_out_reg_2_data;
    // Control
  	//logic ExMe_out_mem_wrt;
  	//logic ExMe_out_mem_en;
    // Output
  	logic [31:0] mem_data;
  	logic MeDone;

    /////////////////////////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////////////////////////
    //////////////////// MeWb Pipeline Register Signals /////////////////////////
    // inputs to the pipeline register
    // data signals  
    	//logic [31:0] ExMe_out_alu_out;
    	//logic [31:0] mem_data; declared in Memory
    	//logic [31:0] ExMe_out_PC_next;
    	logic [31:0] MeWb_in_LR;
    	logic [1:0] MeWb_in_FL;
    	logic [31:0] MeWb_in_LR_wrt_data;
    	logic [1:0] MeWb_in_FL_wrt_data;
    // control signals 
    	//logic [1:0] ExMe_out_result_sel;
    	//logic ExMe_out_reg_wrt_en;
    	//logic [4:0] ExMe_out_reg_wrt_sel;
    	//logic ExMe_out_LR_read;
    	//logic ExMe_out_LR_write;
    	//logic ExMe_out_FL_read;
    	//logic ExMe_out_FL_write;
    
    // outputs to the pipeline register 
    	logic [31:0] MeWb_out_alu_out;
    	logic [31:0] MeWb_out_mem_data;
    	logic [31:0] MeWb_out_PC_next;
    	logic [31:0] MeWb_out_LR;
    	logic [1:0] MeWb_out_FL;
    	logic [31:0] MeWb_out_LR_wrt_data;
    	logic [1:0] MeWb_out_FL_wrt_data;
    // control signals 
    	logic [1:0] MeWb_out_result_sel;
    	logic [4:0] MeWb_out_reg_wrt_sel;
    	logic MeWb_out_reg_wrt_en;
    	logic MeWb_out_LR_read;
    	logic MeWb_out_LR_write;
    	logic MeWb_out_FL_read;
    	logic MeWb_out_FL_write;
    /////////////////////////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////////////////////////
    //////////////////////////// Writeback Signals ////////////////////////////////
    // Data
  	//logic [31:0] MeWb_out_alu_out;
  	//logic [31:0] MeWb_out_mem_data;
  	//logic [31:0] MeWb_out_PC_next;
    // Control
  	//logic [1:0] MeWb_out_result_sel;
    // Output
  	//logic [31:0] reg_wrt_data;
    /////////////////////////////////////////////////////////////////////////////


    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// MODULE DECLARATIONS //////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////////
    ////////////////////////// Interrupt FSM module /////////////////////////////
    CPU_interrupt_fsm iFSM(
        ////////// INPUTS ///////////
        .clk(clk),
        .rst_n(rst_n),
        .INT(INT),
        .INT_INSTR(INT_INSTR),
        .cpu_instr(FeDe_in_instr),
        .current_PC(current_PC), 
        .current_LR(DeEx_in_LR), 
        .current_FL(DeEx_in_FL),
        ////////// OUTPUTS //////////
        .ACK(ACK),
        .PC_before_int(PC_before_int),
        .LR_before_int(LR_before_int),
        .FL_before_int(FL_before_int),
        .use_INT_INSTR(use_INT_INSTR), 
        .use_cpu_injection(use_cpu_injection), 
        .cpu_injection(cpu_injection), 
        .restore(restore) 
    );
    /////////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////// Fetch module /////////////////////////////
    fetch iFETCH (
        ////////// INPUTS ///////////
        .clk(clk), .rst_n(rst_n),
        .in_PC_next(ExMe_out_PC_next), //[31:0]
        .stall(stall), .flush(flush),
        // for interrupts
        //.INT(INT),
        .INT_INSTR(INT_INSTR), //[31:0]
        .PC_before_int(PC_before_int),
        .restore(restore),
        .use_cpu_injection(use_cpu_injection), 
        .cpu_injection(cpu_injection), 
        .use_INT_INSTR(use_INT_INSTR),

        .ExMe_out_Branch(ExMe_out_Branch), 
	    .ExMe_out_Jump(ExMe_out_Jump), 
        .ExMe_out_ALU_OP(ExMe_out_ALU_OP),
	    .ExMe_out_LR(ExMe_out_LR), 
	    .ExMe_out_FL(ExMe_out_FL),

        ////////// OUTPUTS //////////
        .out_PC_next(FeDe_in_PC_next), //[31:0]
        .instr(FeDe_in_instr), //[31:0]
        .Done(FeDone),
        // for interrupts
        //.ACK(ACK)
        .current_PC(current_PC),
	//////////WIRES TO MEM_CTRL///////////
	.DataIn_host(FeDataIn_host),
	.tx_done_host(Fetx_done_host),
	.rd_valid_host(Ferd_valid_host),
	.DataOut_host(FeDataOut_host),
	.AddrOut_host(FeAddrOut_host),
	.op_host(Feop_host)
    );
    /////////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////////
    /////////////////// Fetch - Decode Pipeline registers ///////////////////////
    FeDe iFEDE(
        ////////// INPUTS ///////////
        .clk(clk),
        .rst_n(rst_n),
        .FeDe_in_PC_next(FeDe_in_PC_next), //[31:0]
        .FeDe_in_instr(FeDe_in_instr), //[31:0]
        .flush(flush),
        .stall(~stall),//write enable

        ////////// OUTPUTS //////////
        .FeDe_out_PC_next(FeDe_out_PC_next), //[31:0]
        .FeDe_out_instr(FeDe_out_instr) //[31:0]
    );
    /////////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////////
    /////////////////////////// Decode Module /////////////////////////////////// 
    decode iDECODE(
        ////////////////// INPUTS /////////////////////
        .clk(clk), .rst_n(rst_n),
        .instr(FeDe_out_instr), //[31:0]
        .in_PC_next(FeDe_out_PC_next), //[31:0]
        .reg_wrt_en(MeWb_out_reg_wrt_en),
        .reg_wrt_sel(MeWb_out_reg_wrt_sel), //[4:0]
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
        .ALU_OP(DeEx_in_ALU_OP), //[4:0]
        .Branch(DeEx_in_Branch), 
        .Jump(DeEx_in_Jump),
        // control for Memory
        .mem_wrt(DeEx_in_mem_wrt),
        .mem_en(DeEx_in_mem_en),
        // control for Writeback
        .result_sel(DeEx_in_result_sel), //[1:0]
        .next_reg_wrt_en(DeEx_in_reg_wrt_en), 
        .next_reg_wrt_sel(DeEx_in_reg_wrt_sel),
	.DeEx_in_reg_1_sel(DeEx_in_reg_1_sel),
	.DeEx_in_reg_2_sel(DeEx_in_reg_2_sel),

        //////////// INTERRUPT SIGNALS /////////////
        .restore(restore), 
        .LR_before_int(LR_before_int), 
        .FL_before_int(FL_before_int)
	);
    /////////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////////
    ///////////////////// Decode - Execute Pipeline Regs ////////////////////////
    DeEx iDEEX(
        //////////////////////////// Inputs /////////////////////////////
        .clk(clk),
        .rst_n(rst_n),
        .stall(~stall),
        .DeEx_in_PC_next(DeEx_in_PC_next), // [31:0]
        .DeEx_in_reg_1_data(DeEx_in_reg_1_data), // [31:0]
        .DeEx_in_reg_2_data(DeEx_in_reg_2_data), // [31:0]
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
    execute iEXECUTE(
        .clk(clk),
        .rst_n(rst_n),
        // controls
 	.DeEx_out_Branch(DeEx_out_Branch),
        .DeEx_out_Jump(DeEx_out_Jump),
        .DeEx_out_ALU_op(DeEx_out_ALU_OP),//lowercase op in execute module
        .forward1_sel(forward1_sel),
        .forward2_sel(forward2_sel),
        .forward_FL_sel(forward_FL_sel), // new  
        .forward_LR_sel(forward_LR_sel), // new

        // From ID/EX:
        .DeEx_out_mem_wrt(DeEx_out_mem_wrt),
        .DeEx_out_reg_wrt_en(DeEx_out_reg_wrt_en),
        .DeEx_out_mem_en(DeEx_out_mem_en),
        .DeEx_out_result_sel(DeEx_out_result_sel),
        .DeEx_out_PC_next(DeEx_out_PC_next),    
        .DeEx_out_reg_1(DeEx_out_reg_1_data),
        .DeEx_out_reg_2(DeEx_out_reg_2_data),
        .DeEx_out_ALU_src(DeEx_out_ALU_src),    
        .DeEx_out_imm(DeEx_out_imm),
        .DeEx_out_FL(DeEx_out_FL),
        .DeEx_out_LR(DeEx_out_LR),
        .reg_wrt_data(reg_wrt_data),
        .ExMe_out_alu_out(ExMe_out_alu_out),

        // new inputs for forwarding 
        .ExMe_out_FL(ExMe_out_FL), // new
        .MeWb_out_FL(MeWb_out_FL), // new
        .ExMe_out_LR(ExMe_out_LR), // new
        .MeWb_out_LR(MeWb_out_LR), // new 

        // Outputs
	.ExMe_in_alu_out(ExMe_in_alu_out),
        .ExMe_in_PC_next(ExMe_in_PC_next),
        .ExMe_in_LR_wrt_data(ExMe_in_LR_wrt_data),
        .ExMe_in_reg_2_data(ExMe_in_reg_2_data),
        .ExMe_in_FL_wrt_data(ExMe_in_FL_wrt_data)
    );
    /////////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////////
    /////////////////////////// Forwarding  Unit //////////////////////////////// 

    forwarding iFORWARD(
        // input
        .clk(clk), 
	.rst_n(rst_n),
        .ExMe_out_reg_wrt_en(ExMe_out_reg_wrt_en), 
	.ExMe_out_reg_wrt_sel(ExMe_out_reg_wrt_sel),
        .MeWb_out_reg_wrt_en(MeWb_out_reg_wrt_en), 
	.MeWb_out_reg_wrt_sel(MeWb_out_reg_wrt_sel),
        .DeEx_out_reg_1_sel(DeEx_out_reg_1_sel), 
	.DeEx_out_reg_2_sel(DeEx_out_reg_2_sel),
        .ExMe_out_FL_write(ExMe_out_FL_write), 
	.DeEx_out_FL_write(DeEx_out_FL_write), 
	.MeWb_out_FL_write(MeWb_out_FL_write),
        .ExMe_out_LR_write(ExMe_out_LR_write), 
	.DeEx_out_LR_write(DeEx_out_LR_write), 
	.MeWb_out_LR_write(MeWb_out_LR_write),
        .DeEx_FL(DeEx_out_FL), 
	.ExMe_FL(ExMe_out_FL), 
	.MeWb_FL(MeWb_out_FL), 
        .DeEx_LR(DeEx_out_LR), 
	.ExMe_LR(ExMe_out_LR), 
	.MeWb_LR(MeWb_out_LR),
        // output
        .forward_LR_sel(forward_LR_sel),
        .forward_FL_sel(forward_FL_sel),
        .forward1_sel(forward1_sel), 
	.forward2_sel(forward2_sel)
    );

    // input clk, rst_n;
    // input ExMe_out_reg_wrt_en;
    // input [4:0] ExMe_out_reg_wrt_sel;
    // input MeWb_out_reg_wrt_en;
    // input [4:0] MeWb_out_reg_wrt_sel; --------> MeWb_out_reg_wrt_sel
    // input [4:0] DeEx_out_reg_1_sel, DeEx_out_reg_2_sel;
    // input DeEx_out_FL_write, ExMe_out_FL_write, MeWb_out_FL_write;
    // input DeEx_out_LR_write, ExMe_out_LR_write, MeWb_out_LR_write;
    // input [1:0] DeEx_FL, ExMe_FL, MeWb_FL; ---------> DeEx_out_FL, ExMe_out_FL, MeWb_out_FL
    // input [31:0] DeEx_LR, ExMe_LR, MeWb_LR; --------> DeEx_out_LR, ExMe_out_LR, MeWb_out_LR

    // output [1:0] forward1_sel, forward2_sel;
    // logic forward_LR_sel;
    // logic [1:0] forward_FL_sel;

    /////////////////////////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////////////////////////
    ///////////////////// Execute - Memory Pipeline Regs ////////////////////////
    ExMe iEXME(
        // Inputs to the pipeline registers 
    	// Data signals 
    .clk(clk),
    .rst_n(rst_n),
    .stall(~stall),
	.ExMe_in_PC_next(ExMe_in_PC_next),
    .DeEx_out_Branch(DeEx_out_Branch), 
	.DeEx_out_Jump(DeEx_out_Jump), 
    .DeEx_out_ALU_OP(DeEx_out_ALU_OP), 

	.ExMe_in_alu_out(ExMe_in_alu_out),
	.ExMe_in_reg_2_data(ExMe_in_reg_2_data), //could be an issue, see vs DeEx_out_reg_2
	.ExMe_in_LR(ExMe_in_LR),
	.ExMe_in_FL(ExMe_in_FL),
	.ExMe_in_LR_wrt_data(ExMe_in_LR_wrt_data),
	.ExMe_in_FL_wrt_data(ExMe_in_FL_wrt_data),
    	// Control Signals 
	.DeEx_out_mem_wrt(DeEx_out_mem_wrt),
	.DeEx_out_mem_en(DeEx_out_mem_en),
	.DeEx_out_reg_wrt_en(DeEx_out_reg_wrt_en),
	.DeEx_out_reg_wrt_sel(DeEx_out_reg_wrt_sel),
	.DeEx_out_result_sel(DeEx_out_result_sel),
	.DeEx_out_LR_read(DeEx_out_LR_read),
	.DeEx_out_LR_write(DeEx_out_LR_write),
	.DeEx_out_FL_read(DeEx_out_FL_read),
	.DeEx_out_FL_write(DeEx_out_FL_write),

    	// Ouputs to the next pipeline stage 
    	// Data signals 
	.ExMe_out_PC_next(ExMe_out_PC_next),
    	.ExMe_out_Branch(ExMe_out_Branch),
    	.ExMe_out_Jump(ExMe_out_Jump),
    	.ExMe_out_ALU_OP(ExMe_out_ALU_OP),

	.ExMe_out_alu_out(ExMe_out_alu_out),
	.ExMe_out_reg_2_data(ExMe_out_reg_2_data),
	.ExMe_out_LR(ExMe_out_LR),
	.ExMe_out_FL(ExMe_out_FL),
	.ExMe_out_LR_wrt_data(ExMe_out_LR_wrt_data),
	.ExMe_out_FL_wrt_data(ExMe_out_FL_wrt_data),
    	// Control Signals 
	.ExMe_out_mem_wrt(ExMe_out_mem_wrt),
	.ExMe_out_mem_en(ExMe_out_mem_en),
	.ExMe_out_reg_wrt_en(ExMe_out_reg_wrt_en),
	.ExMe_out_reg_wrt_sel(ExMe_out_reg_wrt_sel),
	.ExMe_out_result_sel(ExMe_out_result_sel),
	.ExMe_out_LR_read(ExMe_out_LR_read),
	.ExMe_out_LR_write(ExMe_out_LR_write),
	.ExMe_out_FL_read(ExMe_out_FL_read),
	.ExMe_out_FL_write(ExMe_out_FL_write)
    );
    /////////////////////////////////////////////////////////////////////////////


  /////////////////////////////////////////////////////////////////////////////
    /////////////////////////// Memory Module ////////////////////////////////// 
    memory iMEMORY(
	.clk(clk),
	.rst_n(rst_n),
  // Data
  	.ExMe_out_alu_out(ExMe_out_alu_out),
  	.ExMe_out_reg_2_data(ExMe_out_reg_2_data),
  // Control
  	.ExMe_out_mem_wrt(ExMe_out_mem_wrt),
  	.ExMe_out_mem_en(ExMe_out_mem_en),
  	.mem_data(mem_data),
  	.done(MeDone),
   //////////WIRES TO MEM_CTRL///////////
	.DataIn_host(MeDataIn_host),
	.tx_done_host(Metx_done_host),
	.rd_valid_host(Merd_valid_host),
	.DataOut_host(MeDataOut_host),
	.AddrOut_host(MeAddrOut_host),
	.op_host(Meop_host),
	.startFPU(startFPU)
    );
    /////////////////////////////////////////////////////////////////////////////


    /////////////////////////////////////////////////////////////////////////////
    ///////////////////// Memory - Writeback Pipeline Regs ////////////////////////
    MeWb iMEWB(
	.clk(clk),
	.rst_n(rst_n),
    	.stall(~stall),
    // inputs to the pipeline register
    // data signals  
	.ExMe_out_alu_out(ExMe_out_alu_out),
	.mem_data(mem_data),
	.ExMe_out_PC_next(ExMe_out_PC_next), 
	.MeWb_in_LR(MeWb_in_LR),
	.MeWb_in_FL(MeWb_in_FL),
	.MeWb_in_LR_wrt_data(MeWb_in_LR_wrt_data),
	.MeWb_in_FL_wrt_data(MeWb_in_FL_wrt_data),
    // control signals 
	.ExMe_out_result_sel(ExMe_out_result_sel),
	.ExMe_out_reg_wrt_en(ExMe_out_reg_wrt_en),
	.ExMe_out_reg_wrt_sel(ExMe_out_reg_wrt_sel), 
	.ExMe_out_LR_read(ExMe_out_LR_read),
	.ExMe_out_LR_write(ExMe_out_LR_write),
	.ExMe_out_FL_read(ExMe_out_FL_read),
	.ExMe_out_FL_write(ExMe_out_FL_write),    
    // outputs to the pipeline register 
	.MeWb_out_alu_out(MeWb_out_alu_out),
	.MeWb_out_mem_data(MeWb_out_mem_data),
	.MeWb_out_PC_next(MeWb_out_PC_next),
	.MeWb_out_LR(MeWb_out_LR),
	.MeWb_out_FL(MeWb_out_FL),
	.MeWb_out_LR_wrt_data(MeWb_out_LR_wrt_data),
	.MeWb_out_FL_wrt_data(MeWb_out_FL_wrt_data),
    // control signals 
	.MeWb_out_result_sel(MeWb_out_result_sel),
	.MeWb_out_reg_wrt_sel(MeWb_out_reg_wrt_sel),
	.MeWb_out_reg_wrt_en(MeWb_out_reg_wrt_en),
	.MeWb_out_LR_read(MeWb_out_LR_read),
	.MeWb_out_LR_write(MeWb_out_LR_write),
	.MeWb_out_FL_read(MeWb_out_FL_read),
	.MeWb_out_FL_write(MeWb_out_FL_write)
    );
    /////////////////////////////////////////////////////////////////////////////


    /////////////////////////// Writeback Module ////////////////////////////////// 
    writeback iWRITEBACK(
        .clk(clk),
	.rst_n(rst_n),
   // Data
	.MeWb_out_alu_out(MeWb_out_alu_out),
	.MeWb_out_mem_data(MeWb_out_mem_data),
	.MeWb_out_PC_next(MeWb_out_PC_next),
  // Control
	.MeWb_out_result_sel(MeWb_out_result_sel),
  // Output
	.reg_wrt_data(reg_wrt_data)
    );
    /////////////////////////////////////////////////////////////////////////////

 
	// connect wires
	assign ExMe_in_FL = DeEx_out_FL;
	assign ExMe_in_LR = DeEx_out_LR;
	assign MeWb_in_LR = ExMe_out_LR;
	assign MeWb_in_FL = ExMe_out_FL;
	assign MeWb_in_LR_wrt_data = ExMe_out_LR_wrt_data; 
	assign MeWb_in_FL_wrt_data = ExMe_out_FL_wrt_data;
    // FLush logic 
    // .ExMe_out_Branch(ExMe_out_Branch),
    // .ExMe_out_Jump(ExMe_out_Jump),
    // .ExMe_out_ALU_OP(ExMe_out_ALU_OP),
    // .ExMe_out_FL(ExMe_out_FL),  / N = ExMe_out_FL[1] /  Z = ExMe_out_FL[0]

    assign flush =  (ExMe_out_Branch && ~ExMe_out_Jump) ?  ((ExMe_out_ALU_OP == 2'd0 && ExMe_out_FL[0] == 1) ? (1'b1) :  
                                                            (ExMe_out_ALU_OP == 2'd1 && ExMe_out_FL[0] == 0) ? (1'b1) : 
                                                            (ExMe_out_ALU_OP == 2'd2 && ExMe_out_FL[1] == 1) ? (1'b1) : 
                                                            (ExMe_out_ALU_OP == 2'd3 && ExMe_out_FL[1] == 0) ? (1'b1) : 1'b0) : 
                                                    ( ExMe_out_Jump ? ( (ExMe_out_ALU_OP == 2'd0 || ExMe_out_ALU_OP == 2'd2) ? (1'b1) : 
                                                    ((ExMe_out_ALU_OP == 2'd1) ? (1'b1) : 1'b0)) : 1'b0);

    assign stall = ~MeDone | ~FeDone; 


// todo stalling (insert NOPs, using Done signals and prediction and stuff, see 552)
// todo flushing (flush up to execute, using Branching, see 552)

endmodule
