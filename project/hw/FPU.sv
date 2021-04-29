module FPU#(COL_WIDTH = 10, MEM_BUFFER_WIDTH = 512, CL_WIDTH = 64, START_ADDRESS = 32'h1000_0000)(clk, rst_n, done, start, mapped_data_valid, mapped_data_request, mapped_data, mapped_address, dram_if);
	//START_ADDRESS is the starting config address	
	//using different clock speeds doesn't work in testbench
	input clk, rst_n, mapped_data_valid, start;
	input [511:0] mapped_data;
	FPUDRAM_if dram_if;
	output done, mapped_data_request;
	output [31:0] mapped_address;

	logic shift_cols, rd_buffer_sel, wr_buffer_sel, wr_en_wr_buffer, wr_en_rd_buffer;
	logic signed [7:0] filter [8:0];
	logic [7:0] buffer_read_data;
	logic [CL_WIDTH-1: 0] buffer_write_data;
	logic [$clog2(MEM_BUFFER_WIDTH) + $clog2(COL_WIDTH-2) - 1:0] buffer_rd_address;
	logic [$clog2(MEM_BUFFER_WIDTH) + $clog2(COL_WIDTH) - 1:0] buffer_wr_address;
	logic [$clog2(MEM_BUFFER_WIDTH) - 1:0] read_col_address;
	logic [$clog2(MEM_BUFFER_WIDTH) -1:0] write_col_address;
	logic [7:0] write_col [COL_WIDTH - 3: 0];
	logic [7:0] read_col [COL_WIDTH-1:0];

	logic [7:0] col0 [COL_WIDTH-1:0];
	logic [7:0] col1 [COL_WIDTH-1:0];
	logic [7:0] col2 [COL_WIDTH-1:0];

	FPUCntrlReq_if req_if();


	FPURequestController #(.BUFFER_DEPTH(MEM_BUFFER_WIDTH), .COL_WIDTH(COL_WIDTH), .CL_WIDTH(CL_WIDTH)) requestController(.clk(clk),
																.rst_n(rst_n),
																.req_if(req_if.REQUEST_CONTROLLER),
																.dram_if(dram_if),
																.buffer_rd_address(buffer_rd_address),
																.buffer_read_data(buffer_read_data),
																.buffer_wr_address(buffer_wr_address),
																.buffer_write_data(buffer_write_data),
																.wr_en_rd_buffer(wr_en_rd_buffer)
																);

	FPUController #(.MEM_BUFFER_WIDTH(MEM_BUFFER_WIDTH), .COL_WIDTH(COL_WIDTH), .START_ADDRESS(START_ADDRESS)) controller(	.clk(clk),
																.rst_n(rst_n),
																.start(start),
																.mapped_data_valid(mapped_data_valid),
																.mapped_data_request(mapped_data_request),
																.shift_cols(shift_cols),
																.filter(filter),
																.done(done),
																.write_col_address(write_col_address),
																.read_col_address(read_col_address),
																.rd_buffer_sel(rd_buffer_sel),
																.wr_buffer_sel(wr_buffer_sel),
																.wr_en_wr_buffer(wr_en_wr_buffer),
																.address_mem(mapped_address),
																.data_mem(mapped_data),
																.req_if(req_if.CONTROLLER)
											);

 	FPURequestBuffer#(.BUFFER_DEPTH(MEM_BUFFER_WIDTH), .COL_WIDTH(COL_WIDTH)) requestBuffer(.clk(clk),
												.rst_n(rst_n),
												.request_write_address(buffer_wr_address),
												.request_read_address(buffer_rd_address),
												.request_data_in(buffer_write_data),
												.request_data_out(buffer_read_data),
												.wr_en_rd_buffer(wr_en_rd_buffer),
												.wr_en_wr_buffer(wr_en_wr_buffer),
												.rd_buffer_sel(rd_buffer_sel),
												.wr_buffer_sel(wr_buffer_sel),
												.read_col(read_col),
												.write_col(write_col),
												.read_col_address(read_col_address),
												.write_col_address(write_col_address)
												);
	FPUMAC #(.COL_WIDTH(COL_WIDTH)) mac(	.clk(clk),
						.rst_n(rst_n),
						.col0(col0),
						.col1(col1),
						.col2(col2),
						.filter(filter),
						.result_pixels(write_col)
						);

	FPUBuffers #(.COL_WIDTH(COL_WIDTH)) buffers (	.clk(clk),
							.rst_n(rst_n),
							.shift_cols(shift_cols),
							.col_new(read_col),
							.col0(col0),
							.col1(col1),
							.col2(col2)
							);
endmodule
