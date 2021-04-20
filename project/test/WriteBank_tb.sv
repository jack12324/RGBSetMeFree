module WriteBank_tb();
	parameter BANK_WIDTH = 10;
	parameter MEM_DEPTH = 512;
	logic clk, wr, rst_n;
	logic [7:0] data_in [BANK_WIDTH-1: 0]; 
	logic [$clog2(BANK_WIDTH)-1:0] read_sel;
	logic [$clog2(MEM_DEPTH)-1:0] address;
	logic [7:0] data_out;

	logic [BANK_WIDTH-1:0][7:0] ref_mem [MEM_DEPTH-1:0];

	WriteBank #(.BANK_WIDTH(BANK_WIDTH), .MEM_BUFFER_DEPTH_BYTES(MEM_DEPTH)) dut(.*);
	int errors;
	always #5 clk = ~clk;
	
	initial begin
		clk = 1'b0;
		rst_n = 1'b0;
		errors = 0;

		@(posedge clk);
		rst_n = 1'b1;
	
		//fill memory
		for(int i = 0; i < MEM_DEPTH; i++) begin	
			wr = 1;
			for(int j = 0; j < BANK_WIDTH; j++) begin
				data_in[j] = $random();		
				ref_mem[i][j] = data_in[j];
			end	
			address = i;	
			@(posedge clk);
		end
		//check memory
		for(int i = 0; i < MEM_DEPTH; i++) begin	
			for(int j = 0; j < BANK_WIDTH; j++) begin		
				wr = 0;
				address = i;	
				read_sel = j;
				@(posedge clk);
				#1
				if(data_out != ref_mem[i][j])
					$display("Error: %d  memory addr: %d  col: %d  expected: %d  actual %d", errors++, address, read_sel, ref_mem[i][j], data_out);
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
