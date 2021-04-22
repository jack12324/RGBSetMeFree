module FPURequestController#(BUFFER_DEPTH = 512, COL_WIDTH = 10)(clk, rst_n, req_if, dram_if, buffer_rd_address, buffer_read_data);
	localparam CL_WIDTH = 64; //bytes
	input clk, rst_n;
	input [7:0] buffer_read_data;
	output [$clog2(BUFFER_DEPTH) + $clog2(COL_WIDTH) - 1:0] buffer_rd_address;
	FPUCntrlReq_if req_if;
	FPUDRAM_if dram_if;

	typedef enum {IDLE, START_WRITE_REQUEST, LOAD_WRITE_DATA, WAIT_DRAM_READY_WRITE, SEND_WRITE_CL, WAIT_WRITE_DONE, CHECK_WRITE_REQ_DONE, DONE, XXX} state_e;
	state_e state, next;

	//used to save the initial state
	logic capture;
	logic cap_read;
	logic [16:0] cap_width;
	logic [16:0] cap_height;
	logic [31:0] cap_wr_addr;
	logic [31:0] cap_rd_addr;
	logic [7:0] request_size;

	logic [$clog2(BUFFER_DEPTH)-1:0] rd_col;
	logic [$clog2(COL_WIDTH)-1:0] rd_row;
	logic [$clog2(CL_WIDTH):0] load_count;

	logic [7:0] sent_lines;
	logic [16:0] rows_sent;

	assign buffer_rd_address = {rd_row, rd_col};
	
	always_ff @(posedge clk, negedge rst_n)
		if(!rst_n) state <= IDLE;
		else state <= next;
	
	always_comb begin
		next = XXX;
		case(state)
			IDLE: if(req_if.write)					next = START_WRITE_REQUEST;
				else if(req_if.read) 				next = XXX;
				else						next = IDLE;				//@loopback

			START_WRITE_REQUEST:					next = LOAD_WRITE_DATA;
	
			LOAD_WRITE_DATA: if(load_count == CL_WIDTH)		next = WAIT_DRAM_READY_WRITE;		
				else						next = LOAD_WRITE_DATA;			//@loopback		
			
			WAIT_DRAM_READY_WRITE: if(dram_if.dram_ready)		next = SEND_WRITE_CL;
				else						next = WAIT_DRAM_READY_WRITE;		//@loopback
			
			SEND_WRITE_CL: if(sent_lines == request_size)		next = WAIT_WRITE_DONE;
				else						next = LOAD_WRITE_DATA;
		
			WAIT_WRITE_DONE: if(dram_if.request_done) begin
					if(rows_sent == cap_height)		next = IDLE;
					else					next = START_WRITE_REQUEST;
				else						next = WAIT_WRITE_DONE;			//@loopback

		endcase
	end
	
	always_ff @(posedge clk, negedge rst_n)begin
		if(!rst_n)begin
			capture <= '0;
			dram_if.address <= '0;
			dram_if.request_size <= '0;
			dram_if.request <= '0;
			dram_if.rd_wr <= '0;
			rd_row <= '0;
			rd_col <= '0;
			load_count <= '0;
			dram_if.fpu_ready <= '0;
			req_if.making_request <= '0;
			sent_lines <= '0;
			rows_sent <= '0;

		end else begin
			capture <= '0;
			dram_if.address <= dram_if.address;
			dram_if.request_size <= dram_if.request_size;
			dram_if.request <= '0;
			dram_if.rd_wr <= '0;
			rd_row <= '0;
			rd_col <= '0;
			load_count <= load_count;
			dram_if.fpu_ready <= '0;
			req_if.making_request <= '1;
			sent_lines <= sent_lines;
			rows_sent <= '0;

			case(next)
				IDLE: begin
					capture <= '1;
					dram_if.address <= req_if.write ? req_if_write_address : req_if.read_address;
					req_if.making_request <= '0;
					rows_sent <= '0;
				end
				START_WRITE_REQUEST: begin
					dram_if.request_size <= request_size;
					dram_if.rd_wr <= '1;
					dram_if.request <= '1;
					load_count <= '0;
					rd_col <= '0;
					sent_lines <= '0;
					rows_sent <= rows_sent +1;
				end
				LOAD_WRITE_DATA: begin
					load_count <= load_count + 1;
					rd_col <= rd_col + 1;
					dram_if.write_data <= (dram_if.write_data << 8) + buffer_read_data; 
				end
				WAIT_DRAM_READY_WRITE: begin
				end
				SEND_WRITE_CL: begin
					dram_if.fpu_ready <= '1;
					sent_lines <= sent_lines + 1;
				end
				WAIT_WRITE_DONE: begin
				end
			endcase
		end
	end

	always_ff @(posege clk, negedge rst_n)begin
		if(!rst_n)begin
			cap_width <= '0;
			cap_height <= '0;
			cap_wr_addr <= '0;
			cap_rd_addr <= '0;
			request_size <= '0;
		end else if (capture)begin
			cap_width <= req_if.width;
			cap_height <= req_if.height;
			cap_wr_addr <= req_if.write_address;
			cap_rd_addr <= req_if.read_address;
			request_size <= (req_if.width >> 6) + |req_if.width[5:0];
		end
	end
	
endmodule
