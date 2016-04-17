`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2016 11:26:18 AM
// Design Name: 
// Module Name: vga_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module vga_top #(parameter char_size=16, char_count=4, char_bits=8, sm_locations=12000)
    (
    input wire clk,
    output [3:0] red, green, blue,
    output wire hsync, vsync
    );
    
    wire screen_write;
    wire [$clog2(sm_locations)-1:0] screen_readaddr1, screen_readaddr2, screen_writeaddr;
    wire [char_bits-1:0] screen_writedata, screen_readdata1, screen_readdata2;
    
    vgadisplaydriver #(char_bits, $clog2(sm_locations) ) vdd(clk, red, gree, blue, hsync, vsync);
   
//    parameter Nloc = 1200,                     // Number of memory locations
//    parameter Dbits = 8,                       // Number of bits in data
//    parameter initfile = "screenmem_data.txt"  // Name of file with initial values
//    )(
//    input wire wr,                             // WriteEnable:  if wr==1, data is written into mem
//    input wire [$clog2(Nloc)-1 : 0] ReadAddr1, ReadAddr2, WriteAddr, // 3 addresses, two for reading and one for writing
//    input wire [Dbits-1 : 0] WriteData,          // Data for writing into memory (if wr==1)
//    output logic [Dbits-1 : 0] ReadData1, ReadData2 // 2 output ports
//    );

    screenmem #(sm_locations, char_bits, "screenmem_data.txt") sm(screen_write, screen_readaddr1, screen_readaddr2, screen_writeaddr, screen_writedata, screen_readdata1, screen_readdata2);

endmodule
