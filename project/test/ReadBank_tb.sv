module ReadBank_tb();
	parameter BANK_WIDTH = 10;
	parameter MEM_DEPTH = 512;

	logic clk, wr, rst_n;
	logic [63:0] data_in; 
	logic [$clog2(BANK_WIDTH)-1:0] write_sel;
	logic [$clog2(MEM_DEPTH)-1:0] address;
	logic [7:0] data_out [BANK_WIDTH-1:0];


	logic [BANK_WIDTH-1:0][7:0] ref_mem [MEM_DEPTH-1:0];

	ReadBank #(.BANK_WIDTH(BANK_WIDTH), .MEM_BUFFER_DEPTH_BYTES(MEM_DEPTH)) dut(.*);
	int errors;
	always #5 clk = ~clk;
	
	initial begin
		clk = 1'b0;
		rst_n = 1'b0;
		errors = 0;

		@(posedge clk);
		rst_n = 1'b1;
	
		//fill memory
		for(int i = 0; i < BANK_WIDTH; i++) begin	
			wr = 1;
			write_sel = i;	
			for(int j = 0; j < MEM_DEPTH; j+=8) begin
				address = j;
				data_in = {$random(), $random()};		
				ref_mem[j + 7][i] = data_in[7:0];
				ref_mem[j + 6][i] = data_in[15:8];
				ref_mem[j + 5][i] = data_in[23:16];
				ref_mem[j + 4][i] = data_in[31:24];
				ref_mem[j + 3][i] = data_in[39:32];
				ref_mem[j + 2][i] = data_in[47:40];
				ref_mem[j + 1][i] = data_in[55:48];
				ref_mem[j + 0][i] = data_in[63:56];
			@(posedge clk);
			end
		end
		//check memory
		for(int i = 0; i < MEM_DEPTH; i++) begin	
			address = i;	
			wr = 0;
			@(posedge clk);
			for(int j = 0; j < BANK_WIDTH; j++) begin		
				#1
				if(data_out[j] != ref_mem[i][j])
					$display("Error: %d  memory addr: %d  col: %d  expected: %d  actual %d", errors++, address, j, ref_mem[i][j], data_out[j]);
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
