module FPUControllerConfigurationLoader #(CONFIG_ADDR = 32'h1000_0000)(clk, rst_n, config_if);
	input clk, rst_n;
	FPUConfig_if config_if;
	
	typedef enum {IDLE, WAIT_READY, CAPTURE, DONE, XXX} state_e; 

	state_e state, next;

	always_ff @(posedge clk, negedge rst_n)
		if(!rst_n) state <= IDLE;
		else state <= next;
	
	//decide next state	
	always_comb begin
		next = XXX;
		case(state)
			IDLE: if(config_if.load_config_start)						next = WAIT_READY;
			      else									next = IDLE;			//@loopback
			WAIT_READY: if(config_if.mapped_data_valid)					next = CAPTURE;
				else									next = WAIT_READY;		//@loopback
			CAPTURE:									next = DONE;
			DONE:										next = IDLE;
			default:									next = XXX;
		endcase
	end	
	
	//outputs	
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin

			config_if.address_mem <= '0;
			config_if.load_config_done <= 0;
			config_if.mapped_data_request <= '0;
			config_if.filter <= '{default:'0};
			config_if.image_width <= '0;
			config_if.image_height <= '0;
			config_if.start_address <= '0;
			config_if.result_address <= '0;
		end
		else begin
			config_if.address_mem <= '0;
			config_if.load_config_done <= 0;
			config_if.mapped_data_request <= '0;
			case(next)
				IDLE:begin end
				WAIT_READY:begin
					config_if.address_mem <= CONFIG_ADDR;
					config_if.mapped_data_request <= '1;
				end
				CAPTURE: begin
					{	config_if.image_width, 
						config_if.image_height, 
						config_if.start_address, 
						config_if.result_address, 
						config_if.filter[0],	
						config_if.filter[1],	
						config_if.filter[2],	
						config_if.filter[3],	
						config_if.filter[4],	
						config_if.filter[5],	
						config_if.filter[6],	
						config_if.filter[7],	
						config_if.filter[8]	
					} <= config_if.data_mem[511:344];
				end 
				DONE: begin
					config_if.load_config_done <= '1;
				end
				default: begin end
			endcase
		end
	end	
endmodule
