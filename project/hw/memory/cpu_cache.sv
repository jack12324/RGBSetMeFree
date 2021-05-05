
//
// Cache module for CS/ECE 552 Project
// Written by Andy Phelps
// 4 May 2006
//
//  Modified by Derek Hower
//  30 Oct 2006
//   Changed to 4-word lines, byte addressable
//
//  
// Modified for ECE 554 Project :: RGBSetMeFree (Spring 2021)
//  by Mayukh Misra
//  4096 bytes (4kB) Cache Module
//  256 Lines Cache Module
//  Each Line contains 16 Words = 64 Bytes 
//  1 Host DMA Cache Line = 1 CPU Cache line
//  256 * 16 = 4096 Bytes
//

module cpu_cache (
    input en, 
    input clk,
    input rst_n, 
    input logic [7:0] index, 
    input logic [5:0] offset, 
    input comp, 
    input wr, 
    input [17:0] tag_in, 
    input [31:0] data_in, 
    input valid_in,
    output hit, 
    output dirty, 
    output logic [17:0] tag_out, 
    output logic [31:0] data_out, 
    output valid,
    input logic replaceLine,   //Replace entire cache line with cl_in
    input logic [511:0] cl_in,  //Used for direct read from mem_ctrl
    output logic [511:0] cl_out //Used for direct writeback to mem_ctrl
);
//NOTE: Bits 1:0 of Offset must always be 0 for automatic word alignment!

logic [31:0]       w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15;
assign            go = en & rst_n;  
assign            match = (tag_in == tag_out);
assign            cl_out = {w15, w14, w13, w12, w11, w10, w9, w8, w7, w6, w5, w4, w3, w2, w1, w0};  //TODO:: Verify the Endianness

assign            wr_word0 = replaceLine || (go & wr  & ~offset[5] & ~offset[4] & ~offset[3] & ~offset[2] & (match | ~comp));
assign            wr_word1 =  replaceLine || (go & wr  & ~offset[5] & ~offset[4] & ~offset[3] & offset[2] & (match | ~comp));
assign            wr_word2 =  replaceLine || (go & wr  & ~offset[5] & ~offset[4] & offset[3] & ~offset[2] & (match | ~comp));
assign            wr_word3 =  replaceLine || (go & wr  & ~offset[5] & ~offset[4] & offset[3] & offset[2] & (match | ~comp));

assign            wr_word4 =  replaceLine || (go & wr  & ~offset[5] & offset[4] & ~offset[3] & ~offset[2] & (match | ~comp));
assign            wr_word5 =  replaceLine || (go & wr  & ~offset[5] & offset[4] & ~offset[3] & offset[2] & (match | ~comp));
assign            wr_word6 =  replaceLine || (go & wr  & ~offset[5] & offset[4] & offset[3] & ~offset[2] & (match | ~comp));
assign            wr_word7 =  replaceLine || (go & wr  & ~offset[5] & offset[4] & offset[3] & offset[2] & (match | ~comp));

assign            wr_word8 =  replaceLine || (go & wr  & offset[5] & ~offset[4] & ~offset[3] & ~offset[2] & (match | ~comp));
assign            wr_word9 =  replaceLine || (go & wr  & offset[5] & ~offset[4] & ~offset[3] & offset[2] & (match | ~comp));
assign            wr_word10 =  replaceLine || (go & wr  & offset[5] & ~offset[4] & offset[3] & ~offset[2] & (match | ~comp));
assign            wr_word11 =  replaceLine || (go & wr  & offset[5] & ~offset[4] & offset[3] & offset[2] & (match | ~comp));

assign            wr_word12 =  replaceLine || (go & wr  & offset[5] & offset[4] & ~offset[3] & ~offset[2] & (match | ~comp));
assign            wr_word13 =  replaceLine || (go & wr  & offset[5] & offset[4] & ~offset[3] & offset[2] & (match | ~comp));
assign            wr_word14 =  replaceLine || (go & wr  & offset[5] & offset[4] & offset[3] & ~offset[2] & (match | ~comp));
assign            wr_word15 =  replaceLine || (go & wr  & offset[5] & offset[4] & offset[3] & offset[2] & (match | ~comp));


assign            wr_dirty =  replaceLine || (go & wr & (match | ~comp));
assign            wr_tag   =  replaceLine || (go & wr & ~comp);
assign            wr_valid =  replaceLine || (go & wr & ~comp);
assign            dirty_in = replaceLine? '0 : comp ;  // a compare-and-wr sets dirty; a cache-fill clears it

