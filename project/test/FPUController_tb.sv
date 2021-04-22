// FIFO Testbench

module FPUController_tb();
	parameter COL_WIDTH = 10;
	parameter MEM_BUFFER_WIDTH = 512;

	// Clock
	logic clk;
	logic rst_n;

	logic stall, mapped_data_valid, making_request;
	logic [31:0] data_mem;

	logic shift_cols, done, request_write, request_read, rd_buffer_sel, wr_buffer_sel, wr_en_wr_buffer;
	logic signed [7:0] filter [8:0];
	logic [31:0] read_address;
	logic [31:0] write_address;
	logic [$clog2(MEM_BUFFER_WIDTH)-1:0] write_col_address;
	logic [$clog2(MEM_BUFFER_WIDTH)-1:0] read_col_address;
	logic [31:0] address_mem;
	logic [16:0] write_request_width;
	logic [8:0] write_request_height;

	always #5 clk = ~clk; 

	int errors;
	logic [31:0] start_address, result_address, start_sig;
	logic [15:0] width, height;
	logic signed [7:0] filter_conf [8:0];

	logic [7:0] input_memory [(2**22)-1:0];
	logic [7:0] output_memory[(2**22)-1:0];
	logic [7:0] ref_output_memory[(2**22)-1:0];

	logic [MEM_BUFFER_WIDTH-1:0][7:0] read_buff0 [COL_WIDTH-1:0];
	logic [MEM_BUFFER_WIDTH-1:0][7:0] read_buff1 [COL_WIDTH-1:0];

	logic [MEM_BUFFER_WIDTH-1:0][7:0] write_buff0[COL_WIDTH-1:0];
	logic [MEM_BUFFER_WIDTH-1:0][7:0] write_buff1[COL_WIDTH-1:0];

	logic [7:0] col_new [COL_WIDTH - 1:0];
	logic [7:0] col0   [COL_WIDTH - 1:0];
	logic [7:0] col1   [COL_WIDTH - 1:0];
	logic [7:0] col2   [COL_WIDTH - 1:0];
	logic [7:0] result_pixels [COL_WIDTH-3:0];

	FPUController #(.MEM_BUFFER_WIDTH(MEM_BUFFER_WIDTH), .COL_WIDTH(COL_WIDTH))controller(.*);

	FPUMAC #(.COL_WIDTH(COL_WIDTH)) mac(.*);
	FPUBuffers #(.COL_WIDTH(COL_WIDTH)) buff(.*);

	initial forever get_mapped_mem();
	initial forever handle_requests();
	initial forever write_buffer();
	initial forever read_buffer();
		
	initial begin
		clk = 1'b0;
		rst_n = 1'b0;
		errors = 0;

		@(posedge clk);
		rst_n = 1'b1;
	
		test_from_file(225, 225);	

		//test fits completely in one buffer
		//test_with_image_size(160, 5);

		////tests thats height fits in one buffer but width is larger
		//test_with_image_size(169, 5);
		//test_with_image_size(210, 5);
		//test_with_image_size(200, 5);
		//test_with_image_size(400, 5);

		////tests that width fit in one buffer but height is larger
		//test_with_image_size(160, 9);
		//test_with_image_size(160, 200);
		//test_with_image_size(160, 20);

		////tests that fill both ways
		//test_with_image_size(300, 10);
		//test_with_image_size(1000, 600);
		
		
		$display("Errors: %d", errors);

		if(!errors) begin
			$display("YAHOO!!! All tests passed.");
		end
		else begin
			$display("ARRRR!  Ye codes be blast! Aye, there be errors. Get debugging!");
		end

		$stop;

	end
	
	task automatic test_from_file(int width, int height);
		set_config_vars(width, height);	
		for(int i = 0; i < 9; i++)
			filter_conf[i] = -1;
		filter_conf[4] = 8;
		load_and_init_memories();

		@(posedge clk);
		start_sig = 1'b1;
		
		@(posedge controller.conf.load_config_done);	
		start_sig = 1'b0;
		check_config_vars();
		
		@(posedge done);
		compare_memories();
		@(posedge clk);
		write_result(width, height);

	endtask

	task automatic write_result(int width, int height);
		integer outfile;
		outfile = $fopen("output.txt", "w");
		for(int i = result_address; i < result_address + height * ((width*3)+4); i++)begin
			$fdisplay(outfile, "%d",output_memory[i]);
		end
		$fclose(outfile);
	endtask
	
	task automatic load_and_init_memories();
		int input_row_width = (width+2)*3;
		int output_row_width = (width)*3 + 4;

		$readmemh("test.txt", input_memory, start_address);

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

	
	task automatic test_with_image_size(int width, int height);
		set_config_vars(width, height);	
		initialize_memories();

		@(posedge clk);
		start_sig = 1'b1;
		
		@(posedge controller.conf.load_config_done);	
		start_sig = 1'b0;
		check_config_vars();
		
		@(posedge done);
		compare_memories();
		@(posedge clk);

	endtask
	
	task automatic compare_memories();
		for(int i = 0; i < (2**22)-1; i++)begin
			if(output_memory[i] !== ref_output_memory[i])begin
				$display("location: %d expected: %d actual: %d", i, ref_output_memory[i], output_memory[i]);
			end
		end		
	endtask

	task automatic read_buffer();
		@(posedge clk)
		for(int row = 0; row < COL_WIDTH; row++)begin
			if(rd_buffer_sel) col_new[row] = read_buff1[row][read_col_address];
			else col_new[row] = read_buff0[row][read_col_address];
		end
	endtask

	task automatic write_buffer();
		@(posedge clk)
		if(wr_en_wr_buffer)begin
			for(int row = 0; row < COL_WIDTH; row++)begin
				if(wr_buffer_sel) write_buff1[row][write_col_address] = result_pixels[row];
				else write_buff0[row][write_col_address] = result_pixels[row];
			end
		end
	endtask

	task automatic handle_requests();
		int max_stall = 1000;
		int min_stall = 10;
		@(posedge clk)
		if(request_read && request_write) begin
			making_request = 1;
			empty_buffer(!rd_buffer_sel, write_address, write_request_width, write_request_height);
			fill_buffer(!rd_buffer_sel, read_address);
			for(int stall_cyc = 0; stall_cyc < $urandom_range(min_stall,max_stall); stall_cyc++) @(posedge clk);
			making_request = 0;
		end else if (request_read && !request_write)begin
			making_request = 1;
			fill_buffer(!rd_buffer_sel, read_address);
			for(int stall_cyc = 0; stall_cyc < $urandom_range(min_stall,max_stall); stall_cyc++) @(posedge clk);
			making_request = 0;
		end else if (!request_read && request_write)begin
			making_request = 1;
			empty_buffer(!rd_buffer_sel, write_address, write_request_width, write_request_height);
			for(int stall_cyc = 0; stall_cyc < $urandom_range(min_stall,max_stall); stall_cyc++) @(posedge clk);
			making_request = 0;
		end
	endtask

	task automatic fill_buffer(bit buffer, int strt_address);
		for(int row = 0; row < COL_WIDTH; row++)begin
			for(int col = 0; col < MEM_BUFFER_WIDTH; col++)begin
				if(buffer) read_buff1[row][col] = input_memory[strt_address + row * (width+2)*3 + col];	
				else read_buff0[row][col] = input_memory[strt_address + row * (width+2)*3 + col];	
			end
		end
	endtask

	task automatic empty_buffer(bit buffer, int res_address, int size_w, int size_h);
		//$display("from buffer %d  fill starting %d  width %d  height %d", buffer, res_address, size_w, size_h);
		for(int row = 0; row < size_h; row++)begin
			for(int col = 0; col < size_w; col++)begin
				if(buffer) output_memory[res_address + row * (width*3+4) + col] = write_buff1[row][col];	
				else output_memory[res_address + row * (width*3+4) + col] = write_buff0[row][col];	
			end
		end
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

	task automatic check_config_vars();
		if (controller.conf.image_width != width) $display("Configuration Load Error %d: expected image width = %d, got: %d", errors++, width, controller.conf.image_width);
		if (controller.conf.image_height != height) $display("Configuration Load Error %d: expected image height = %d, got: %d", errors++, height, controller.conf.image_height);
		if (controller.conf.start_address != start_address) $display("Configuration Load Error %d: expected image start_address = %h, got: %h", errors++, start_address, controller.conf.start_address);
		if (controller.conf.result_address != result_address) $display("Configuration Load Error %d: expected image result_address = %h, got: %h", errors++, result_address, controller.conf.result_address);
		for (int i = 0; i < 9; i++)
			if (controller.conf.filter[i]!= filter_conf[i]) $display("Configuration Load Error %d: expected image filter slot %d = %d, got: %d", errors++, i, filter_conf[i], controller.conf.filter[i]);
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
		case (address_mem)
			M_STARTSIG_ADDRESS: data_mem = start_sig;
			M_FILTER_ADDRESS: data_mem = {filter_conf[0],filter_conf[1],filter_conf[2],filter_conf[3]};
			M_FILTER_ADDRESS+4: data_mem = {filter_conf[4],filter_conf[5],filter_conf[6],filter_conf[7]};
			M_FILTER_ADDRESS+8: data_mem = {filter_conf[8], noise[23:0]};
			M_DIMS_ADDRESS: data_mem = {width, height};
			M_START_ADDRESS: data_mem = start_address;
			M_RESULT_ADDRESS: data_mem = result_address;
			default: data_mem = 'x;
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


	typedef logic [7:0]test_def[8:0];
	function automatic test_def assemble(input [7:0] col0 [COL_WIDTH-1:0], input [7:0] col1 [COL_WIDTH-1:0], input [7:0] col2 [COL_WIDTH-1:0], input int index);
		assemble = {col2[index  ], col1[index  ], col0[index  ],
			    col2[index+1], col1[index+1], col0[index+1],
		            col2[index+2], col1[index+2], col0[index+2] };
		return {<<8{assemble}};	
	endfunction

	task automatic displayArray(input[7:0] array0 [8:0], input signed [7:0] array1 [8:0]);
		for(int i = 0; i < 9; i++)begin
			$display("index: %d arr0: %d filter: %d", i, array0[i], array1[i]);
		end
	endtask


endmodule
