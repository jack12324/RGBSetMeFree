/*  ram_block v1.0 
 *  Instantiates 256 line Register array of size defined by parameter 
 *
*/
module ram_block #(parameter SIZE =  32) (
    input rst_n,
    input clk,
    input logic [13:0] addr,
    input logic [SIZE-1:0] d,
    input logic WrEn,
    output logic [SIZE-1:0] q
);

    reg [SIZE-1:0] mem [255:0];
    integer i;
    
    always_ff @( posedge clk ) begin : RAM
        if(~rst_n) begin
            for (i=0; i<256; i=i+1) begin
                mem[i] = 0;
             end
        end 
        if(rst_n && WrEn) mem[addr] = d;
        else q = (WrEn | ~rst_n) ? 0 : mem[addr];
    end
    
endmodule