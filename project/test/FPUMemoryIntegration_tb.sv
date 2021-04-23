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
	int dram_base_write_address = 0;

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

	logic [7:0] ref_mem[0: 2**16];
	logic [7:0] out_mem[0: 2**16];

	FPUCntrlReq_if req_if();
	FPUDRAM_if dram_if();

	FPURequestBuffer #(.BUFFER_DEPTH(MEM_BUFFER_WIDTH), .COL_WIDTH(COL_WIDTH))buff(.*);
	FPURequestController#(.BUFFER_DEPTH(MEM_BUFFER_WIDTH), .COL_WIDTH(COL_WIDTH)) cont(.clk(clk), .rst_n(rst_n), .req_if(req_if.REQUEST_CONTROLLER), .dram_if(dram_if.FPU), .buffer_rd_address(request_read_address), .buffer_read_data(request_data_out));

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

		@(posedge clk);
		rst_n = 1'b1;

		fillMemory('0, MEM_BUFFER_WIDTH, COL_WIDTH-2, '0);
	
		wr_buffer_sel = 1;
		req_if.write = 1;
		req_if.width = 512;
		req_if.height = 8;
		@(posedge clk);
		req_if.write = 0;
		
		@(negedge req_if.making_request);
		$display("done");
		compare_memories();
		$stop();
		
	end

	task automatic compare_memories();
		for(int i = 0; i < (2**16)-1; i++)begin
			if(out_mem[i] !== ref_mem[i])begin
				$display("location: %d expected: %d actual: %d", i, ref_mem[i], out_mem[i]);
			end
		end		
	endtask

	task dramRespond();
		@(posedge clk)
		dram_if.request_done = 0;
		if(dram_if.request)begin
			dram_request_num = dram_if.request_size;
			dram_request_count = 0;
			dram_base_write_address = dram_if.address;
		end
		dram_if.dram_ready = '1;
		if(dram_if.fpu_ready)begin
			for(int i = 0; i < 512; i+=8)begin
				out_mem[dram_base_write_address + dram_request_count*(64)+i/8] = dram_if.write_data[511-i-:8]; 
			end
			dram_if.dram_ready = '0;
			for(int i = 0; i < $urandom_range(0,10); i++) @(posedge clk);
			dram_if.dram_ready = '1;
			dram_request_count++;
			if(dram_request_count == dram_request_num)
				dram_if.request_done = 1;
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
