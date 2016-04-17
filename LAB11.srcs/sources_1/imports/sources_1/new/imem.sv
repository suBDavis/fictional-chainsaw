`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/05/2016 05:32:39 PM
// Design Name: 
// Module Name: imem
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

// imem #(32, 32, 32, imem_init) imem(pc[31:0], instr);

module imem #(
    parameter Abits = 32, //number of address bits
    parameter Dbits = 32, //number of bits on the memory wires.
    parameter Nloc = 32,  //number of memory locations.
    parameter initfile="screentest_nopause_imem.txt" //memory initialization file
    )(
    input wire [Abits-1:0] pc, 
    output logic [Dbits-1:0] instr
    );
    
    logic [Dbits-1 : 0] im [Nloc-1 : 0];
    initial $readmemh(initfile, im, 0, Nloc-1);
    
    assign instr = im[pc>>2];
    
endmodule