module tpumac
	#(
	  parameter BITS_AB = 8,
  	  parameter BITS_C = 16
	)
	(
	 input clk, rst_n, WrEn, en,
	 input signed [BITS_AB-1:0] Ain,
	 input signed [BITS_AB-1:0] Bin,
	 input signed [BITS_C-1:0]  Cin,
	 output reg signed [BITS_AB-1:0] Aout,
	 output reg signed [BITS_AB-1:0] Bout,
	 output reg signed [BITS_C-1:0]  Cout
	);
	
	logic [(BITS_AB * 2) - 1:0] mult_res;
	logic [BITS_C - 1:0] Cval;

	assign mult_res = Ain * Bin; 
	assign Cval = WrEn ? Cin : mult_res + Cout;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			Aout <= 0;
			Bout <= 0;
			Cout <= 0;
		end
		else begin
			if(en) begin
				Aout <= Ain;
				Bout <= Bin;
				Cout <= Cval;
			end
			else if (WrEn)begin
				Cout <= Cin;
			end
		end
	end
endmodule
 
