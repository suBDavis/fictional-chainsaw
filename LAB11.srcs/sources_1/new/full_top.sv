//////////////////////////////////////////////////////////////////////////////////
//
// Montek Singh
// 11/12/2015 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none

module full_top #(
    parameter imem_init="screentest_imem.txt",
    parameter dmem_init="screentest_dmem.txt",
    parameter scrmem_init="screentest_smem.txt",		// text file to initialize screen memory
    parameter bitmap_init="screentest_bmem.txt",	    // text file to initialize bitmap memory
    parameter char_bits=4,                           //Number of bits for distinct charactders (32 default)
    parameter sm_locations=1200                     //number of screen memory locations (30 * 40) (for a 16x16 char)
)(
    input wire clk, reset,
    // add I/O signals here
    output wire [3:0] red, green, blue,
    output wire hsync, vsync
);
   
    wire [31:0] pc, instr, mem_readdata, mem_writedata, mem_addr;
    wire mem_wr;
    wire clk100, clk50, clk25, clk12;
    
    //fix these
    wire [char_bits-1 : 0] charcode;
    wire [$clog2(sm_locations)-1 : 0] smem_addr;

    // Uncomment *only* one of the following two lines:
    //    when synthesizing, use the first line
    //    when simulating, get rid of the clock divider, and use the second line
    //
    clockdivider_Nexys4 clkdv(clk, clk100, clk50, clk25, clk12);
    //assign clk100=clk; assign clk50=clk; assign clk25=clk; assign clk12=clk;

    // For synthesis:  use an appropriate clock frequency(ies) below
    //   clk100 will work for only the most efficient designs (hardly anyone)
    //   clk50 or clk 25 should work for the vast majority
    //   clk12 should work for everyone!
    //
    // Use the same clock frequency for the MIPS and data memory/memIO modules
    // The vgadisplaydriver should keep the 100 MHz clock.
    // For example:
    
    //input wire clk, 
    //input wire reset, 
    //output wire [31:0] pc, 
    //input wire [31:0] instr, 
    //output wire mem_wr, 
    //output wire [31:0] mem_addr,
    //output wire [31:0] mem_writedata, 
    //input wire [31:0] mem_readdata
    
    mips mips(
        .clk(clk12), 
        .reset(reset), 
        .pc(pc[31:0]), 
        .instr(instr), 
        .mem_wr(mem_wr), 
        .mem_addr(mem_addr), 
        .mem_writedata(mem_writedata), 
        .mem_readdata(mem_readdata)
        );
    
    imem #(32, 32, 32, imem_init) 
        imem(pc[31:0], instr);
    
    //parameter Abits = 32,
    //parameter Nloc = 32,
    //parameter Dbits = 32,
    //parameter sm_locations = 1200,
    //parameter max_addr_bits=13,
    //parameter char_bits = 8,
    //parameter dmem_init = "dmem_init.txt",
    //parameter screenmem_init = "screenmem_init.txt"
    //)(
    //input wire clk,
    //input wire mem_wr,
    //input wire [Dbits-1:0] mem_writedata, 
    //output wire [Dbits-1:0] mem_readdata,
    //input wire [Abits-1:0] mem_addr,
    //output wire [char_bits-1:0] char_code,
    //input wire [$clog2(sm_locations)-1:0] screen_addr
    memIO #(32, 32, 32, sm_locations, 13, char_bits, dmem_init, scrmem_init) memIO(
        .clk(clk12), 
        .mem_wr(mem_wr), 
        .mem_writedata(mem_writedata), 
        .mem_readdata(mem_readdata), 
        .mem_addr(mem_addr), 
        .char_code(charcode), 
        .screen_addr(smem_addr));
        
    //    parameter char_bits=4,
    //    parameter sm_locations = 1200, 
    //    parameter initfile="bitmap_init.txt"
    //    )(
    //    input wire clk,
    //    input wire [char_bits-1:0] char_code,
    //    output wire [$clog2(sm_locations):0] screen_addr, //bits to store 1200 locations
    //    output wire [11:0] bmem_color, //rgb in that order
    //    output wire hsync, vsync
    vgadisplaydriver #(char_bits, sm_locations, bitmap_init) display(
        .clk(clk100), 
        .char_code(charcode), 
        .screen_addr(smem_addr), 
        .bmem_color({red, green, blue}), 
        .hsync(hsync), 
        .vsync(vsync));

endmodule