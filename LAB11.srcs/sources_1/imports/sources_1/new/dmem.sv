`timescale 1ns / 1ps
`default_nettype none
//dmem #(32, 32, 32, dmem_init) dmem(clk, mem_wr, mem_addr, mem_writedata, mem_readdata);

module dmem #(
    parameter Abits = 32,
    parameter Nloc = 32,
    parameter Dbits = 32,
    parameter initfile = "dmem.txt"
    )(
    input wire clock,
    input wire mem_wr,
    input wire [Abits-1 : 0] mem_addr,
    input wire [Dbits-1 : 0] mem_writedata, 
    output logic [Dbits-1 : 0] mem_readdata 
    );
    
    logic [Dbits-1:0] dm [Nloc-1:0];
    initial $readmemh(initfile, dm, 0, Nloc-1);

    always_ff @(posedge clock)                   // Memory write: only when wr==1, and only at posedge clock
        if(mem_wr)
            dm[ mem_addr>>2 ] <= mem_writedata;
         
    assign mem_readdata = dm[mem_addr>>2];
    
endmodule