`timescale 1ns / 1ps
`default_nettype none
`include "display640x480.sv"

module vgatimer(
    input wire clk,
    output wire hsync, vsync, activevideo,
    output wire [`xbits-1:0] x,
    output wire [`ybits-1:0] y

    );
    
    logic [1:0] clk_count = 0;
    always_ff @(posedge clk)
        clk_count <= clk_count + 2'b01;
    
    logic Every2ndTick, Every4thTick;
    assign Every2ndTick = (clk_count[0] == 1'b1);
    assign Every4thTick = (clk_count[1:0] == 2'b11);
    
    //25 MHZ counter
    xycounter #(`WholeLine, `WholeFrame) xy(clk, Every4thTick, x, y);
    
    assign hsync = (x >= `hSyncStart & x <= `hSyncEnd) ? 0 : 1;
    assign vsync = (y >= `vSyncStart & y <= `vSyncEnd) ? 0 : 1;
    assign activevideo = (x < `hVisible && y < `vVisible) ? 1 : 0;
    
endmodule
