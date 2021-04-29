/* mem_ctrl.sv
 * Memory Controller
 *
 * This controller assumes based on the message type
 * it will either perform (0) nothing, (1) read, or (3) write
 * The packet parsing itself is left up to the user to define. You need to set op correctly
 * from the outside.
 *
 * On startup, the MHSR/cc which has communication with the memory controller should stall until ready is asserted by the mem_ctrl
 * After ready is asserted, read and write requests can be serviced. Before then, all signals, except reset, are ignored.
 *
 * wchen329
 * EDIT: TEAM EMOTIONAL MELTDOWN
 */
module mem_ctrl
#(
	parameter WORD_SIZE = 32,
	parameter CL_SIZE_WIDTH = 512,
	parameter ADDR_BITCOUNT = 64
	
)
(
	input wire clk,
	input wire rst_n,
	input wire host_init,
	input wire host_rd_ready,
	input wire host_wr_ready,

	input logic [1:0] op,
	input wire [ADDR_BITCOUNT-1:0] raw_address,
	input wire [ADDR_BITCOUNT-1:0] address_offset,

	input logic [CL_SIZE_WIDTH-1:0] common_data_bus_read_in, 
	output logic [CL_SIZE_WIDTH-1:0] common_data_bus_write_out, 

	input logic [CL_SIZE_WIDTH-1:0] host_data_bus_read_in,
	output logic [CL_SIZE_WIDTH-1:0] host_data_bus_write_out,

	output logic [ADDR_BITCOUNT-1:0] corrected_address,

	output logic ready,
	output logic tx_done,
	output logic rd_valid,
	output logic host_re, // might need since controls fifo shifting...
	output logic host_we,
	output logic host_rgo,
	output logic host_wgo
);
	
	// Definitions
	typedef enum logic [1:0]
	{
		IDLE = 2'b00,
		READ = 2'b01,
		WRITE = 2'b11 
	} opcode;

	typedef enum reg[1:0]
	{
		STARTUP = 2'b00,
		READY = 2'b01,
		HOSTOP = 2'b10,
		FILL = 2'b11
	} sm_state;


	// Wiring
	opcode op_in;

	// State Elements
	sm_state state;
	logic fill_count;

	//logic [WORD_SIZE-1:0] line_out [FILL_COUNT-1:0];
	logic [CL_SIZE_WIDTH-1:0] internal_val;

	// Bubble : for undocumented required stalls on the DMA system
	reg bubble;
	
	always_comb begin
		// Default values
		host_data_bus_write_out = internal_val;
		common_data_bus_write_out = internal_val;
		tx_done = 1'b0;
		ready = 1'b1;
		host_re = 1'b0;
		host_we = 1'b0;
		host_rgo = 1'b0;
		host_wgo = 1'b0;
		rd_valid = 1'b0;

		case(state)
			STARTUP: begin
				ready = 1'b0;
			end
			READY: begin
			end

			HOSTOP: begin

				if(op == WRITE) begin
					host_wgo = 1'b1;

					if(host_wr_ready && bubble) begin
						// Write
						/* Here, we should just write the data and then
						 * return to READY when done
						 */
						tx_done = 1'b1;
						host_we = 1'b1;
					end
				end	
				else if(op == READ) begin
				// Read
				/* Just fill the cache line buffer with a single read
				 */
					host_rgo = 1'b1;
				end
			end
				
			FILL: begin

				if(op == READ) begin
					rd_valid = 1'b1;
					host_re = 1'b1;

					if(&fill_count == 1'b1) begin
						tx_done = 1'b1;
					end
				end
			end
			default: begin
				// If we are in startup we really don't
				// do anything out of the ordinary
			end
		endcase

	end
	
	always_ff@ (posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			state <= STARTUP;
			fill_count <= '0;
			internal_val <= '0;
			bubble <= '0;
		end

		else begin
			case(state)
				STARTUP: begin
					if(host_init) begin
						// We've init'd, we can go start servicing
						state <= READY;
					end
				end

				READY: begin
					if(op_in == READ) begin
						state <= HOSTOP;
					end
					else if(op_in == WRITE) begin
						state <= FILL;
					end
				end

				FILL: begin
					// We fill until we can fill no more!
					if(&fill_count == 1'b1) begin
						fill_count <= '0;

						if(op_in == WRITE) begin
							state <= HOSTOP;
							internal_val <= common_data_bus_read_in;
						end
						else if(op_in == READ) begin
							state <= READY;
						end
					end
					else begin
						if(op_in == WRITE) begin
							internal_val <= common_data_bus_read_in;
						end
						fill_count <= fill_count + 1;
					end
				end

				HOSTOP: begin
					if(op == READ && host_rd_ready) begin
						// Read
						internal_val <= host_data_bus_read_in;
						state <= FILL;
					end
					else if(op == WRITE && bubble) begin
						// Write
						/* Here, we should just write the data and then
						 * return to READY when done
						 */
						state <= READY;
						bubble <= 1'b0;
					end
					else if(op == WRITE && !bubble && host_wr_ready) begin
						// Wait a cycle to let any address changes propagate down the chain.
						bubble <= bubble + 1;
					end
				end

				default begin
				end
			endcase
		end
	end

	// Continuous Assigns
	assign op_in = opcode'(op);
	assign corrected_address = raw_address + address_offset;

endmodule
