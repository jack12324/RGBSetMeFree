module FilterMAC (clk, rst_n, array1, array0, result_pixel);
	input clk, rst_n;
	input [7:0] array0 [8:0];
	input signed [7:0] array1 [8:0];
	output reg [7:0] result_pixel;

	logic signed [8:0] array0_signed [8:0];
	logic signed [15:0] mult_res_comb [8:0];
	logic signed [15:0] mult_res [8:0];
	logic signed [19:0] add_res1, add_res2, add_res3, add_res4, add_res5, add_res6, add_res7;

	always_ff @(posedge clk, negedge rst_n)begin
		if(!rst_n)begin
			result_pixel <= 0;
			for(int i = 0; i < 9; i++)
				mult_res[i] <= '0;
			add_res1 <= '0;
			add_res2 <= '0;
			add_res3 <= '0;
			add_res4 <= '0;
			add_res5 <= '0;
			add_res6 <= '0;
			add_res7 <= '0;
		end
		else begin
			result_pixel <= add_res7[19] ? 0 : |add_res7[18:8] ? 8'hFF : add_res7[7:0];
			for(int i = 0; i < 9; i++)
				mult_res[i] <= mult_res_comb[i];
			add_res1 <= mult_res[0] + mult_res[1];
			add_res2 <= mult_res[2] + mult_res[3];
			add_res3 <= mult_res[4] + mult_res[5];
			add_res4 <= mult_res[6] + mult_res[7] + mult_res[8];
	
			add_res5 <= add_res1 + add_res2;
			add_res6 <= add_res3 + add_res4;

			add_res7 <= add_res5 + add_res6;

		end
	end

	always_comb begin
		for(int i = 0; i < 9; i++)begin
			array0_signed[i] = array0[i];
			mult_res_comb[i] = array0_signed[i] * array1[i];
		end
	end

endmodule
