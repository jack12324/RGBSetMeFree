module fpu_dma_ctrl #(
    parameter ADDR_WIDTH = 32
    )(
    
    input clk,
    input rst_n,
    FPUDRAM_if.DRAM dram_if,
    //Inputs: From mem_ctrl
    input logic [511:0] common_data_bus_write_out,    
    input logic tx_done,
    input logic rd_valid,
    //Outputs : To mem_ctrl
    output logic [1:0] op,
    output logic [ADDR_WIDTH -1 : 0] raw_address,
    output logic [ADDR_WIDTH -1 : 0] address_offset,
    output logic [511:0] common_data_bus_read_in   //Naming convention relative to mem_ctrl
);


typedef enum logic[1:0] {START, ACTIVE, DONE} state_t;

state_t current, next;
logic [7:0] req_counter;

always_ff @( posedge clk ) begin 
    if(~rst_n) current <= START;
    else current <= next;
end

always @(posedge clk) begin
    if(~rst_n)   req_counter <= '0;
    //Update counter after every Cache line transaction is complete
    req_counter <= (current == ACTIVE)? (
                    (tx_done)? (req_counter + 1'b1 ) : req_counter)
                    : 'b0;
end

always_comb begin 
    case (current)
        START   : begin
            //FPU Buffer
            op = '0;
            raw_address = '0;
            address_offset = '0;
            //Mem_ctrl
            common_data_bus_read_in = '0;
            dram_if.dram_ready = '1;
            dram_if.request_done = '0;
            dram_if.read_data = '0;
            next = dram_if.request ? ACTIVE : START;    //Start sending requests to arbiter when FPU demands
        end 
        ACTIVE  : begin 
            //FPU Buffer
            //Don't start writing till FPU ready on write
            op = (dram_if.rd_wr) ? ((dram_if.fpu_ready) ? 2'b11 : 2'b00): (dram_if.fpu_ready) ? 2'b01 : 2'b00;
            raw_address = dram_if.address + (req_counter<<6);
            address_offset = '0;    //Not relevant, set by top level AFU
            //Mem_ctrl
            common_data_bus_read_in = dram_if.write_data;
            dram_if.read_data = common_data_bus_write_out;
            dram_if.dram_ready = dram_if.rd_wr ? 1'b1: tx_done;    //Signals data is ready to be read
            dram_if.request_done = '0;
            next = (req_counter == dram_if.request_size)? DONE : ACTIVE;
        end
        DONE    : begin
            //FPU Buffer
            op = '0;
            raw_address = '0;
            address_offset = '0;
            //Mem_ctrl
            common_data_bus_read_in = '0;
            dram_if.dram_ready = '0;
            dram_if.request_done = '1;
            dram_if.read_data = '0;
            next = dram_if.fpu_ready ? ACTIVE : DONE;
        end

        default: begin
            //FPU Buffer
            op = '0;
            raw_address = '0;
            address_offset = '0;
            //Mem_ctrl
            common_data_bus_read_in = '0;
            dram_if.dram_ready = '1;
            dram_if.request_done = '0;
            dram_if.read_data = '0;
        end
    endcase
end

endmodule