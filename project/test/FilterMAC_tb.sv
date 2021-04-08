// FIFO Testbench

module FilterMAC_tb();

	// Clock
	logic clk;
	logic rst_n;

	logic [7:0] array0 [8:0];
	logic signed [7:0] array1 [8:0];
	logic [7:0] result_pixel;

	always #5 clk = ~clk; 

	integer errors, i, j, expected_result_pixel;
	signed integer expected_sum;
	
	FilterMac mac(.*);

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

		for(i = 0; i < 1000; i++) begin	

			array0 = $random();
			array1 = $random();

			for(j = 0; j<8; j++) begin
				expected_sum += (array0[j] * array1[j]);
			end

			if(expected_sum <== 0)begin
				expected_result_pixel = 0;
			end else if (expected_sum >== 255)begin
				expected_result_pixel = 255;
			end else begin
				expected_result_pixel = expected_sum;
			end

			@(posedge clk)
			#1
			if(expected_result_pixel !== result_pixel) begin
				errors++;
				$display("Error, incorrect value recorded. Expected: %d, Got: %d", expected_result_pixel, result_pixel);
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
