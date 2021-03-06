module FPUVerilogDemo();
	localparam START_ADDRESS = 32'h1000_0000;
	logic clk, rst_n, mapped_data_valid, mapped_data_request, done, start;
	logic [511:0] mapped_data;
	FPUDRAM_if dram_if();
	logic [31:0] mapped_address;

	FPU #(.COL_WIDTH(10), .MEM_BUFFER_WIDTH(512), .CL_WIDTH(64), .START_ADDRESS(START_ADDRESS)) dut(.clk(clk), .rst_n(rst_n), .done(done), .start(start), .mapped_data_valid(mapped_data_valid), .mapped_data_request(mapped_data_request), .mapped_data(mapped_data), .mapped_address(mapped_address), .dram_if(dram_if.FPU));

	logic [31:0] start_address, result_address;
	logic [15:0] width, height;
	logic signed [7:0] filter_conf [8:0];
	int dram_request_num = 0;
	int dram_request_count = 0;
	int dram_base_address = 0;
	int dram_rd_wr = 0;

	logic [7:0] input_memory [(2**25)-1:0];
	logic [7:0] output_memory[(2**25)-1:0];

	always #1 clk = ~clk; 
	initial forever get_mapped_mem();
	initial forever dramRespond();

	initial begin
		clk = 1'b0;
		rst_n = 1'b0;

		@(posedge clk);
		rst_n = 1'b1;

		test_from_file();

		$stop;
	end	

	
	task automatic test_from_file();
		set_config_vars();	
		$readmemh("RGB.txt", input_memory, start_address);

		@(posedge clk);
		start = 1'b1;
		
		@(posedge dut.controller.conf.load_config_done);	
		start = 1'b0;
		
		@(posedge done);
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

	task automatic set_config_vars();
		integer config_file;
		config_file = $fopen("config.txt","r");
		$fscanf(config_file, "%d\n", width);
		$fscanf(config_file, "%d\n", height);
		start_address = 0;
		result_address = 0;
		for(int i = 0; i < 9; i++)
			$fscanf(config_file, "%d\n", filter_conf[i]);
		$fclose(config_file);
	endtask
	
	task automatic dramRespond();
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
					output_memory[dram_base_address + dram_request_count*(64)+i/8] = dram_if.write_data[511-i-:8]; 
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
					dram_if.read_data[511-i*8 -:8] = input_memory[dram_base_address + dram_request_count*64+i];
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

	task automatic get_mapped_mem(); 	
		@(posedge clk);
		mapped_data_valid = 0;
		if(mapped_data_request)begin
			for(int i = 0; i < $urandom_range(1,100); i++)
				@(posedge clk);
			case (mapped_address)
				START_ADDRESS: mapped_data[511:344] = {	width, 
							height, 
							start_address, 
							result_address, 
							filter_conf[0], 
							filter_conf[1],
							filter_conf[2],
							filter_conf[3],
							filter_conf[4],
							filter_conf[5],
							filter_conf[6],
							filter_conf[7],
							filter_conf[8]
							};
				default: mapped_data = '0;
			endcase
			@(posedge clk);
			mapped_data_valid = 1;
			@(posedge clk);
		end	
	endtask
endmodule
