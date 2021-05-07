// FIFO Testbench

module FPUMAC_tb();
	parameter COL_WIDTH = 10;

	// Clock
	logic clk;
	logic rst_n;

	logic [7:0] col0 [COL_WIDTH-1:0];
	logic [7:0] col1 [COL_WIDTH-1:0];
	logic [7:0] col2 [COL_WIDTH-1:0];
	logic signed [7:0] filter [8:0];
	logic [7:0] result_pixels [COL_WIDTH-3:0];

 	logic [7:0] [COL_WIDTH-3:0] expected_result_pixels[4:0]; 

	always #5 clk = ~clk; 

	int errors, i, j, k;
	
	FPUMAC mac(.*);

	initial begin
		clk = 1'b0;
		rst_n = 1'b0;
		errors = 0;

		@(posedge clk);
		rst_n = 1'b1;
	
		#1
		for(i = 0; i < COL_WIDTH-2; i++)begin
			if( result_pixels[i] !== 0 ) begin
				errors++;
				$display("Error, reset fail. Expected: %d, Got: %d", 0, result_pixels[i]);
			end
		end

		//unconstrained random testing
		for(i = 0; i < 1000; i++) begin	
			for(j = 0; j < COL_WIDTH; j++) begin
				col0[j] = $random();
				col1[j] = $random();
				col2[j] = $random();
			end

			for(j = 0; j < 9; j++) begin
				filter[j] = $random();
			end
			
			for(j = 4; j>0; j--)begin
				for(k = 0; k < COL_WIDTH-2; k++) begin
					expected_result_pixels[j][k] = expected_result_pixels[j-1][k];
				end
			end

			for(j = 0; j < COL_WIDTH-2; j++)begin
				expected_result_pixels[0][j] = calc_MAC(assemble(col0, col1, col2, j), filter);
			end

			@(posedge clk)
			if(i > 4)begin
				#1
				for(j = 0; j < COL_WIDTH-2; j++) begin
					if(expected_result_pixels[4][j] !== result_pixels[j])begin
						errors++;
						$display("Error, incorrect value recorded. Expected: %d, Got: %d", expected_result_pixels[4][j], result_pixels[j]);
					end
				end
			end
		end

		//contrained random testing, filter values limited to [-1, 0, 1]
		for(i = 0; i < 1000; i++) begin	
			for(j = 0; j < COL_WIDTH; j++) begin
				col0[j] = $random();
				col1[j] = $random();
				col2[j] = $random();
			end

			for(j = 0; j < 9; j++) begin
				filter[j] = $urandom_range(0,2)-1;
			end
			
			for(j = 4; j>0; j--)begin
				for(k = 0; k < COL_WIDTH-2; k++) begin
					expected_result_pixels[j][k] = expected_result_pixels[j-1][k];
				end
			end

			for(j = 0; j < COL_WIDTH-2; j++)begin
				expected_result_pixels[0][j] = calc_MAC(assemble(col0, col1, col2, j), filter);
			end

			@(posedge clk)
			#1
			for(j = 0; j < COL_WIDTH-2; j++) begin
				if(expected_result_pixels[4][j] !== result_pixels[j])begin
					errors++;
					$display("Error, incorrect value recorded. Expected: %d, Got: %d", expected_result_pixels[4][j], result_pixels[j]);
				end
			end
		end

		$display("Errors: %d", errors);

		if(!errors) begin
			$display("YAHOO!!! All tests passed.");
		end
		else begin
			$display("ARRRR!  Ye codes be blast! Aye, there be errors. Get debugging!");
		end

		$stop;

	end

	function automatic [7:0] calc_MAC(input[7:0] array0 [8:0], input signed [7:0] array1 [8:0]);
		int sum = 0;
		for(int i = 0; i < 9; i++)begin
			sum += signed'({1'b0, array0[i]}) * array1[i];
		end
		if(sum < 0)
			return 0;
		else if (sum > 255)
			return 255;
		return sum;
	endfunction


	typedef logic [7:0]test_def[8:0];
	function automatic test_def assemble(input [7:0] col0 [COL_WIDTH-1:0], input [7:0] col1 [COL_WIDTH-1:0], input [7:0] col2 [COL_WIDTH-1:0], input int index);
		assemble = {col0[index  ], col1[index  ], col2[index  ],
			    col0[index+1], col1[index+1], col2[index+1],
		            col0[index+2], col1[index+2], col2[index+2] };
		return {<<8{assemble}};	
	endfunction


endmodule
