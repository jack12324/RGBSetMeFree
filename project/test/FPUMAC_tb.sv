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

	always #5 clk = ~clk; 

	int errors, i, j, expected_result_pixels;
	
	FPUMAC mac(.*);

	initial begin
		clk = 1'b0;
		rst_n = 1'b0;
		errors = 0;

		@(posedge clk);
		rst_n = 1'b1;
	
		#1
		for(i = 0; i < COL_WIDTH-3; i++)begin
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

			for(j = 0; j < COL_WIDTH-3; j++)begin
				expected_result_pixels[j] = calc_MAC({col0[j+2:j], col1[j+2:j], col2[j+2:j]}, filter);
			end

			@(posedge clk)
			#1
			for(j = 0; j < COL_WIDTH-3; j++) begin
				errors++;
				$display("Error, incorrect value recorded. Expected: %d, Got: %d", expected_result_pixels[j], result_pixels[j]);
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

	function int calc_MAC(input[7:0] array0 [8:0], input signed [7:0] array1 [8:0]);
		calc_MAC = 0;
		for(int i = 0; i < 9; i++)begin
			calc_MAC += signed'({1'b0, array0[i]}) * array1[i];
		end
		if(calc_MAC< 0)
			calc_MAC = 0;
		else if (calc_MAC > 255)
			calc_MAC = 255;
	endfunction

endmodule
