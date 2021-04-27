interface FPUConfig_if();
	logic load_config_start, load_config_done, mapped_data_valid;
	logic signed [7:0] filter [8:0];
	logic [15:0] image_width;
	logic [15:0] image_height;
	logic [31:0] start_address;
	logic [31:0] result_address;
	logic [31:0] address_mem;
	logic [31:0] data_mem;
	
	modport Loader (input load_config_start, mapped_data_valid, data_mem, output load_config_done, filter, image_width, image_height, start_address, result_address, address_mem);
endinterface
