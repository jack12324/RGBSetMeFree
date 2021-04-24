module FPU_tb();
	
	logic clk, rst_n, mapped_data_valid;
	logic [31:0] mapped_data;
	FPUDRAM_if dram_if();
	logic [31:0] mapped_address;

	FPU #(.COL_WIDTH(10), .MEM_BUFFER_WIDTH(512), .CL_WIDTH(64)) dut(.clk(clk), .mem_clk(clk), .rst_n(rst_n), .mapped_data_valid(mapped_data_valid), .mapped_data(mapped_data), .mapped_address(mapped_address), .dram_if(dram_if.FPU));

	int errors;
	logic [31:0] start_address, result_address, start_sig;
	logic [15:0] width, height;
	logic signed [7:0] filter_conf [8:0];
	int dram_request_num = 0;
	int dram_request_count = 0;
	int dram_base_address = 0;
	int dram_rd_wr = 0;

	logic [7:0] input_memory [(2**16)-1:0];
	logic [7:0] output_memory[(2**16)-1:0];
	logic [7:0] ref_output_memory[(2**16)-1:0];
		
	always #5 clk = ~clk; 
	initial forever get_mapped_mem();
	initial forever dramRespond();

	initial begin
		clk = 1'b0;
		rst_n = 1'b0;
		errors = 0;

		@(posedge clk);
		rst_n = 1'b1;

		test_with_image_size(212, 5);
		
		
		$display("Errors: %d", errors);

		if(!errors) begin
			$display("YAHOO!!! All tests passed.");
		end
		else begin
			$display("ARRRR!  Ye codes be blast! Aye, there be errors. Get debugging!");
		end

		$stop;
	end	

	
	task automatic test_with_image_size(int width, int height);
		set_config_vars(width, height);	
		initialize_memories();

		@(posedge clk);
		start_sig = 1'b1;
		
		@(posedge dut.controller.conf.load_config_done);	
		start_sig = 1'b0;
		check_config_vars();
		
		@(posedge dut.done);
		compare_memories();
		@(posedge clk);

	endtask

	task automatic initialize_memories();
		int input_row_width = (width+2)*3;
		int output_row_width = (width)*3 + 4;
		for (int i = start_address; i < start_address + (input_row_width*(height+2)); i++)begin
			input_memory[i] = $random();
		end
		for (int i = 0; i < height; i++)begin
			for (int j = 0; j < input_row_width - 2; j++)begin
				int input_base = start_address + (i * input_row_width) + j;
				int output_base = result_address + (i * output_row_width) + j;
				ref_output_memory[output_base] = calc_MAC({<<8{	input_memory[input_base], input_memory[input_base +1], input_memory[input_base + 2],
									 	input_memory[input_row_width + input_base], input_memory[input_row_width + input_base + 1], input_memory[input_row_width + input_base + 2],
									 	input_memory[2*input_row_width + input_base], input_memory[2*input_row_width + input_base + 1], input_memory[2*input_row_width + input_base + 2]}}, filter_conf);
			end	
		end
	endtask

	task automatic set_config_vars(int w, int h);
		width = w;
		height = h;
		start_address = $urandom_range(0,65535);
		result_address = $urandom_range(0,65535);
		for(int i = 0; i < 9; i++)
			filter_conf[i] = $urandom_range(0,2)-1;
	endtask
	
	task automatic compare_memories();
		for(int i = 0; i < (2**16)-1; i++)begin
			if(output_memory[i] !== ref_output_memory[i])begin
				$display("location: %d expected: %d actual: %d", i, ref_output_memory[i], output_memory[i]);
			end
		end		
	endtask

	task automatic dramRespond();
		@(posedge clk)
		dram_if.request_done = 0;
		if(dram_if.request)begin
			dram_request_num = dram_if.request_size;
			dram_request_count = 0;
			dram_base_address = dram_if.address;
			dram_rd_wr = dram_if.rd_wr;
		end
		dram_if.dram_ready = '1;
		if(dram_rd_wr)begin
			if(dram_if.fpu_ready)begin
				for(int i = 0; i < 512; i+=8)begin
					output_memory[dram_base_address + dram_request_count*(64)+i/8] = dram_if.write_data[511-i-:8]; 
				end
				dram_if.dram_ready = '0;
				for(int i = 0; i < $urandom_range(0,10); i++) @(posedge clk);
				dram_if.dram_ready = '1;
				dram_request_count++;
				if(dram_request_count == dram_request_num)
					dram_if.request_done = 1;
			end
		end else begin
			dram_if.dram_ready = '0;
			if(dram_if.fpu_ready)begin
				for(int i = 0; i < $urandom_range(0,10); i++) @(posedge clk);
				for(int i = 0; i < 64; i++)begin
					dram_if.read_data[511-i*8 -:8] = input_memory[dram_base_address + dram_request_count*64+i];
				end
				dram_if.dram_ready = '1;
				@(posedge clk)
				dram_if.dram_ready = '0;
				dram_request_count++;
				if(dram_request_count == 8)begin
					for(int i = 0; i < $urandom_range(0,20); i++) @(posedge clk);
					dram_if.request_done = 1;
					@(posedge clk)
					while(!dram_if.fpu_ready) @(posedge clk);
					dram_if.request_done = 0;
				end
			end
		end
	endtask

	task automatic check_config_vars();
		if (dut.controller.conf.image_width != width) $display("Configuration Load Error %d: expected image width = %d, got: %d", errors++, width, dut.controller.conf.image_width);
		if (dut.controller.conf.image_height != height) $display("Configuration Load Error %d: expected image height = %d, got: %d", errors++, height, dut.controller.conf.image_height);
		if (dut.controller.conf.start_address != start_address) $display("Configuration Load Error %d: expected image start_address = %h, got: %h", errors++, start_address, dut.controller.conf.start_address);
		if (dut.controller.conf.result_address != result_address) $display("Configuration Load Error %d: expected image result_address = %h, got: %h", errors++, result_address, dut.controller.conf.result_address);
		for (int i = 0; i < 9; i++)
			if (dut.controller.conf.filter[i]!= filter_conf[i]) $display("Configuration Load Error %d: expected image filter slot %d = %d, got: %d", errors++, i, filter_conf[i], dut.controller.conf.filter[i]);
	endtask

	task automatic get_mapped_mem(); 	
		int M_STARTSIG_ADDRESS = 32'h1000_0120;
		int M_FILTER_ADDRESS = 32'h1000_0040;
		int M_DIMS_ADDRESS = 32'h1000_0000;
		int M_START_ADDRESS = 32'h1000_0020;
		int M_RESULT_ADDRESS = 32'h1000_0100;
		int noise = $random();
		mapped_data_valid = 0;
		for(int i = 0; i < $urandom_range(2,10); i++)
			@(posedge clk);
		case (mapped_address)
			M_STARTSIG_ADDRESS: mapped_data = start_sig;
			M_FILTER_ADDRESS: mapped_data = {filter_conf[0],filter_conf[1],filter_conf[2],filter_conf[3]};
			M_FILTER_ADDRESS+4: mapped_data = {filter_conf[4],filter_conf[5],filter_conf[6],filter_conf[7]};
			M_FILTER_ADDRESS+8: mapped_data = {filter_conf[8], noise[23:0]};
			M_DIMS_ADDRESS: mapped_data = {width, height};
			M_START_ADDRESS: mapped_data = start_address;
			M_RESULT_ADDRESS: mapped_data = result_address;
			default: mapped_data = 'x;
		endcase
		@(posedge clk);
		mapped_data_valid = 1;
		@(posedge clk);
	endtask

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

endmodule
