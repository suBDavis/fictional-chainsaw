`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2016 03:04:59 PM
// Design Name: 
// Module Name: memIO
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


module memIO #(
    parameter Abits = 32,
    parameter Nloc = 32,
    parameter Dbits = 32,
    parameter sm_locations = 1200,
    parameter max_addr_bits=13,
    parameter char_bits = 4,
    parameter dmem_init = "dmem.txt",
    parameter screenmem_init = "smem.txt"
    )(
    input wire clk,
    input wire mem_wr,
    input wire [Dbits-1:0] mem_writedata, 
    output wire [Dbits-1:0] mem_readdata,
    input wire [Abits-1:0] mem_addr,
    output wire [char_bits-1:0] char_code,
    input wire [$clog2(sm_locations)-1:0] screen_addr
    );
    
    wire [$clog2(sm_locations)-1:0] screen_readaddr1, screen_readaddr2, screen_writeaddr;
    wire [Dbits-1:0] dmem_writedata, dmem_readdata;
    wire [Abits-1:0] dmem_addr;
    wire [char_bits-1:0] screen_readdata1, screen_readdata2, screen_writedata;
    wire smem_wr, dmem_wr;
    wire [1:0] mem_code;
    
    //Tells the memory where to look for the data
    assign mem_code = mem_addr[max_addr_bits+1:max_addr_bits]; //Default = 15:14
    
    //Tell each of the addresses where to look
    assign screen_readaddr1 = mem_addr[$clog2(sm_locations)-1:0];
    assign dmem_addr = { {(Abits - max_addr_bits) {1'b0}}, mem_addr[max_addr_bits-1:0] };
    assign screen_writeaddr = mem_addr[$clog2(sm_locations)-1:0];
    
    //Assign the other screen read port
    assign screen_readaddr2 = screen_addr;
    assign char_code = screen_readdata2;
    
    //Assign WriteDAta
    assign screen_writedata = mem_writedata[char_bits-1:0];
    assign dmem_writedata = mem_writedata;
    
    //combinational logic for the mem_code
    assign mem_readdata = 
          (mem_code == 2'b10) ? { {(Dbits-char_bits){1'b0}}, screen_readdata1}
        : (mem_code == 2'b01) ? dmem_readdata
        : (mem_code == 2'b00) ? {(Dbits){1'b0}} // return all 0 for 0 register
        : (mem_code == 2'b11) ? {(Dbits){1'bX}} // Not implemented yet!
        : {(Dbits){1'bX}}; // shouldn't happen
        
    //Combinational logic for write
    assign dmem_wr = (mem_code == 2'b01 & mem_wr == 1'b1) ? 1'b1 : 1'b0;
    assign smem_wr = (mem_code == 2'b10 & mem_wr == 1'b1) ? 1'b1 : 1'b0;
        
    //parameter Abits = 32,
    //parameter Nloc = 32,
    //parameter Dbits = 32,
    //parameter initfile = "screentest_dmem.txt"
    //)(
    //input wire clock,
    //input wire mem_wr,
    //input wire [Abits-1 : 0] mem_addr,
    //input wire [Dbits-1 : 0] mem_writedata, 
    //output logic [Dbits-1 : 0] mem_readdata 
    dmem #(Abits, Nloc, Dbits, dmem_init) dmem(
        .clock(clk), 
        .mem_wr(dmem_wr), 
        .mem_addr(dmem_addr), 
        .mem_writedata(dmem_writedata), 
        .mem_readdata(dmem_readdata)
    );
    
    //parameter Nloc = 1200,                     // Number of memory locations
    //parameter Dbits = 4,                       // Number of bits in data
    //parameter initfile = "screentest_smem.txt"  // Name of file with initial values
    //)(
    //input wire clock,
    //input wire wr,                             // WriteEnable:  if wr==1, data is written into mem
    //input wire [$clog2(Nloc)-1 : 0] ReadAddr1, ReadAddr2, WriteAddr, // 3 addresses, two for reading and one for writing
    //input wire [Dbits-1 : 0] WriteData,          // Data for writing into memory (if wr==1)
    //output logic [Dbits-1 : 0] ReadData1, ReadData2 // 2 output ports
    screenmem #(sm_locations, char_bits, screenmem_init) sm (
         .clock(clk), 
         .wr(smem_wr), 
         .ReadAddr1(screen_readaddr1), 
         .ReadAddr2(screen_readaddr2), 
         .WriteAddr(screen_writeaddr), 
         .WriteData(screen_writedata), 
         .ReadData1(screen_readdata1), 
         .ReadData2(screen_readdata2)
     );

endmodule
