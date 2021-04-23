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

		fillMemory();
	
		wr_buffer_sel = 1;
		req_if.write = 1;
		req_if.width = 512;
		req_if.height = 8;
		@(posedge clk);
		req_if.write = 0;
		
		@(negedge req_if.making_request);
		$display("done");
		
	end

	task dramRespond();
		@(posedge clk)
		dram_if.dram_ready = '1;
		if(dram_if.fpu_ready)begin
			dram_if.dram_ready = '0;
			for(int i = 0; i < $urandom_range(0,10); i++) @(posedge clk);
			dram_if.dram_ready = '1;
			
		end
	endtask

	task fillMemory();
		//fill memory
		wr_en_wr_buffer = 1;
		wr_buffer_sel = 0;
		for(int i = 0; i < MEM_BUFFER_WIDTH; i++) begin	
			for(int j = 0; j < COL_WIDTH-2; j++) begin
				write_col[j] = $random();		
				//ref_mem[i][j] = write_col[j];
			end	
			write_col_address = i;	
			@(posedge clk);
		end
		wr_en_wr_buffer = 0;

	endtask
endmodule