logic [31:0] data_in_i [15:0];   //Data in Wires 

genvar i;
generate 
    for (i = 0 ; i < 16; i = i + 1) begin
    assign data_in_i[i] = replaceLine? cl_in[ 32*(i+1) - 1 : 32*i] : data_in;
    end
endgenerate

//Create Array of 256 lines, w represents the module of each word
ram_block #(32) mem_w0 (.q(w0), .addr(index), .d(data_in_i[0]),  .WrEn(wr_word0), .clk(clk), .rst_n(rst_n));
ram_block #(32) mem_w1 (.q(w1), .addr(index), .d(data_in_i[1]),  .WrEn(wr_word1), .clk(clk), .rst_n(rst_n));
ram_block #(32) mem_w2 (.q(w2), .addr(index), .d(data_in_i[2]),  .WrEn(wr_word2), .clk(clk), .rst_n(rst_n));
ram_block #(32) mem_w3 (.q(w3), .addr(index), .d(data_in_i[3]),  .WrEn(wr_word3), .clk(clk), .rst_n(rst_n));

ram_block #(32) mem_w4 (.q(w4), .addr(index), .d(data_in_i[4]),  .WrEn(wr_word4), .clk(clk), .rst_n(rst_n));
ram_block #(32) mem_w5 (.q(w5), .addr(index), .d(data_in_i[5]),  .WrEn(wr_word5), .clk(clk), .rst_n(rst_n));
ram_block #(32) mem_w6 (.q(w6), .addr(index), .d(data_in_i[6]),  .WrEn(wr_word6), .clk(clk), .rst_n(rst_n));
ram_block #(32) mem_w7 (.q(w7), .addr(index), .d(data_in_i[7]),  .WrEn(wr_word7), .clk(clk), .rst_n(rst_n));

ram_block #(32) mem_w8 (.q(w8), .addr(index), .d(data_in_i[8]),  .WrEn(wr_word8), .clk(clk), .rst_n(rst_n));
ram_block #(32) mem_w9 (.q(w9), .addr(index), .d(data_in_i[9]),  .WrEn(wr_word9), .clk(clk), .rst_n(rst_n));
ram_block #(32) mem_w10 (.q(w10), .addr(index), .d(data_in_i[10]),  .WrEn(wr_word10), .clk(clk), .rst_n(rst_n));
ram_block #(32) mem_w11 (.q(w11), .addr(index), .d(data_in_i[11]),  .WrEn(wr_word11), .clk(clk), .rst_n(rst_n));

ram_block #(32) mem_w12 (.q(w12), .addr(index), .d(data_in_i[12]),  .WrEn(wr_word12), .clk(clk), .rst_n(rst_n));
ram_block #(32) mem_w13 (.q(w13), .addr(index), .d(data_in_i[13]),  .WrEn(wr_word13), .clk(clk), .rst_n(rst_n));
ram_block #(32) mem_w14 (.q(w14), .addr(index), .d(data_in_i[14]),  .WrEn(wr_word14), .clk(clk), .rst_n(rst_n));
ram_block #(32) mem_w15 (.q(w15), .addr(index), .d(data_in_i[15]),  .WrEn(wr_word15), .clk(clk), .rst_n(rst_n));

ram_block #(18) mem_tag (.q(tag_out), .addr(index), .d(tag_in),  .WrEn(wr_tag), .clk(clk), .rst_n(rst_n));
ram_block #( 1) mem_dr (.q(dirtybit), .addr(index), .d(dirty_in),  .WrEn(wr_dirty), .clk(clk), .rst_n(rst_n));
ram_block #( 1) mem_vl (.q(validbit), .addr(index), .d(valid_in),  .WrEn(wr_valid), .clk(clk), .rst_n(rst_n));

assign            hit = go & match;
assign            dirty = go & (~wr | (comp & ~match)) & dirtybit;
assign            valid = go & validbit & (~wr | comp);


always_comb begin 
    case (offset[5:2])
        4'd0: data_out = w0;
        4'd1: data_out = w1;
        4'd2: data_out = w2;
        4'd3: data_out = w3;

        4'd4: data_out = w4;
        4'd5: data_out = w5;
        4'd6: data_out = w6;
        4'd7: data_out = w7;

        4'd8: data_out = w8;
        4'd9: data_out = w9;
        4'd10: data_out = w10;
        4'd11: data_out = w11;

        4'd12: data_out = w12;
        4'd13: data_out = w13;
        4'd14: data_out = w14;
        4'd15: data_out = w15;
    endcase
end

endmodule