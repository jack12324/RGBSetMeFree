/*
    CS/ECE 552 Spring '20
    Homework #2, Problem 2

    A 16-bit ALU module.  It is designed to choose
    the correct operation to perform on 2 16-bit numbers from rotate
    left, shift left, shift right arithmetic, shift right logical, add,
    or, xor, & and.  Upon doing this, it should output the 16-bit result
    of the operation, as well as output a Zero bit and an Overflow
    (OFL) bit.
*/
module alu (InA, InB, Cin, Op, invA, invB, sign, Out, Zero, Ofl);

   // declare constant for size of inputs and outputs (N)
   parameter    N = 16;
   parameter 	O = 3;

   input [N-1:0] InA;
   input [N-1:0] InB;
   input         Cin;
   input [O-1:0] Op;
   input         invA;
   input         invB;
   input         sign;
   output reg [N-1:0] Out;
   output wire        Ofl;
   output wire       Zero;

	// simple 2-to-1 mux for this top level to choose between barrel shifter and logical operations
	wire [N-1:0] out0, out1;
	// we also handle inverting on this top level
	wire [N-1:0] inverseA, inverseB;
	assign inverseA = ~InA;
	assign inverseB = ~InB;
	reg [N-1:0] activeA, activeB;
		
	// instantiate submodules
 	shifter msbOp0(.In(activeA), .Cnt(activeB[3:0]), .Op(Op[1:0]), .Out(out0));
	logical msbOp1(.InA(activeA), .InB(activeB), .Cin(Cin), .Op(Op[1:0]), .sign(sign), .Out(out1), .Ofl(Ofl));

	always @* begin	
		// set outputs by mux choice
		case(Op[2])
			1'b0: Out = out0;
			1'b1: Out = out1;
			default: Out = 16'b0; // error
		endcase
	end
	always @* begin	
		// invert A mux
		case (invA) 
			1'b0: activeA = InA;
			1'b1: activeA = inverseA;
			default: activeA = 16'b0; // error
		endcase
	end
	always @* begin	
		// invert B mux
		case (invB)
			1'b0: activeB = InB;
			1'b1: activeB = inverseB;
			default: activeB = 16'b0; // error
		endcase		
	end

	// handle things equaling 0
	assign Zero = ~(|Out);

endmodule
