module FilterMAC_tb();

	// Clock
	logic clk;
	logic rst_n;

	logic [7:0] array0 [8:0];
	logic signed [7:0] array1 [8:0];
	logic signed [8:0] array0_signed [8:0];
	logic [7:0] result_pixel;

	int expected_result_pixel[4:0];

	always #5 clk = ~clk; 

	int errors, i, j, expected_sum;
	
	FilterMAC mac(.*);

	initial begin
		clk = 1'b0;
		rst_n = 1'b0;
		errors = 0;

		@(posedge clk);
		rst_n = 1'b1;
	
		#1
		if( result_pixel !== 0 ) begin
			errors++;
			$display("Error, reset fail. Expected: %d, Got: %d", 0, result_pixel);
		end

		//unconstrained random testing
		for(i = 0; i < 1000; i++) begin	
			expected_sum = 0;

			for(j = 0; j<9; j++) begin
				array0[j] = $random();
				array0_signed[j] = array0[j];
				array1[j] = $random();
			end
			
			for(j = 4; j>0; j--)begin
				expected_result_pixel[j] = expected_result_pixel[j-1];
			end

			for(j = 0; j<9; j++) begin
				expected_sum += (array0_signed[j] * array1[j]);
			end
			

			if(expected_sum <= 0)begin
				expected_result_pixel[0] = 0;
			end else if (expected_sum >= 255)begin
				expected_result_pixel[0] = 255;
			end else begin
				expected_result_pixel[0] = expected_sum;
			end
			
			@(posedge clk)
			if(i > 4)begin
				#1
				if(expected_result_pixel[4] !== result_pixel) begin
					errors++;
					$display("Error, incorrect value recorded. Expected: %d, Got: %d", expected_result_pixel[4], result_pixel);
				end
			end
		end

		//contrained random testing, filter values limited to [-1, 0, 1]
		for(i = 0; i < 1000; i++) begin	
			expected_sum = 0;

			for(j = 0; j<9; j++) begin
				array0[j] = $random();
				array0_signed[j] = array0[j];
				array1[j] = $urandom_range(0,2)-1;
			end
			
			for(j = 4; j>0; j--)begin
				expected_result_pixel[j] = expected_result_pixel[j-1];
			end


			for(j = 0; j<9; j++) begin
				expected_sum += (array0_signed[j] * array1[j]);
			end

			if(expected_sum <= 0)begin
				expected_result_pixel[0] = 0;
			end else if (expected_sum >= 255)begin
				expected_result_pixel[0] = 255;
			end else begin
				expected_result_pixel[0] = expected_sum;
			end
			
			@(posedge clk)
			#1
			if(expected_result_pixel[4] !== result_pixel) begin
				errors++;
				$display("Error, incorrect value recorded. Expected: %d, Got: %d", expected_result_pixel[4], result_pixel);
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

endmodule
