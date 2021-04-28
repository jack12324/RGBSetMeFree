//Mem Arbiter to be used by Data Mem and Inst Mem contention, and FPU and CPU contention.

module mem_arbiter #(
    parameter ADDR_WIDTH = 32;  
    )(
    input clk, 
    input rst_n,
    //Inputs from Src1
    input logic [1:0] op_src1,
    input logic [ADDR_WIDTH -1 : 0] raw_address_src1,
    input logic [ADDR_WIDTH -1 : 0] address_offset_src1,
    input logic [511:0] common_data_bus_read_in_src1,
    //Outputs to Src1
    output logic [511:0] common_data_bus_write_out_src1, 
    output logic tx_done_src1,
    output logic rd_valid_src1,
    //Inputs from Src2
    input logic [1:0] op_src2,
    input logic [ADDR_WIDTH -1 : 0] raw_address_src2,
    input logic [ADDR_WIDTH -1 : 0] address_offset_src2,
    input logic [511:0] common_data_bus_read_in_src2,
    //Outputs to Src2
    output logic [511:0] common_data_bus_write_out_src2, 
    output logic tx_done_src2,
    output logic rd_valid_src2,
    //Inputs: From mem_ctrl
    input logic [511:0] common_data_bus_write_out,    
    input logic tx_done,
    input logic rd_valid,
    //Outputs : To mem_ctrl
    output logic [1:0] op,
    output logic [ADDR_WIDTH -1 : 0] raw_address,
    output logic [ADDR_WIDTH -1 : 0] address_offset,
    output logic [511:0] common_data_bus_read_in,   //Naming convention relative to mem_ctrl
);

    typedef enum {READY, SRC1, SRC2} state;

    state current, next;
    
    //State transition block
    always_ff @( posedge clk, negedge rst_n ) begin 
        if(~rst_n) current <= READY;    //Default state
        else current <= next;
    end

    always_comb begin 
        case (current)
            READY: begin
                op = 2'b0;  //Do Nothing
                next = (Condition) ? READY : (Condition Two) ? SRC1 : SRC2;
            end
            SRC1: begin
                //Inputs
                common_data_bus_write_out_src1 = common_data_bus_write_out;
                tx_done_src1 = tx_done;
                rd_valid_src1 = rd_valid;
                //Outputs : To mem_ctrl
                op = op_src1;
                raw_address = raw_address_src1
                address_offset = address_offset_src1;
                common_data_bus_read_in = common_data_bus_read_in_src1;
                next = (Condition possibly tx_done) ? READY : SRC1;
            end
            SRC2: begin
                common_data_bus_write_out_src2 = common_data_bus_write_out;
                tx_done_src2 = tx_done;
                rd_valid_src2 = rd_valid;
                //Outputs : To mem_ctrl
                op = op_src2;
                raw_address = raw_address_src2;
                address_offset = address_offset_src2;
                common_data_bus_read_in = common_data_bus_read_in_src2;
                next = (Condition possibly tx_done) ? READY : SRC2;
            end
            default: 
        endcase
    end
endmodule