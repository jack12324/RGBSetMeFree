module syn_test(input clk, input rst_n);
	parameter COL_WIDTH = 10;
	parameter MEM_BUFFER_WIDTH = 256;

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

	logic [31:0] start_address, result_address, start_sig;
	logic [15:0] width, height;
	logic signed [7:0] filter_conf [8:0];

	logic [7:0] col_new [COL_WIDTH - 1:0];
	logic [7:0] col0   [COL_WIDTH - 1:0];
	logic [7:0] col1   [COL_WIDTH - 1:0];
	logic [7:0] col2   [COL_WIDTH - 1:0];
	logic [7:0] result_pixels [COL_WIDTH-3:0];

	FPUController #(.MEM_BUFFER_WIDTH(MEM_BUFFER_WIDTH), .COL_WIDTH(COL_WIDTH))controller(.*);
	FPUMAC #(.COL_WIDTH(COL_WIDTH)) mac(.*);
	FPUBuffers #(.COL_WIDTH(COL_WIDTH)) buff(.*);
endmodule

