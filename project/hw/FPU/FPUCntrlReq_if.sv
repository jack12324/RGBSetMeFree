interface FPUCntrlReq_if();
	logic read;
	logic write;
	logic making_request;
	logic [16:0] width;
	logic [16:0] height;
	logic [31:0] write_address;
	logic [31:0] read_address;
	logic [18:0] input_row_width; 
	logic [18:0] output_row_width; 

	modport CONTROLLER(output read, write, width, height, write_address, read_address, input_row_width, output_row_width, input making_request);
	modport REQUEST_CONTROLLER(output making_request, input read, write, width, height, write_address, read_address, input_row_width, output_row_width);
endinterface
