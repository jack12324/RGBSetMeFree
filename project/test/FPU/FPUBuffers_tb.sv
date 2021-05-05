module FPUBuffers_tb();
	parameter COL_WIDTH = 10;

	logic clk, rst_n, shift_rows;
	logic [7:0] col_new [COL_WIDTH - 1:0];
	logic [7:0] col0 [COL_WIDTH - 1:0];
	logic [7:0] col1 [COL_WIDTH - 1:0];
	logic [7:0] col2 [COL_WIDTH - 1:0];

	logic [7:0] expectedCol0 [COL_WIDTH - 1:0];
	logic [7:0] expectedCol1 [COL_WIDTH - 1:0];
	logic [7:0] expectedCol2 [COL_WIDTH - 1:0];	

	always #5 clk = ~clk; 

	int errors, i, j;
	
	FPUBuffers buffers(.*);

	initial begin
		clk = 1'b0;
		rst_n = 1'b0;
		errors = 0;

		@(posedge clk);
		rst_n = 1'b1;
	
		#1
		for(i = 0; i < COL_WIDTH; i++)begin
			if( col0[i] !== 0 ) begin
				errors++;
				$display("Error, col0 byte %d reset fail. Expected: %d, Got: %d", i, 0, col0[i]);
			end
			if( col1[i] !== 0 ) begin
				errors++;
				$display("Error, col1 byte %d reset fail. Expected: %d, Got: %d", i, 0, col1[i]);
			end
			if( col2[i] !== 0 ) begin
				errors++;
				$display("Error, col2 byte %d reset fail. Expected: %d, Got: %d", i, 0, col2[i]);
			end
		end

		//unconstrained random testing
		for(i = 0; i < 1000; i++) begin	
			for(j = 0; j < COL_WIDTH; j++) begin
				col_new[j] = $random();
			end

			shift_rows = $random();

			expectedCol0 = shift_rows ? col1 : col0;
			expectedCol1 = shift_rows ? col2 : col1;
			expectedCol2 = shift_rows ? col_new : col2;

			@(posedge clk)
			#1

			//separate outer for loops so that error output is grouped by column not byte
			for(j = 0; j < COL_WIDTH; j++) begin
				if(expectedCol0[j] !== col0[j])begin
					errors++;
					$display("Error, incorrect value recorded in col0 byte %d. Expected: %d, Got: %d", j, expectedCol0[j], col0[j]);
				end
			end
			for(j = 0; j < COL_WIDTH; j++) begin
				if(expectedCol1[j] !== col1[j])begin
					errors++;
					$display("Error, incorrect value recorded in col1 byte %d. Expected: %d, Got: %d", j, expectedCol1[j], col1[j]);
				end
			end
			for(j = 0; j < COL_WIDTH; j++) begin
				if(expectedCol2[j] !== col2[j])begin
					errors++;
					$display("Error, incorrect value recorded in col2 byte %d. Expected: %d, Got: %d", j, expectedCol2[j], col2[j]);
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
endmodule
