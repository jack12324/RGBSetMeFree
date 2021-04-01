// FIFO Testbench

module tpumac_tb();

	// Clock
	logic clk;
	logic rst_n;
	logic en;
	logic WrEn;
	logic signed [7:0] Ain, Bin, Aout, Bout, expected_a, expected_b;
	logic signed [15:0] Cin, Cout, expected_c;

	always #5 clk = ~clk; 

	integer errors, i;

	tpumac tpumac(.clk(clk), .rst_n(rst_n), .WrEn(WrEn), .en(en), .Ain(Ain), .Bin(Bin), .Cin(Cin), .Aout(Aout), .Bout(Bout), .Cout(Cout));

	initial begin
		clk = 1'b0;
		rst_n = 1'b0;
		en = 1'b0;
		errors = 0;

		// Load stimulti for our DUT
		@(posedge clk);
		rst_n = 1'b1;
		en = 1'b1;
		WrEn = 1'b0;
	
		//check reset values	
		#1
		if( Aout !== 0 ) begin
			errors++;
			$display("Error, reset fail. Expected: %d, Got: %d", 0, Aout);
		end
		
		if( Bout !== 0 ) begin
			errors++;
			$display("Error, reset fail. Expected: %d, Got: %d", 0, Bout);
		end
		if( Cout !== 0) begin
			errors++;
			$display("Error, reset fail. Expected: %d, Got: %d", 0, Cout);
		end


		//test mac with 1000 random Ain and Bin vectors	
		for(i = 0; i < 1000; i++) begin	

			Ain = $random();
			Bin = $random();
			Cin = $random();

			expected_c = (Ain * Bin) + Cout;
			expected_a = Ain;
			expected_b = Bin;

			@(posedge clk)
			#1
			if( Aout !== expected_a ) begin
				errors++;
				$display("Error, incorrect value recorded. Expected: %d, Got: %d", expected_a, Aout);
			end
			
			if( Bout !== expected_b ) begin
				errors++;
				$display("Error, incorrect value recorded. Expected: %d, Got: %d", expected_b, Bout);
			end
			
			if( Cout !== expected_c ) begin
				errors++;
				$display("Error, incorrect value recorded. Expected: %d, Got: %d", expected_c, Cout);
			end
		end
		
		//repeat test with randomized WrEn. WrEn should set Cout to Cin
		for(i = 0; i < 1000; i++) begin	

			Ain = $random();
			Bin = $random();
			Cin = $random();
			WrEn = $random();

			expected_c = WrEn ? Cin : (Ain * Bin) + Cout;
			expected_a = Ain;
			expected_b = Bin;

			@(posedge clk)
			#1
			if( Aout !== expected_a ) begin
				errors++;
				$display("Error, incorrect value recorded. Expected: %d, Got: %d", expected_a, Aout);
			end
			
			if( Bout !== expected_b ) begin
				errors++;
				$display("Error, incorrect value recorded. Expected: %d, Got: %d", expected_b, Bout);
			end
			
			if( Cout !== expected_c ) begin
				errors++;
				$display("Error, incorrect value recorded. Expected: %d, Got: %d", expected_c, Cout);
			end
		end

		//repeat test with randomized en. If en is not asserted then out values should hold 
		for(i = 0; i < 1000; i++) begin	

			Ain = $random();
			Bin = $random();
			Cin = $random();
			WrEn = $random();
			en = $random();

			expected_c = en ? (WrEn ? Cin : (Ain * Bin) + Cout) : Cout;
			expected_a = en ? Ain : Aout;
			expected_b = en ? Bin : Bout;

			@(posedge clk)
			#1
			if( Aout !== expected_a ) begin
				errors++;
				$display("Error, incorrect value recorded. Expected: %d, Got: %d", expected_a, Aout);
			end
			
			if( Bout !== expected_b ) begin
				errors++;
				$display("Error, incorrect value recorded. Expected: %d, Got: %d", expected_b, Bout);
			end
			
			if( Cout !== expected_c ) begin
				errors++;
				$display("Error, incorrect value recorded. Expected: %d, Got: %d", expected_c, Cout);
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
