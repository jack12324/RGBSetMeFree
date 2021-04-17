// FIFO Testbench

module FPUController_tb();
	parameter COL_WIDTH = 10;

	// Clock
	logic clk;
	logic rst_n;

	logic stall, mapped_data_valid, making_request;
	logic [31:0] data_mem;

	logic shift_cols, done, request_write, request_read, rd_buffer_sel, wr_buffer_sel, wr_en_wr_buffer;
	logic signed [7:0] filter [8:0];
	logic [31:0] read_address;
	logic [31:0] write_address;
	logic [8:0] write_col_address;
	logic [8:0] read_col_address;
	logic [31:0] address_mem;

	always #5 clk = ~clk; 

	int errors, i, j, width, height, start_address, result_address, start_sig;
	logic signed [7:0] filter_conf [8:0];
	
	FPUController controller(.*);

	initial forever get_mapped_mem();

	initial begin
		set_config_vars();	
		clk = 1'b0;
		rst_n = 1'b0;
		errors = 0;

		@(posedge clk);
		rst_n = 1'b1;
		start_sig = 1'b1;
		
		@(posedge controller.conf.load_config_done);	
		

		$display("Errors: %d", errors);

		if(!errors) begin
			$display("YAHOO!!! All tests passed.");
		end
		else begin
			$display("ARRRR!  Ye codes be blast! Aye, there be errors. Get debugging!");
		end

		$stop;

	end
	
	task automatic set_config_vars();
		width = $random();
		height = $random();
		start_address = $random();
		result_address = $random();
		for(int i = 0; i < 9; i++)
			filter_conf[i] = $urandom_range(0,2)-1;
	endtask

	task automatic get_mapped_mem(); 	
		int M_STARTSIG_ADDRESS = 32'h1000_0120;
		int M_FILTER_ADDRESS = 32'h1000_0040;
		int M_DIMS_ADDRESS = 32'h1000_0000;
		int M_START_ADDRESS = 32'h1000_0020;
		int M_RESULT_ADDRESS = 32'h1000_0100;
		mapped_data_valid = 0;
		for(int i = 0; i < $urandom_range(1,10); i++)
			@(posedge clk)
		case (address_mem)
			M_STARTSIG_ADDRESS: data_mem = start_sig;
			M_FILTER_ADDRESS: data_mem = {filter_conf[8],filter_conf[7],filter_conf[6],filter_conf[5]};
			M_FILTER_ADDRESS+4: data_mem = {filter_conf[4],filter_conf[3],filter_conf[2],filter_conf[1]};
			M_FILTER_ADDRESS+8: data_mem = {filter_conf[0], $random()};
			M_DIMS_ADDRESS: data_mem = {width, height};
			M_START_ADDRESS: data_mem = start_address;
			M_RESULT_ADDRESS: data_mem = result_address;
			default: data_mem = 'x;
		endcase
		mapped_data_valid = 1;
	endtask

	function automatic [7:0] calc_MAC(input[7:0] array0 [8:0], input signed [7:0] array1 [8:0]);
		int sum = 0;
		for(int i = 0; i < 9; i++)begin
			sum += signed'({1'b0, array0[i]}) * array1[i];
		end
		if(sum < 0)
			return 0;
		else if (sum > 255)
			return 255;
		return sum;
	endfunction


	typedef logic [7:0]test_def[8:0];
	function automatic test_def assemble(input [7:0] col0 [COL_WIDTH-1:0], input [7:0] col1 [COL_WIDTH-1:0], input [7:0] col2 [COL_WIDTH-1:0], input int index);
		assemble = {col2[index  ], col1[index  ], col0[index  ],
			    col2[index+1], col1[index+1], col0[index+1],
		            col2[index+2], col1[index+2], col0[index+2] };
		return {<<8{assemble}};	
	endfunction


endmodule
