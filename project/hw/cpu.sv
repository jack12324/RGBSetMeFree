// OP CODE defines
// termination
`define HALT 16'b00000xxxxxxxxxxx
`define NOP 16'b00001xxxxxxxxxxx

//I type
`define ADDI 16'b01000xxxxxxxxxxx
`define SUBI 16'b01001xxxxxxxxxxx
`define XORI 16'b01010xxxxxxxxxxx
`define ANDNI 16'b01011xxxxxxxxxxx
`define ROLI 16'b10100xxxxxxxxxxx
`define SLLI 16'b10101xxxxxxxxxxx
`define RORI 16'b10110xxxxxxxxxxx
`define SRLI 16'b10111xxxxxxxxxxx

//Mem
`define ST 16'b10000xxxxxxxxxxx
`define LD 16'b10001xxxxxxxxxxx
`define STU 16'b10011xxxxxxxxxxx

//Strange one
`define BTR 16'b11001xxxxxxxxxxx

//R type
`define ADD 16'b11011xxxxxxxxx00
`define SUB 16'b11011xxxxxxxxx01
`define XOR 16'b11011xxxxxxxxx10
`define ANDN 16'b11011xxxxxxxxx11
`define ROL 16'b11010xxxxxxxxx00
`define SLL 16'b11010xxxxxxxxx01
`define ROR 16'b11010xxxxxxxxx10
`define SRL 16'b11010xxxxxxxxx11
`define SEQ 16'b11100xxxxxxxxxxx
`define SLT 16'b11101xxxxxxxxxxx
`define SLE 16'b11110xxxxxxxxxxx
`define SCO 16'b11111xxxxxxxxxxx

//Branch
`define BEQZ 16'b01100xxxxxxxxxxx
`define BNEZ 16'b01101xxxxxxxxxxx
`define BLTZ 16'b01110xxxxxxxxxxx
`define BGEZ 16'b01111xxxxxxxxxxx

//Strange ones
`define LBI 16'b11000xxxxxxxxxxx
`define SLBI 16'b10010xxxxxxxxxxx

//J type
`define J 16'b00100xxxxxxxxxxx
`define JR 16'b00101xxxxxxxxxxx
`define JAL 16'b00110xxxxxxxxxxx
`define JALR 16'b00111xxxxxxxxxxx

//For geniuses
`define SIIC 16'b00010xxxxxxxxxxx
`define RTI 16'b00011xxxxxxxxxxx

module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input clk;
   input rst;

   output err;

   // None of the above lines can be modified

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
	wire fetchErr, decodeErr, executeErr, memoryErr, wbErr;
	assign err = fetchErr | decodeErr | executeErr |  memoryErr | wbErr;
   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines
   
   
   /* your code here -- should include instantiations of fetch, decode, execute, mem and wb modules */




////////// inbetween wires and control signals
	// for fetch
	wire [15:0] PCinput;
	//output
	wire [15:0] FeDe_inInstr; //important wire, will be used for control signals
	wire [15:0] FeDe_inAddr;
		// control
	wire delay;
	wire FeDone, FeStall;
	wire MeDone, MeStall; //data memory access
	wire globalPause = ~rst & ~( MeStall);
	
