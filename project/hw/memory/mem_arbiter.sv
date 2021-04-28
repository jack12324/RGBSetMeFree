//Mem Arbiter to be used by Data Mem and Inst Mem and FPU Buffer contention.
// Uses Round Robin Scheduling over multiple requests. 

module mem_arbiter #(
    parameter ADDR_WIDTH = 32      //Address needs to be 64 bits for Mem_ctrl.sv
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
    
    //Inputs from Src3
    input logic [1:0] op_src3,
    input logic [ADDR_WIDTH -1 : 0] raw_address_src3,
    input logic [ADDR_WIDTH -1 : 0] address_offset_src3,
    input logic [511:0] common_data_bus_read_in_src3,
    //Outputs to Src3
    output logic [511:0] common_data_bus_write_out_src3, 
    output logic tx_done_src3,
    output logic rd_valid_src3,

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

    //No Need to latch in SRCs because they will be kept high in the states they are created.

    typedef enum {SRC1, SRC2, SRC3} state;

    state current, next;
    
    //State transition block
    always_ff @( posedge clk, negedge rst_n ) begin 
        if(~rst_n) current <= READY;    //Default state
        else current <= next;
    end
    //Transition states checking 
    /* state = ready
        src1 -> src2 -> src3 -> srcX ... until (opX) != 0, then stay in srcX till tx_done
      cyc1:         op_1 = Read || ...*n cycles
      cyc n + 1:    txdone_1 = 1 || 
      cyc n + 2:    op_1 = Write || ... *n
    */

    always_comb begin 
        case (current)
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
                next = |op_src1 & ~(tx_done_host) ? SRC1 : SRC2;
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
                next = |op_src2 & ~(tx_done_host) ? SRC2 : SRC3;
            end
            SRC3: begin
                common_data_bus_write_out_src3 = common_data_bus_write_out;
                tx_done_src3 = tx_done;
                rd_valid_src3 = rd_valid;
                //Outputs : To mem_ctrl
                op = op_src3;
                raw_address = raw_address_src3;
                address_offset = address_offset_src3;
                common_data_bus_read_in = common_data_bus_read_in_src3;
                next = |op_src2 & ~(tx_done_host) ? SRC3 : SRC1;
                next = |op_src3 & ~(tx_done_host) ? SRC3 : SRC1;
            end
            default: 
                op = '0;
                raw_address = '0;
                address_offset = '0;
                common_data_bus_read_in = '0;
                next = SRC1;
        endcase
    end
endmodule
