module FPUMemoryIntegration_tb();
	parameter COL_WIDTH = 10;
	parameter MEM_BUFFER_WIDTH = 512;
	localparam BADDR_BITS = $clog2(MEM_BUFFER_WIDTH);
	localparam CADDR_BITS = $clog2(COL_WIDTH);
	localparam WADDR_BITS = $clog2(COL_WIDTH-2);

	// Clock
	logic clk;
	logic rst_n;

	int errors;
	int dram_request_num = 0;
	int dram_request_count = 0;
	int dram_base_address = 0;
	int dram_rd_wr = 0;

	//request buffer inputs
	logic  wr_en_rd_buffer, wr_en_wr_buffer, rd_buffer_sel, wr_buffer_sel;
	logic  [BADDR_BITS-1:0] read_col_address;
	logic  [BADDR_BITS-1:0] write_col_address;
	logic  [BADDR_BITS + CADDR_BITS - 1:0] request_write_address;
	logic  [BADDR_BITS + WADDR_BITS - 1:0] request_read_address;
	logic  [63:0] request_data_in;
	logic  [7:0] write_col [COL_WIDTH - 3: 0];
	//request buffer outputs
	logic [7:0] read_col [COL_WIDTH-1:0];
	logic [7:0] request_data_out;

	logic [7:0] input_mem[0:2**16];
	logic [7:0] buff_mem[0:2**16];

	logic [7:0] ref_mem[0: 2**16];
	logic [7:0] out_mem[0: 2**16];


	FPUCntrlReq_if req_if();
	FPUDRAM_if dram_if();

	FPURequestBuffer #(.BUFFER_DEPTH(MEM_BUFFER_WIDTH), .COL_WIDTH(COL_WIDTH))buff(.*);
	FPURequestController#(.BUFFER_DEPTH(MEM_BUFFER_WIDTH), .COL_WIDTH(COL_WIDTH)) cont(.clk(clk), .rst_n(rst_n), .req_if(req_if.REQUEST_CONTROLLER), .dram_if(dram_if.FPU), .buffer_rd_address(request_read_address), .buffer_read_data(request_data_out), .buffer_wr_address(request_write_address), .buffer_write_data(request_data_in), .wr_en_rd_buffer(wr_en_rd_buffer));

	always dramRespond();
	always #5 clk = ~clk; 
	initial begin
		clk = 1'b0;
		rst_n = 1'b0;
		errors = 0;
		req_if.read = '0;
		req_if.write = '0;
		req_if.width = '0;
		req_if.height = '0;
		req_if.read_address = '0;
		req_if.write_address = '0;
		req_if.input_row_width = '0;
		req_if.output_row_width = '0;
		dram_if.read_data = '0;

		@(posedge clk);
		rst_n = 1'b1;
		@(posedge clk);
		write_test('0, MEM_BUFFER_WIDTH, COL_WIDTH-2, '0);
		//write_test('1, MEM_BUFFER_WIDTH, COL_WIDTH-2, 5000);
		//write_test('1, MEM_BUFFER_WIDTH, COL_WIDTH-2, '0);
		//write_test('1, MEM_BUFFER_WIDTH, 3, '0);
		//write_test('1, MEM_BUFFER_WIDTH, 1, '0);
		//write_test('1, 64, COL_WIDTH-2, '0);
		//write_test('1, 320, COL_WIDTH-2, 3000);
		//
	
		//read_test('0, 448, 50);
		//read_test('0, 64, 50);
		//read_test('0, 512, 50);
		//read_test('1, 664, 0);

		//write_read_test(1,1,512,8,512,0,0);
		//write_read_test(0,1,64,5,560,4,100);

		$stop();
		
	end

	task automatic write_read_test(bit write_buffer, bit read_buffer, int write_width, int write_height, int row_width, int start_address, int res_address);
		fillMemory(write_buffer, write_width, write_height, res_address);
		read_mem_init(start_address, row_width);
	
		wr_buffer_sel = ~write_buffer;
		rd_buffer_sel = ~read_buffer;
		req_if.write = 1;
		req_if.read = 1;
		req_if.width = write_width;
		req_if.height = write_height;
		req_if.input_row_width = row_width;
		req_if.write_address = res_address;
		req_if.read_address = start_address;
		req_if.output_row_width = write_width;
		@(posedge clk);
		req_if.write = 0;
		req_if.read = 0;
		
		@(negedge req_if.making_request);
		compare_memories();
		emptyBuffer(read_buffer);
		compare_read_mems(start_address, row_width);
		@(posedge clk);
	endtask

	task automatic write_test(bit buffer, int width, int height, int res_address);
		fillMemory(buffer, width, height, res_address);
	
		wr_buffer_sel = ~buffer;
		req_if.write = 1;
		req_if.width = width;
		req_if.height = height;
		req_if.write_address = res_address;
		req_if.output_row_width = width;
		@(posedge clk);
		req_if.write = 0;
		
		@(negedge req_if.making_request);
		compare_memories();
		@(posedge clk);
	endtask

	task automatic read_test(bit buffer, int width, int start_address);
		read_mem_init(start_address, width);
		rd_buffer_sel = !buffer;
		req_if.read = 1;
		req_if.input_row_width = width;
		req_if.read_address = start_address;
		req_if.input_row_width = width;
		@(posedge clk);
		req_if.read = 0;
		
		@(negedge req_if.making_request);
		emptyBuffer(buffer);
		compare_read_mems(start_address, width);
		@(posedge clk);
	endtask

	task automatic compare_read_mems(int start_address, int image_width);
		for(int i = 0; i < COL_WIDTH; i++)begin
			for(int j = 0; j < MEM_BUFFER_WIDTH; j++)begin
				if(buff_mem[i*MEM_BUFFER_WIDTH + j] !== input_mem[start_address+i*image_width+j])begin
					$display("read fail: location: %d expected: %d actual: %d", i*MEM_BUFFER_WIDTH + j, input_mem[start_address+i*image_width+j], buff_mem[i*MEM_BUFFER_WIDTH + j]);
				end
			end
		end		
	endtask
	
	task automatic read_mem_init(int start_address, width);
		for(int i = 0; i < width * COL_WIDTH; i++)begin
			input_mem[start_address +i] = $random();
		end	
	endtask

	task automatic compare_memories();
		for(int i = 0; i < (2**16)-1; i++)begin
			if(out_mem[i] !== ref_mem[i])begin
				$display("write fail: location: %d expected: %d actual: %d", i, ref_mem[i], out_mem[i]);
			end
		end		
	endtask

	task dramRespond();
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
					out_mem[dram_base_address + dram_request_count*(64)+i/8] = dram_if.write_data[511-i-:8]; 
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
					dram_if.read_data[511-i*8 -:8] = input_mem[dram_base_address + dram_request_count*64+i];
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

	task automatic emptyBuffer(bit buffer);
		//check memory
		@(posedge clk);
		rd_buffer_sel = buffer;
		for(int i = 0; i < MEM_BUFFER_WIDTH; i++) begin	
			read_col_address = i;	
			wr_en_rd_buffer = 0;
			@(posedge clk)
			@(negedge clk)
			for(int j = 0; j < COL_WIDTH; j++) begin		
				buff_mem[j*MEM_BUFFER_WIDTH + i] = read_col[j];
			end
		end
	endtask

	task fillMemory(bit buffer, int width, int height, int res_address);
		//fill memory
		wr_en_wr_buffer = 1;
		wr_buffer_sel = buffer;
		for(int i = 0; i < width; i++) begin	
			for(int j = 0; j < height; j++) begin
				write_col[j] = $random();		
				ref_mem[res_address + width*j + i] = write_col[j];
			end	
			write_col_address = i;	
			@(posedge clk);
		end
		wr_en_wr_buffer = 0;
	endtask
endmodule
