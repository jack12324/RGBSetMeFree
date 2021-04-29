/*  ram_block v1.0 
 *  Instantiates 256 line Register array of size defined by parameter 
 *
*/
module ram_block #(parameter SIZE =  32) (
    input rst_n,
    input clk,
    input logic [7:0] addr,
    input logic [SIZE-1:0] d,
    input logic WrEn,
    output logic [SIZE-1:0] q
);

    reg [SIZE-1:0] mem [255:0];
    integer i;
    
    //Currently Big endian - To change this make 
    /*
    assign data_swapped = {{data[07:00]},
                       {data[15:08]},
                       {data[23:16]},
                       {data[31:24]}};
    */
    always_ff @( posedge clk ) begin : RAM
        if(~rst_n) begin
            for (i=0; i<256; i=i+1) begin
                mem[i] <= 0;
             end
        end 
        else if(WrEn) mem[addr] <= d;
        q <= mem[addr];
    end
    
    // logic [31:0] littleEndian = {mem[addr][7:0], mem[addr][15:8], mem[addr][23:16], mem[addr][31:24]}
    
endmodule