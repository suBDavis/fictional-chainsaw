`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Montek Singh
// 10/2/2015 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none
`include "display640x480.sv"

module vgadisplaydriver #(
    parameter char_bits=4,
    parameter sm_locations = 1200, 
    parameter initfile="bitmap_init.txt"
    )(
    input wire clk,
    input wire [char_bits-1:0] char_code,
    output wire [$clog2(sm_locations)-1:0] screen_addr, //bits to store 1200 locations
    output wire [11:0] bmem_color, //rgb in that order
    output wire hsync, vsync
    );

    wire [`xbits-1:0] x;
    wire [`ybits-1:0] y;
    wire activevideo;
    wire [(char_bits+8)-1:0] bmem_addr;
    
    vgatimer myvgatimer(clk, hsync, vsync, activevideo, x, y);
    
    //    row = y/16
    //    col = x/16
    //    screen_addr = row<<5 + row<<3 + col (row*40 + col)
    //    bitmap_addr = charcode*255 + ymod16 * 16 + xmod 16
   
    //Figure out screen data address from 
    assign screen_addr = ((y>>4)<<5) + ((y>>4)<<3) + x>>4;
    
    //Figure out the bitmap location
    assign bmem_addr = {char_code, y[3:0], x[3:0]};
   
    //    parameter Nloc = 4096,                      // Number of memory locations (16 characters * 16x16 patterns)
    //    parameter Dbits = 12,                       // Number of bits in data
    //    parameter initfile = "screentest_bmem.txt"  // Name of file with initial values
    //    )(
    //    input wire [$clog2(Nloc)-1 : 0] ReadAddr1,
    //    output logic [Dbits-1 : 0] ReadData1
    //    );
    bitmapmem #(4096, 12, initfile) bm (bmem_addr, bmem_color);
 
endmodule