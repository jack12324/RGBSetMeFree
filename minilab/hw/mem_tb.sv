`include "systolic_array_memory_tc.svh"

module mem_tb();

	localparam BITS_AB=8;
	localparam BITS_C=16;
	localparam DIM=8;
	localparam ROWBITS=$clog2(DIM);
	localparam B_TESTS=10;
	localparam A_TESTS=10;

	logic clk;
	logic rst_n;
	logic en_B;
	logic en_A;
	logic WrEn;
	
	logic signed [BITS_AB-1:0] Ain [DIM-1:0];
	logic [$clog2(DIM)-1:0] Arow;
	logic signed [BITS_AB-1:0] Aout [DIM-1:0];
	logic signed [BITS_AB-1:0] Bin [DIM-1:0];
	// logic [$clog2(DIM)-1:0] Brow;
	logic signed [BITS_AB-1:0] Bout [DIM-1:0];
	
	//Used for comparison
	logic [BITS_AB-1:0] A [DIM-1:0];
	logic [BITS_AB-1:0] B [DIM-1:0];
	
	always #5 clk = ~clk; 
	
	integer errors,mycycle;
	
	//Declare DUT(s)
	
	memA #(.BITS_AB(BITS_AB), .DIM(DIM)) Adut (.clk(clk), .rst_n(rst_n), .en(en_A), .WrEn(WrEn), .Ain(Ain), .Arow(Arow), .Aout(Aout));
	memB #(.BITS_AB(BITS_AB), .DIM(DIM)) Bdut (.clk(clk), .rst_n(rst_n), .en(en_B), .Bin(Bin), .Bout(Bout));
	
	systolic_array_memory_tc #(.BITS_AB(BITS_AB),
                       .DIM(DIM)
                       ) samtc;
				
	initial begin

		$info("Starting Testbench with %d Memory A tests and %d Memory B tests", A_TESTS, B_TESTS);
		if(A_TESTS == 0)begin
			$warning("A_TESTS are set to 0, no tests of Memory A will be run");
		end
		if(B_TESTS == 0)begin
			$warning("B_TESTS are set to 0, no tests of Memory B will be run");
		end

		clk = 1'b0;
		rst_n = 1'b1;
		en_A = 1'b0;
		en_B = 1'b0;
		WrEn = 1'b0;
		errors = 0;
		for(int rowcol=0;rowcol<DIM;++rowcol) begin
			A[rowcol] = {BITS_AB{1'b0}};
			B[rowcol] = {BITS_AB{1'b0}};
		end
	
		// reset and check Cout
		@(negedge clk) begin end
		rst_n = 1'b0; // active low reset
		@(negedge clk) begin end
		rst_n = 1'b1; // reset finished
		@(negedge clk) begin end
		
		//quick reset check
		for(int i = 0; i < DIM; i++) begin
			@(negedge clk);
			for(int j = 0; j < DIM; j++) begin
				if(A_TESTS !== 0 && Aout[j] !== 0) begin
					errors++;
					$display("Error! Reset was not conducted properly. Expected Aout: 0, Got: %d for Row %d Col %d", Aout[j], i, j); 
				end
			end
			for(int j = 0; j < DIM; j++) begin
				if(B_TESTS !== 0 && Bout[j] !== 0) begin
					errors++;
					$display("Error! Reset was not conducted properly. Expected Bout: 0, Got: %d for Row %d Col %d", Bout[j], i, j); 
				end
			end
		end
		
		//Seperate tests for A and B for log clarity
		for(int i = 0; i < A_TESTS; i++) begin
			samtc = new();

			//load A
			WrEn = 1'b1;
			en_A = 1'b0;
			for(int row = 0; row < DIM; row++) begin 
				Arow = row;
				for(int col = 0; col < DIM; col++)begin
					Ain[col] = samtc.A[row][col];
				end
				@(posedge clk) begin end
			end
			WrEn = 1'b0;
			
			@(posedge clk) begin end
			en_A = 1'b1; // enabled throughout following DIM*3 cycles      
			// DIM cycles to fill, DIM cycles to compute, DIM cycles to drain
			for(int cyc=0;cyc<(DIM*3-2);++cyc) begin
            			// set A values from the testcase
				for(int rowcol=0;rowcol<DIM;++rowcol) begin
					A[rowcol] = samtc.get_next_A(rowcol);
				end
				@(posedge clk) begin end
				//Check if shifted out vals match
				if(cyc > DIM-1 && cyc < 2*DIM) begin 
					for(int i = 0; i < DIM; i++) begin
						if(A[i] !== Aout[i]) begin
							errors++;
							$display("Error! Aout col %d incorrect. Expected Aout: %d, Got: %d for Row %d", cyc -DIM, A[i], Aout[i], i);
						end
					end
				end
				mycycle = samtc.next_cycle();
			end
			
			@(posedge clk) begin end
			// compute is done
			en_A = 1'b0;
			
		end

		for(int i = 0; i < B_TESTS; i++) begin
			samtc = new();

			//load B 
			en_B = 1'b1;
			for(int row = 0; row < DIM; row++) begin 
				for(int col = 0; col < DIM; col++)begin
					Bin[col] = samtc.B[row][col];
				end
				@(posedge clk) begin end
			end

			for(int col = 0; col < DIM; col++)begin
				Bin[col] = 0;
			end

			@(posedge clk) begin end
			// DIM cycles to fill, DIM cycles to compute, DIM cycles to drain
			for(int cyc=0;cyc<(DIM*3-2);++cyc) begin
            			// set B expected values from the testcase
				for(int rowcol=0;rowcol<DIM;++rowcol) begin
					B[rowcol] = samtc.get_next_B(rowcol);
				end
				@(posedge clk) begin end
				//Check if shifted out vals match
				if(cyc > DIM-1 && cyc < 2*DIM) begin 
					for(int i = 0; i < DIM; i++) begin
						if(B[i] !== Bout[i]) begin
							errors++;
							$display("Error! Bout row %d incorrect. Expected Bout: %d, Got: %d for Col %d", cyc -DIM, B[i], Bout[i], i);
						end
					end
				end
				mycycle = samtc.next_cycle();
			end
			
			@(posedge clk) begin end
			// compute is done
			en_B = 1'b0;
			
		end
		if(errors == 0) begin
			$display("YAHOO!!! All tests passed.");
		end else begin
			$display("ARRRR!  Ye codes be blast! Aye, there be errors. Get debugging!");
		end 
		$stop;	
	end
endmodule
