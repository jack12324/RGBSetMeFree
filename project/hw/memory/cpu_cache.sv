// 1024 bytes (1kB) Cache Module
// 256 Line Cache Module
// Each Line contains 4 Words = 16 Bytes [ 4 * 32 bits = 4 * 4 * 8 bits]
// 256 * 4 = 1024 Bytes

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
//

module cpu_cache (
    cache_if.cache cintf
);
//NOTE: Bits 1:0 of Offset must always be 0 for automatic word alignment!

logic [31:0]       w0, w1, w2, w3;
assign            go = enable & rst_n;  
assign            match = (tag_in == tag_out);

assign            wr_word0 = go & write & ~offset[3] & ~offset[2] & (match | ~comp);
assign            wr_word1 = go & write & ~offset[3] &  offset[2] & (match | ~comp);
assign            wr_word2 = go & write &  offset[3] & ~offset[2] & (match | ~comp);
assign            wr_word3 = go & write &  offset[3] &  offset[2] & (match | ~comp);

assign            wr_dirty = go & write & (match | ~comp);
assign            wr_tag   = go & write & ~comp;
assign            wr_valid = go & write & ~comp;
assign            dirty_in = comp;  // a compare-and-write sets dirty; a cache-fill clears it

//Create Array of 256 lines, w represents the module of each word
ram_block #(32) mem_w0 (.q(w0), .index(index), .d(data_in),  .WrEn(wr_word0), .clk(clk), .rst_n(rst_n));
ram_block #(32) mem_w1 (.q(w1), .index(index), .d(data_in),  .WrEn(wr_word1), .clk(clk), .rst_n(rst_n));
ram_block #(32) mem_w2 (.q(w2), .index(index), .d(data_in),  .WrEn(wr_word2), .clk(clk), .rst_n(rst_n));
ram_block #(32) mem_w3 (.q(w3), .index(index), .d(data_in),  .WrEn(wr_word3), .clk(clk), .rst_n(rst_n));

ram_block #(20) mem_tag (.q(tag_out), .index(index), .d(tag_in),  .WrEn(wr_tag), .clk(clk), .rst_n(rst_n));
ram_block #( 1) mem_dr (.q(dirtybit), .index(index), .d(dirty_in),  .WrEn(wr_dirty), .clk(clk), .rst_n(rst_n));
ram_block #( 1) mem_vl (.q(validbit), .index(index), .d(valid_in),  .WrEn(wr_valid), .clk(clk), .rst_n(rst_n));

assign            hit = go & match;
assign            dirty = go & (~write | (comp & ~match)) & dirtybit;
assign            data_out = (write | ~go)? 'b0 : 
                    offset[3] ? (offset[2] ? w3 : w2) : 
                        (offset[2] ? w1 : w0) ;
assign            valid = go & validbit & (~write | comp);

endmodule

// DUMMY LINE FOR REV CONTROL :0:

endmodule 