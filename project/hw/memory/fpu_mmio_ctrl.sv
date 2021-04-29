module fpu_mmio_ctrl #(
    parameter ADDR_WIDTH = 32
    )(
    
    input clk,
    input rst_n,
    //FPU I/O
    input logic mapped_data_request,
    input logic [31:0] mapped_address,
    output logic [511:0] mapped_data,
    output logic mapped_data_valid,

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


typedef enum logic[1:0] {READY, BUSY} state_t;

state_t current, next;

always_ff @( posedge clk ) begin 
    if(~rst_n) current <= READY;
    else current <= next;
end

always_comb begin 
    case (current)
        READY   : begin
            //FPU MMIO
            op = '0;
            raw_address = '0;
            address_offset = '0;
            //Mem_ctrl
            common_data_bus_read_in = '0;
            next = mapped_data_request ? BUSY : READY;    //Start sending requests to arbiter when FPU demands
        end 
        BUSY  : begin 
            //FPU Buffer
            //Don't start writing till FPU ready on write
            op = 2'b01;  //Always Read from Host
            raw_address = mapped_address;
            address_offset = '0;    //Not relevant, set by top level AFU
            //Mem_ctrl
            common_data_bus_read_in = '0;   //Don't care, never write data
            mapped_data = common_data_bus_write_out;
            mapped_data_valid = tx_done;
            next = (tx_done)? READY : BUSY;
        end
        
        default: begin
            //Mem_ctrl
            op = '0;
            raw_address = '0;
            address_offset = '0;
            common_data_bus_read_in = '0;
            //FPU mmio
            mapped_data_valid = '0;
            mapped_data = '0;
        end
    endcase
end

endmodule