//IF/ID
	wire [15:0] FeDe_outAddr;
	regDFF FeDe_nextAddr(.regQ(FeDe_outAddr), .regD(FeDe_inAddr), .clk(clk), .rst(rst), .writeEn(globalPause));
	wire [15:0] FeDe_outInstr; 
	wire [15:0] IFInput;
	regDFF FeDe_Instr(.regQ(FeDe_outInstr), .regD(IFInput), .clk(clk), .rst(1'b0), .writeEn(rst | globalPause));
												

	// for decode
		// control
	reg [1:0] dstReg;
	reg [1:0] sizeslc;
	reg extslc;
	//reg regWrite;

//ID/EX

	
	wire [15:0] DeEx_inNextInstrAddr;
	wire [15:0] DeEx_outNextInstrAddr;
	regDFF DeEx_nextInstrAddr(.regQ(DeEx_outNextInstrAddr), .regD(DeEx_inNextInstrAddr), .clk(clk), .rst(rst), .writeEn(globalPause));
	wire [15:0] DeEx_inReg1;
	wire [15:0] DeEx_outReg1;
	regDFF #(16) DeEx_Reg1(.regQ(DeEx_outReg1), .regD(DeEx_inReg1), .clk(clk), .rst(rst), .writeEn(globalPause));
	wire [15:0] DeEx_inReg2;
	wire [15:0] DeEx_outReg2;
	regDFF #(16) DeEx_Reg2(.regQ(DeEx_outReg2), .regD(DeEx_inReg2), .clk(clk), .rst(rst), .writeEn(globalPause));
	wire [15:0] DeEx_inExImm;
	wire [15:0] DeEx_outExImm;
	regDFF #(16) DeEx_ExImm(.regQ(DeEx_outExImm), .regD(DeEx_inExImm), .clk(clk), .rst(rst), .writeEn(globalPause));
	//control signals
	// decode control
	//reg cmp, cmpRslt;
	//reg DeEx_inPCSrc1, DeEx_inMemAddrSrc, DeEx_inALUCin, DeEx_inInvA, DeEx_inInvB, DeEx_inSign;
	//reg [2:0] ALUcntrl;
	//reg [1:0] ALUsrc1;
	//reg [1:0] ALUsrc2;
	//wire zero, ofl, ALUOutput15;
	wire [2:0] DeEx_inWriteRegAddr;
	wire [2:0] DeEx_outWriteRegAddr;
	regDFF #(3) DeEx_WriteRegAddr(.regQ(DeEx_outWriteRegAddr), .regD(DeEx_inWriteRegAddr), .clk(clk), .rst(rst), .writeEn(globalPause));
	reg DeEx_inWriteEn;
	wire DeEx_outWriteEn;
	regDFF #(1) DeEx_WriteEn(.regQ(DeEx_outWriteEn), .regD(DeEx_inWriteEn), .clk(clk), .rst(rst), .writeEn(globalPause));
	
	// execute control
	reg [1:0] DeEx_inALUSrc1;
	wire [1:0] DeEx_outALUSrc1;
	regDFF #(2) DeEx_ALUSrc1(.regQ(DeEx_outALUSrc1), .regD(DeEx_inALUSrc1), .clk(clk), .rst(rst), .writeEn(globalPause));
	reg [1:0] DeEx_inALUSrc2;
	wire [1:0] DeEx_outALUSrc2;
	regDFF #(2) DeEx_ALUSrc2(.regQ(DeEx_outALUSrc2), .regD(DeEx_inALUSrc2), .clk(clk), .rst(rst), .writeEn(globalPause));
	reg [2:0] DeEx_inALUCtrl;
	wire [2:0] DeEx_outALUCtrl;
	regDFF #(3) DeEx_ALUCtrl(.regQ(DeEx_outALUCtrl), .regD(DeEx_inALUCtrl), .clk(clk), .rst(rst), .writeEn(globalPause));
	reg DeEx_inMemAddrSrc;
	wire DeEx_outMemAddrSrc;
	regDFF #(1) DeEx_MemAddrSrc(.regQ(DeEx_outMemAddrSrc), .regD(DeEx_inMemAddrSrc), .clk(clk), .rst(rst), .writeEn(globalPause));
	reg DeEx_inPCSrc1;
	wire DeEx_outPCSrc1;
	regDFF #(1) DeEx_PCSrc1(.regQ(DeEx_outPCSrc1), .regD(DeEx_inPCSrc1), .clk(clk), .rst(rst), .writeEn(globalPause));
	reg DeEx_inALUCin;
	wire DeEx_outALUCin;
	regDFF #(1) DeEx_ALUCin(.regQ(DeEx_outALUCin), .regD(DeEx_inALUCin), .clk(clk), .rst(rst), .writeEn(globalPause));
	reg DeEx_inInvA;
	wire DeEx_outInvA;
	regDFF #(1) DeEx_InvA(.regQ(DeEx_outInvA), .regD(DeEx_inInvA), .clk(clk), .rst(rst), .writeEn(globalPause));
	reg DeEx_inInvB;
	wire DeEx_outInvB;
	regDFF #(1) DeEx_InvB(.regQ(DeEx_outInvB), .regD(DeEx_inInvB), .clk(clk), .rst(rst), .writeEn(globalPause));
	reg DeEx_inSign;
	wire DeEx_outSign;
	regDFF #(1) DeEx_Sign(.regQ(DeEx_outSign), .regD(DeEx_inSign), .clk(clk), .rst(rst), .writeEn(globalPause));
	reg [2:0] DeEx_inPCSrc2Code;
	wire [2:0] DeEx_outPCSrc2Code;
	regDFF #(3) DeEx_PCSrc2Code(.regQ(DeEx_outPCSrc2Code), .regD(DeEx_inPCSrc2Code), .clk(clk), .rst(rst), .writeEn(globalPause));
	reg DeEx_inCmp; 
	wire DeEx_outCmp;
	regDFF #(1) DeEx_Cmp(.regQ(DeEx_outCmp), .regD(DeEx_inCmp), .clk(clk), .rst(rst), .writeEn(globalPause));
	reg [1:0] DeEx_inCmpRsltCode;
	wire [1:0] DeEx_outCmpRsltCode;
	regDFF #(2) DeEx_CmpRsltCode(.regQ(DeEx_outCmpRsltCode), .regD(DeEx_inCmpRsltCode), .clk(clk), .rst(rst), .writeEn(globalPause));
	// memory control
	reg DeEx_inMemRead;
	wire DeEx_outMemRead;
	regDFF #(1) DeEx_MemRead(.regQ(DeEx_outMemRead), .regD(DeEx_inMemRead), .clk(clk), .rst(rst), .writeEn(globalPause));
	reg DeEx_inMemWrite;
	wire DeEx_outMemWrite;
	regDFF #(1) DeEx_MemWrite(.regQ(DeEx_outMemWrite), .regD(DeEx_inMemWrite), .clk(clk), .rst(rst), .writeEn(globalPause));
	reg DeEx_inCreateDump;
	wire DeEx_outCreateDump;
	regDFF #(1) DeEx_CreateDump(.regQ(DeEx_outCreateDump), .regD(DeEx_inCreateDump), .clk(clk), .rst(rst), .writeEn(globalPause));
	// writeback control
	reg DeEx_inMemToReg;
	wire DeEx_outMemToReg;
	regDFF #(1) DeEx_MemToReg(.regQ(DeEx_outMemToReg), .regD(DeEx_inMemToReg), .clk(clk), .rst(rst), .writeEn(globalPause));
	reg DeEx_inHalt;
	wire DeEx_outHalt;
	regDFF #(1) DeEx_Halt(.regQ(DeEx_outHalt), .regD(DeEx_inHalt), .clk(clk), .rst(rst), .writeEn(globalPause));
	// forwarding control
	wire [2:0] DeEx_inRs;
	wire [2:0] DeEx_outRs;
	regDFF #(3) DeEx_Rs(.regQ(DeEx_outRs), .regD(DeEx_inRs), .clk(clk), .rst(rst), .writeEn(globalPause));
	wire [2:0] DeEx_inRt;
	wire [2:0] DeEx_outRt;
	regDFF #(3) DeEx_Rt(.regQ(DeEx_outRt), .regD(DeEx_inRt), .clk(clk), .rst(rst), .writeEn(globalPause));
	// also using
	//ExMe_outWriteRegAddr
	//MeWb_outWriteRegAddr
	wire [15:0] ExInput1;
	wire [15:0] ExInput2;
	// stalling control
	wire [15:0] IDOutput;
	// implement rst and stall conditions, if so NOP
	reg DeEx_inBranchOrJump;
	wire DeEx_outBranchOrJump;
	regDFF #(1) DeEx_BranchOrJump(.regQ(DeEx_outBranchOrJump), .regD(DeEx_inBranchOrJump), .clk(clk), .rst(rst), .writeEn(globalPause));
	wire ExMe_inBranchOrJump;
	wire ExMe_outBranchOrJump;
	regDFF #(1) ExMe_BranchOrJump(.regQ(ExMe_outBranchOrJump), .regD(ExMe_inBranchOrJump), .clk(clk), .rst(rst), .writeEn(globalPause));

	// for execute
		// inputs
	//wire [15:0] nextInstrAddrDeEx;
	//wire [15:0] reg1;
	//wire [15:0] reg2DeEx;
	//wire [15:0] exImm;
		// outputs
	//wire [15:0] nextAddr;
	

//Ex/Mem
	wire ExMe_inPCSrc2;

	wire [15:0] ExMe_inNextAddr;
	wire [15:0] ExMe_outNextAddr;
	regDFF #(16) ExMe_NextAddr(.regQ(ExMe_outNextAddr), .regD(ExMe_inNextAddr), .clk(clk), .rst(rst), .writeEn(globalPause));
	wire [15:0] ExMe_inResult;
	wire [15:0] ExMe_outResult;
	regDFF #(16) ExMe_Result(.regQ(ExMe_outResult), .regD(ExMe_inResult), .clk(clk), .rst(rst), .writeEn(globalPause));
	wire [15:0] ExMe_inReg2;
	wire [15:0] ExMe_outReg2;
	regDFF #(16) ExMe_Reg2(.regQ(ExMe_outReg2), .regD(ExMe_inReg2), .clk(clk), .rst(rst), .writeEn(globalPause));
	wire ExMe_outPCSrc2;
	regDFF #(1) ExMe_PCSrc2(.regQ(ExMe_outPCSrc2), .regD(ExMe_inPCSrc2), .clk(clk), .rst(rst), .writeEn(globalPause));
	wire valid;
	regDFF #(1) FeDe_valid(.regQ(valid), .regD(~ExMe_inPCSrc2), .clk(clk), .rst(rst), .writeEn(globalPause));
	// control signals
	// memory control
	wire ExMe_inZero;
	wire ExMe_outZero;
	regDFF #(1) ExMe_Zero(.regQ(ExMe_outZero), .regD(ExMe_inZero), .clk(clk), .rst(rst), .writeEn(globalPause));
	wire ExMe_inMemRead;
	wire ExMe_outMemRead;
	regDFF #(1) ExMe_MemRead(.regQ(ExMe_outMemRead), .regD(ExMe_inMemRead), .clk(clk), .rst(rst), .writeEn(globalPause));
	wire ExMe_inMemWrite;
	wire ExMe_outMemWrite;
	regDFF #(1) ExMe_MemWrite(.regQ(ExMe_outMemWrite), .regD(ExMe_inMemWrite), .clk(clk), .rst(rst), .writeEn(globalPause));
	wire ExMe_inCreateDump;
	wire ExMe_outCreateDump;
	regDFF #(1) ExMe_CreateDump(.regQ(ExMe_outCreateDump), .regD(ExMe_inCreateDump), .clk(clk), .rst(rst), .writeEn(globalPause));
	// writeback control
	wire ExMe_inMemToReg;
	wire ExMe_outMemToReg;
	regDFF #(1) ExMe_MemToReg(.regQ(ExMe_outMemToReg), .regD(ExMe_inMemToReg), .clk(clk), .rst(rst), .writeEn(globalPause));
	wire [2:0] ExMe_inWriteRegAddr;
	wire [2:0] ExMe_outWriteRegAddr;
	regDFF #(3) ExMe_WriteRegAddr(.regQ(ExMe_outWriteRegAddr), .regD(ExMe_inWriteRegAddr), .clk(clk), .rst(rst), .writeEn(globalPause));
	wire ExMe_inWriteEn;
	wire ExMe_outWriteEn;
	regDFF #(1) ExMe_WriteEn(.regQ(ExMe_outWriteEn), .regD(ExMe_inWriteEn), .clk(clk), .rst(rst), .writeEn(globalPause));
	wire ExMe_inHalt;
	wire ExMe_outHalt;
	regDFF #(1) ExMe_Halt(.regQ(ExMe_outHalt), .regD(ExMe_inHalt), .clk(clk), .rst(rst), .writeEn(globalPause));

	// for memory
		// inputs
	//wire [15:0] resultExMem;
	//wire [15:0] reg2ExMem;	
		// outputs
	//wire [15:0] resultMemWB;
		// control
	//reg DeEx_inMemRead, DeEx_inMemWrite, DeEx_inCreateDump;
	//This tracks when we have an incoming branch during a stall
        wire savedbranchflushout;
 	wire flush = ExMe_inPCSrc2 ? 1'b1 : (FeDone ? 1'b0 : savedbranchflushout);
	regDFF #(1) fetchbranchsavedflush(.regQ(savedbranchflushout), .regD(flush & FeStall), .clk(clk), .rst(rst), .writeEn(1'b1));
		



//Me/Wb
	wire [15:0] MeWb_inReadData;
	wire [15:0] MeWb_outReadData;
	regDFF #(16) MeWb_ReadData(.regQ(MeWb_outReadData), .regD(MeWb_inReadData), .clk(clk), .rst(rst), .writeEn(globalPause));
	wire [15:0] MeWb_inResult;
	wire [15:0] MeWb_outResult;
	regDFF #(16) MeWb_Result(.regQ(MeWb_outResult), .regD(MeWb_inResult), .clk(clk), .rst(rst), .writeEn(globalPause));
	// control signals
	wire MeWb_inMemToReg;
	wire MeWb_outMemToReg;
	regDFF #(1) MeWb_MemToReg(.regQ(MeWb_outMemToReg), .regD(MeWb_inMemToReg), .clk(clk), .rst(rst), .writeEn(globalPause));
	wire [2:0] MeWb_inWriteRegAddr;
	wire [2:0] MeWb_outWriteRegAddr;
	regDFF #(3) MeWb_WriteRegAddr(.regQ(MeWb_outWriteRegAddr), .regD(MeWb_inWriteRegAddr), .clk(clk), .rst(rst), .writeEn(globalPause));
	wire MeWb_inWriteEn;
	wire MeWb_outWriteEn;
	regDFF #(1) MeWb_WriteEn(.regQ(MeWb_outWriteEn), .regD(MeWb_inWriteEn), .clk(clk), .rst(rst), .writeEn(globalPause));
	wire MeWb_inHalt;
	wire MeWb_outHalt;
	regDFF #(1) MeWb_Halt(.regQ(MeWb_outHalt), .regD(MeWb_inHalt), .clk(clk), .rst(rst), .writeEn(globalPause));

	
	// for wb
		// inputs
	//wire [15:0] readData;
	//wire [15:0] result;
		// outputs
	wire [15:0] regWriteData;
		// control
	//reg DeEx_inMemToReg;

	// instantiate submodules
	fetch fetchStage(.nextAddr(PCinput), .nextInstrAddr(FeDe_inAddr), .instr(FeDe_inInstr), .err(fetchErr), 
.clk(clk), .rst(rst), .halt(delay), .Done(FeDone), .Stall(FeStall), .flush(ExMe_inPCSrc2), .savedflush(savedbranchflushout));
	
	decode decodeStage(.instr(IDOutput), .regWriteData(regWriteData), .writeRegAddrIn(MeWb_outWriteRegAddr), 
.writeRegAddrOut(DeEx_inWriteRegAddr), .writeEn(MeWb_outWriteEn), .nextInstrIn(FeDe_outAddr), .nextInstrOut(DeEx_inNextInstrAddr), 
.reg1Data(DeEx_inReg1), .reg2Data(DeEx_inReg2), .exImm(DeEx_inExImm), .dstReg(dstReg), .sizeslc(sizeslc), .extslc(extslc), .err(decodeErr), 
.clk(clk), .rst(rst));
	
	execute executeStage(.err(executeErr), .clk(clk), .rst(rst), .nextInstrAddr(DeEx_outNextInstrAddr), 
.reg1(ExInput1), .reg2In(ExInput2), 
.exImm(DeEx_outExImm), .nextAddr(ExMe_inNextAddr), .result(ExMe_inResult), .reg2Out(ExMe_inReg2), .cmp(DeEx_outCmp), 
.cmpRsltCode(DeEx_outCmpRsltCode), .PCsrc1(DeEx_outPCSrc1), .PCSrc2Code(DeEx_outPCSrc2Code), .PCSrc2(ExMe_inPCSrc2),
.ALUsrc1(DeEx_outALUSrc1), .ALUsrc2(DeEx_outALUSrc2), 
.ALUcntrl(DeEx_outALUCtrl), .memAddrSrc(DeEx_outMemAddrSrc), .ALUCin(DeEx_outALUCin), .invA(DeEx_outInvA), .invB(DeEx_outInvB), .sign(DeEx_outSign), 
.zero(ExMe_inZero), .ofl(ofl), .ALUOutput15(ALUOutput15));
	
	memory memoryStage(.err(memoryErr), .clk(clk), .rst(rst), .resultIn(ExMe_outResult), .resultOut(MeWb_inResult), .reg2(ExMe_outReg2), 
.readData(MeWb_inReadData), .memRead(ExMe_outMemRead), .memWrite(ExMe_outMemWrite), .createdump(ExMe_outCreateDump), .Done(MeDone), .Stall(MeStall));
	
	wb wbStage(.err(wbErr), .clk(clk), .rst(rst), .readData(MeWb_outReadData), .result(MeWb_outResult), .memToReg(MeWb_outMemToReg), .regWriteData(regWriteData));

	// control logic:
	assign PCinput = ExMe_inPCSrc2 ? ExMe_inNextAddr : FeDe_inAddr;

	// forward logic:
	assign DeEx_inRs = IDOutput[10:8];
	assign DeEx_inRt = IDOutput[7:5];
	assign ExMe_inWriteRegAddr = DeEx_outWriteRegAddr;
	assign MeWb_inWriteRegAddr = ExMe_outWriteRegAddr;
	assign ExMe_inWriteEn = DeEx_outWriteEn;
	assign MeWb_inWriteEn = ExMe_outWriteEn;
	assign ExMe_inMemToReg = DeEx_outMemToReg;
	assign MeWb_inMemToReg = ExMe_outMemToReg;
	assign ExMe_inMemRead = DeEx_outMemRead;
	assign MeWb_inMemRead = ExMe_outMemRead;
	assign ExMe_inMemWrite = DeEx_outMemWrite;
	assign MeWb_inMemWrite = ExMe_outMemWrite;
	assign ExMe_inCreateDump = DeEx_outCreateDump;
	assign ExMe_inHalt = DeEx_outHalt;
	assign MeWb_inHalt = ExMe_outHalt;
	// Ex->Ex forwarding ? result at ExMem : [Mem->Ex forwarding ? result at MemWb (which is just wb's result) : regular decode registers]
	assign ExInput1 = ((DeEx_outRs==ExMe_outWriteRegAddr) & ExMe_outWriteEn) ? 
			ExMe_outResult : (((DeEx_outRs==MeWb_outWriteRegAddr) & MeWb_outWriteEn) ? regWriteData : DeEx_outReg1);
	assign ExInput2 = ((DeEx_outRt==ExMe_outWriteRegAddr) & ExMe_outWriteEn) ? 
			ExMe_outResult : (((DeEx_outRt==MeWb_outWriteRegAddr) & MeWb_outWriteEn) ? regWriteData : DeEx_outReg2);

	// predicting/stalling
	assign ExMe_inBranchOrJump = DeEx_outBranchOrJump;
	
	
	assign IDOutput = (rst | ExMe_inPCSrc2 | savedbranchflushout /*| ~FeDone*/) ? 16'b0000100000000000 : FeDe_outInstr;
 	assign IFInput = (rst | ExMe_inPCSrc2  | FeStall | savedbranchflushout | (DeEx_inMemRead & DeEx_inWriteEn)) ? 16'b0000100000000000 : FeDe_inInstr;

	// stalling logic
	assign delay = MeStall | FeStall | (valid & DeEx_inHalt) | (DeEx_inMemRead & DeEx_inWriteEn);

	// flushing logic
	// whenever ExMe_inPCSrc2 is high, we have to flush what is in Fetch and Decode

	always @(*) begin
		// defaults for control is all off/0
		// decode
		dstReg = 2'd0;	
		sizeslc = 2'd0;
		extslc = 1'b0;
		DeEx_inWriteEn = 1'b0;
		// execute
		DeEx_inALUSrc1 = 2'd0;
		DeEx_inALUSrc2 = 2'd0;
		DeEx_inALUCtrl = 3'd0;
		DeEx_inMemAddrSrc = 1'b0;
		DeEx_inPCSrc1 = 1'b0;
		//DeEx_inPCSrc2 = 1'b0;
		DeEx_inCmp = 1'b0;
		DeEx_inALUCin = 1'b0;
		DeEx_inInvA = 1'b0;
		DeEx_inInvB = 1'b0;
		DeEx_inSign = 1'b0;
		DeEx_inPCSrc2Code = 3'd0;
		DeEx_inCmpRsltCode = 2'd0;
		// memory
		DeEx_inMemRead = 1'b0;
		DeEx_inMemWrite = 1'b0;
		DeEx_inCreateDump = 1'b0;
		// writeback
		DeEx_inMemToReg = 1'b0;
		DeEx_inBranchOrJump = 1'b0;
		DeEx_inHalt = 1'b0;

		casex(IDOutput)
			`HALT: begin
				DeEx_inHalt = valid;
				DeEx_inCreateDump = valid;
				end
			`NOP: begin
				//TODO
				end
			`RTI: begin
				//TODO - Treat as a NOP until implemented
				end
			`ADDI: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				dstReg = 2'd1;
				extslc = 1'b1;
				DeEx_inALUSrc2 = 2'd1;
				DeEx_inALUCtrl = 3'd4;
				end
			`SUBI: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				dstReg = 2'd1;
				extslc = 1'b1;
				DeEx_inALUSrc2 = 2'd1;
				DeEx_inALUCtrl = 3'd4;
				DeEx_inALUCin = 1'b1;
				DeEx_inInvA = 1'b1;
				DeEx_inSign = 1'b1;
				end
			`XORI: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				dstReg = 2'd1;
				DeEx_inALUSrc2 = 2'd1;
				DeEx_inALUCtrl = 3'd7;
				end
			`ANDNI: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				dstReg = 2'd1;
				DeEx_inALUSrc2 = 2'd1;
				DeEx_inALUCtrl = 3'd5;
				DeEx_inInvB = 1'b1;
				end
			`ROLI: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				dstReg = 2'd1;
				DeEx_inALUSrc2 = 2'd1;
				end
			`SLLI: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				dstReg = 2'd1;
				DeEx_inALUSrc2 = 1'b1;
				DeEx_inALUCtrl = 3'd1;
				end
			`RORI: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				dstReg = 2'd1;
				DeEx_inALUSrc2 = 1'b1;
				DeEx_inALUCtrl = 3'd2;
				end
			`SRLI: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				dstReg = 2'd1;
				DeEx_inALUSrc2 = 1'b1;
				DeEx_inALUCtrl = 3'd3;
				end
			`ST: begin
				extslc = 1'b1;
				DeEx_inALUSrc2 = 2'd1;
				DeEx_inALUCtrl = 3'd4;
				DeEx_inMemWrite = (ExMe_inPCSrc2 | DeEx_outHalt) ? 1'b0 : 1'b1;
				end
			`LD: begin	
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				dstReg = 2'd1;
				extslc = 1'b1;
				DeEx_inALUSrc2 = 2'd1;
				DeEx_inALUCtrl = 3'd4;
				DeEx_inMemRead = 1'b1;
				DeEx_inMemToReg = 1'b1;
				end
			`STU: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				dstReg = 2'd2;
				extslc = 1'b1;
				DeEx_inALUSrc2 = 2'd1;
			 	DeEx_inALUCtrl = 3'd4;
				DeEx_inMemWrite = (ExMe_inPCSrc2 | DeEx_outHalt) ? 1'b0 : 1'b1;
			end
			`BTR: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				DeEx_inALUSrc1 = 2'd2;
				DeEx_inALUSrc2 = 2'd3;
				DeEx_inALUCtrl = 3'd6;
			end
			`ADD: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				DeEx_inALUCtrl = 3'd4;
				DeEx_inSign = 1'b1;
			end
			`SUB: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				DeEx_inALUCtrl = 3'd4;
				DeEx_inALUCin = 1'b1;
				DeEx_inInvA = 1'b1;
				DeEx_inSign = 1'b1;
			end
			`XOR: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				DeEx_inALUCtrl = 3'd7;
			end
			`ANDN: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				DeEx_inALUCtrl = 3'd5;
				DeEx_inInvB = 1'b1;
			end
			`ROL: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
			end
			`SLL: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				DeEx_inALUCtrl = 3'd1;
			end
			`ROR: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				DeEx_inALUCtrl = 3'd2;
			end
			`SRL: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				DeEx_inALUCtrl = 3'd3;
			end
			`SEQ: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				//do logic for cmpRslt
				DeEx_inCmp = 1'b1;
				DeEx_inCmpRsltCode = 2'd0;
				//cmpRslt = zero;
				DeEx_inALUCtrl = 3'd4;
				DeEx_inALUCin = 1'b1;
				DeEx_inInvB = 1'b1;
				DeEx_inSign = 1'b1;
			end
			`SLT: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				//do logic for cmpRslt
				DeEx_inCmp = 1'b1;
				DeEx_inCmpRsltCode = 2'd1;
				//cmpRslt = ofl^ALUOutput15;
				DeEx_inALUCtrl = 3'd4;
				DeEx_inALUCin = 1'b1;
				DeEx_inInvB = 1'b1;
				DeEx_inSign = 1'b1;
			end
			`SLE: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				//do logic for cmpRslt
				DeEx_inCmpRsltCode = 2'd2;
				//cmpRslt = (ofl^ALUOutput15) | zero;
				DeEx_inCmp = 1'b1;
				DeEx_inALUCtrl = 3'd4;
				DeEx_inALUCin = 1'b1;
				DeEx_inInvB = 1'b1;
				DeEx_inSign = 1'b1;
			end
			`SCO: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				//do logic
				DeEx_inCmp = 1'b1;
				DeEx_inCmpRsltCode = 2'd3;
				//cmpRslt = ofl;
				DeEx_inALUCtrl = 3'd4;
			end
			`BEQZ: begin
				sizeslc = 2'b1;
				extslc = 1'b1; 
				//do logic for DeEx_inPCSrc2
				DeEx_inPCSrc2Code = 3'd1;
				//DeEx_inPCSrc2 = zero;
				DeEx_inALUSrc2 = 2'd3;
				DeEx_inALUCtrl = 3'd6;
				DeEx_inBranchOrJump = 1'b1;
			end
			`BNEZ: begin
				sizeslc = 2'b1;
				extslc = 1'b1;
				//do DeEx_inPCSrc2
				DeEx_inPCSrc2Code = 3'd2;
				//DeEx_inPCSrc2 = ~zero;
				DeEx_inALUSrc2 = 2'd3;
				DeEx_inALUCtrl = 3'd6;
				DeEx_inBranchOrJump = 1'b1;
			end
			`BLTZ: begin
				sizeslc = 2'd1;
				extslc = 1'b1;
				//do DeEx_inPCSrc2				
				DeEx_inPCSrc2Code = 3'd3;
				//DeEx_inPCSrc2 = ALUOutput15;
				DeEx_inALUSrc2 = 2'd3;
				DeEx_inALUCtrl = 3'd6;
				DeEx_inBranchOrJump = 1'b1;
			end
			`BGEZ: begin
				sizeslc = 2'd1;
				extslc = 1'b1; 
				//do DeEx_inPCSrc2				
				DeEx_inPCSrc2Code = 3'd4;
				//DeEx_inPCSrc2 = ~ALUOutput15;
				DeEx_inALUSrc2 = 2'd3;
				DeEx_inALUCtrl = 3'd6;
				DeEx_inBranchOrJump = 1'b1;
			end
			`LBI: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				dstReg = 2'd2;
				sizeslc = 2'd1;
				extslc = 1'b1;
				DeEx_inALUSrc1 = 2'd3;
				DeEx_inALUSrc2 = 2'd1;
				DeEx_inALUCtrl = 3'd6;
			end
			`SLBI: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				dstReg = 2'd2;
				sizeslc = 2'd1;
				DeEx_inALUSrc1 = 2'd1;
				DeEx_inALUSrc2 = 2'd1;
				DeEx_inALUCtrl = 3'd6;
			end
			`J: begin
				sizeslc = 2'd2;
				extslc = 1'b1;
				//DeEx_inPCSrc2 = 1'b1;				
				DeEx_inPCSrc2Code = 3'd5;
				DeEx_inBranchOrJump = 1'b1;
			end
			`JR: begin
				sizeslc = 2'd1;
				extslc = 1'b1;
				DeEx_inPCSrc1 = 1'b1;
				DeEx_inALUSrc2 = 2'd1;
				DeEx_inALUCtrl = 3'd4;				
				DeEx_inPCSrc2Code = 3'd5;
				DeEx_inBranchOrJump = 1'b1;
			end
			`JAL: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				dstReg = 2'd3;
				sizeslc = 2'd2;
				extslc = 1'b1;
				//DeEx_inPCSrc1 = 1'b1; old PCSrc1 version				
				DeEx_inPCSrc2Code = 3'd5;
				//DeEx_inPCSrc2 = 1'b1;
				DeEx_inMemAddrSrc = 1'b1;
				DeEx_inBranchOrJump = 1'b1;
			end
			`JALR: begin
				DeEx_inWriteEn = ExMe_inPCSrc2 ? 1'b0 : 1'b1;
				dstReg = 2'd3;
				sizeslc = 2'd1;
				extslc = 1'b1;
				DeEx_inPCSrc1 = 1'b1;				
				DeEx_inPCSrc2Code = 3'd5;
				DeEx_inALUSrc2 = 2'd1;
				DeEx_inALUCtrl = 3'd4;
				DeEx_inMemAddrSrc = 1'b1;
				DeEx_inBranchOrJump = 1'b1;
			end
			default: begin
				// keep all at 0 for clear error
				end
		endcase
	end
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:

