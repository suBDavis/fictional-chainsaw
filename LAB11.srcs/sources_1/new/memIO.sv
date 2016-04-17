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
    parameter dmem_init = "dmem_init.txt",
    parameter screenmem_init = "screenmem_init.txt"
    )(
    input wire clk,
    //write flag
    input wire mem_wr,
    input wire [Dbits-1:0] mem_writedata, 
    output wire [Dbits-1:0] mem_readdata,
    //mem_addr
    input wire [Abits-1:0] mem_addr,
    //char_code
    output wire [char_bits-1:0] char_code,
    //screen_addr
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
    assign mem_readdata = (mem_code == 2'b10) ? { {(Dbits-char_bits){1'b0}}, screen_readdata1}
        : (mem_code == 2'b01) ? dmem_readdata
        : (mem_code == 2'b00) ? {(Dbits){1'b0}}
        : (mem_code == 2'b11) ? {(Dbits){1'bX}} // Not implemented yet!
        : {(Dbits){1'bX}};
        
    //Combinational logic for write
    assign dmem_wr = (mem_code == 2'b01 & mem_wr == 1'b1) ? 1'b1 : 1'b0;
    assign smem_wr = (mem_code == 2'b10 & mem_wr == 1'b1) ? 1'b1 : 1'b0;
        
    //TODO: FIX ALL THESE WIRES
    dmem #(Abits, Nloc, Dbits, dmem_init) dmem(clk, dmem_wr, dmem_addr, dmem_writedata, dmem_readdata);
    
    //TODO: FIX ALL THESE WIRES
    screenmem sm(clk, smem_wr, screen_readaddr1, screen_readaddr2, screen_writeaddr, screen_writedata, screen_readdata1, screen_readdata2);

endmodule
