module FPUControllerConfigurationLoader #(M_STARTSIG_ADDRESS = 32'h1000_0120, M_FILTER_ADDRESS = 32'h1000_0040, M_DIMS_ADDRESS = 32'h1000_0000, M_START_ADDRESS = 32'h1000_0020, M_RESULT_ADDRESS = 32'h1000_0100)(clk, rst_n, config_if);
	input clk, rst_n;
	FPUConfig_if config_if;
	
	logic wr_filter1, wr_filter2, wr_filter3, wr_dims, wr_start_addr, wr_res_addr; 

	typedef enum {IDLE, LOAD_FILTER1, LOAD_FILTER2, LOAD_FILTER3, LOAD_DIMS, LOAD_START_ADDR, LOAD_RESULT_ADDR, DONE, XXX} state_e;

	state_e state, next;

	always_ff @(posedge clk, negedge rst_n)
		if(!rst_n) state <= IDLE;
		else state <= next;
	
	//decide next state	
	always_comb begin
		next = XXX;
		case(state)
			IDLE: if(config_if.load_config_start)						next = LOAD_FILTER1;
			      else									next = IDLE;			//@loopback
			LOAD_FILTER1: if(config_if.mapped_data_valid)					next = LOAD_FILTER2;
				     else								next = LOAD_FILTER1;		//@loopback	
			LOAD_FILTER2: if(config_if.mapped_data_valid)					next = LOAD_FILTER3;
				     else								next = LOAD_FILTER2;		//@loopback
			LOAD_FILTER3: if(config_if.mapped_data_valid)					next = LOAD_DIMS;
				     else								next = LOAD_FILTER3;		//@loopback
			LOAD_DIMS: if(config_if.mapped_data_valid)					next = LOAD_START_ADDR;
				    else								next = LOAD_DIMS;		//@loopback
			LOAD_START_ADDR: if(config_if.mapped_data_valid)				next = LOAD_RESULT_ADDR;
					 else								next = LOAD_START_ADDR;		//@loopback
			LOAD_RESULT_ADDR: if(config_if.mapped_data_valid)				next = DONE;
					  else								next = LOAD_RESULT_ADDR;	//@loopback
			DONE:										next = IDLE;
			default:									next = XXX;
		endcase
	end	
	
	//outputs	
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			wr_filter1 <= 0;
			wr_filter2 <= 0;
			wr_filter3 <= 0;
			wr_dims <= 0;
			wr_start_addr <= 0;
			wr_res_addr <= 0;
		end
		else begin
			wr_filter1 <= '0;
			wr_filter2 <= '0;
			wr_filter3 <= '0;
			wr_dims <= 0;
			wr_start_addr <= 0;
			wr_res_addr <= 0;

			case(state)
				IDLE: config_if.address_mem <= M_STARTSIG_ADDRESS;
				LOAD_FILTER1: begin
					config_if.address_mem <= M_FILTER_ADDRESS;
					wr_filter1 <= 1;
					end
				LOAD_FILTER2: begin
					config_if.address_mem <= M_FILTER_ADDRESS + 4;
					wr_filter2 <= 1;
					end
				LOAD_FILTER3: begin
					config_if.address_mem <= M_FILTER_ADDRESS + 8;
					wr_filter3 <= 1;
					end
				LOAD_DIMS: begin
					config_if.address_mem <= M_DIMS_ADDRESS;
					wr_dims <= 1;
					end
				LOAD_START_ADDR: begin
					config_if.address_mem <= M_START_ADDRESS;
					wr_start_addr <= 1;
					end
				LOAD_RESULT_ADDR: begin
					config_if.address_mem <= M_RESULT_ADDRESS;
					wr_res_addr <= 1;
					end
				DONE:	config_if.load_config_done <= 1;
				default: begin end
			endcase
		end
	end	
	
	//registers to hold configuration values
	always_ff @(posedge clk, negedge rst_n)begin
		if (!rst_n) begin
			config_if.filter <= '{default:'0};
			config_if.image_width <= '0;
			config_if.image_height <= '0;
			config_if.start_address <= '0;
			config_if.result_address <= '0;
		end
		else begin
			if(wr_filter1) config_if.filter[3:0] <= {config_if.data_mem[7:0], config_if.data_mem[15:8], config_if.data_mem[23:16], config_if.data_mem[31:24]};
			else if(wr_filter2) config_if.filter[7:4] <= {config_if.data_mem[7:0], config_if.data_mem[15:8], config_if.data_mem[23:16], config_if.data_mem[31:24]};
			else if(wr_filter3) config_if.filter[8] <= config_if.data_mem[31:24];
			
			if(wr_dims) begin
				config_if.image_width <= config_if.data_mem[31:16];
				config_if.image_height <= config_if.data_mem[15:0];
			end
			
			if(wr_start_addr) config_if.start_address <= config_if.data_mem;
			if(wr_res_addr) config_if.result_address <= config_if.data_mem;
		end
	end
endmodule
