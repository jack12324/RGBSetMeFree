interface FPUDRAM_if();
	logic request;			//asserted to make a request, request type specified by rd_wr
	logic rd_wr;			//high = wr, low = read
	logic fpu_ready;		//for writes this signals that the data on the write data line is valid, must not be asserted if dram_ready is not asserted. for reads this signifies if the fpu is ready to recieve a cache line of data
	logic dram_ready;		//for writes this signals that the fpu is ready to recieve data. for reads this signifies thaat the data on the read_data line is valid, must not be asserted if fpu_ready is not asserted. 
	logic request_done;		//asserted when a request is done
	logic [31:0] address;		//starting address for request
	logic [511:0] write_data;	//data from FPU, dram_ready signifies valid data
	logic [511:0] read_data;	//data from DRAM controller, dram_ready signifies valid data
	logic [7:0] request_size;	//number of cache lines for a request
	
	modport FPU (input dram_ready, request_done, read_data output request, rd_wr, fpu_ready, address, write_data, request_size);
endinterface
