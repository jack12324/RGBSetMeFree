interface FPUCntrlReq_if();
	logic read;
	logic write;
	logic making_request;
	logic [16:0] width;
	logic [16:0] height;
	logic [31:0] write_address;
	logic [31:0] read_address;
	
	modport CONTROLLER(output read, write, width, height, write_address, read_address, input making_request);
	modport REQUEST_CONTROLLER(output making_request, input read, write, width, height, write_address, read_address);
endinterface
