module systolic_array
#(
  parameter BITS_AB=8,
  parameter BITS_C=16,
  parameter DIM=8
 )
 (
  input clk,rst_n,wrEn,en,
  input signed [BITS_AB-1:0] A [DIM-1:0],
  input signed [BITS_AB-1:0] B [DIM-1:0],
  input signed [BITS_C-1:0]  Cin [DIM-1:0],
  input [$clog2(DIM)-1:0]    Crow,
  output signed [BITS_C-1:0] Cout [DIM-1:0]
 );
  	logic signed [BITS_C-1:0] carr [DIM-1:0][DIM-1:0];
	logic signed [BITS_AB-1:0] Aouts [DIM-1:0][DIM:0];
	logic signed [BITS_AB-1:0] Bouts [DIM:0][DIM-1:0];
  	genvar row, col, i;
	generate
		for (row = 0; row < DIM; row++)begin
			for ( col = 0; col <DIM; col++)begin
				tpumac #(.BITS_AB(BITS_AB), .BITS_C(BITS_C)) mac (.Ain(Aouts[row][col]), .Bin(Bouts[row][col]), .Cin(Cin[col]), .Aout(Aouts[row][col+1]), .Bout(Bouts[row+1][col]), .Cout(carr[row][col]), .clk(clk), .rst_n(rst_n), .en(en), .WrEn(wrEn && (Crow === row)));
			end
		end
	for(i = 0; i<DIM; i++)begin
		assign Aouts[i][0] = A[i];
		assign Bouts[0][i] = B[i];
	end
	endgenerate
	assign Cout = carr[Crow];
endmodule

