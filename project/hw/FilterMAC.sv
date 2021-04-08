module FilterMAC (clk, rst_n, array1, array0, result_pixel);
	input clk, rst_n;
	input [7:0] array0 [8:0];
	input signed [7:0] array1 [8:0];
	output [7:0] result_pixel;

	logic signed [8:0] array0_signed [8:0];
	logic signed [15:0] mult_res [8:0];
	logic signed [19:0] add_res;
	
	assign array0_signed = array0;

	always_ff @(posedge clk, negedge rst_n)begin
		if(!rst_n)begin
			result_pixel <= 0;
		end
		else begin
			add_res[19] == 1'b1 ? 0 : |add_res[18:8] ? 8'hFF : add_res[7:0];
		end
	end

	always_comb begin
		for(int i = 0; i < 8; i++)begin
			mult_res[i] = array0_signed[i] * array1[i];
		end
	end
	assign add_res = mult_res[0] + mult_res[1] + mult_res[2] + mult_res[3] + mult_res[4] + mult_res[5] + mult_res[6] + mult_res[7];
	
endmodule
