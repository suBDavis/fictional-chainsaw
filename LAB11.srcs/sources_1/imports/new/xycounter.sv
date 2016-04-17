`timescale 1ns / 1ps
`default_nettype none

module xycounter #(parameter width=2, height=2)(
    input wire clock,
    input wire enable,
    output logic [$clog2(width)-1:0] x=0,
    output logic [$clog2(height)-1:0] y=0
    );
    
    always_ff @(posedge clock) 
        begin
        if (enable)
            begin
            if (y == height-1)
                begin
                if (x == width -1)
                    begin
                    x <= 0;
                    y <= 0;
                    end
                else
                    x <= x + 1;
                end
            else
                begin
                if (x == width -1)
                    begin
                    x <= 0;
                    y <= y + 1;
                    end
                else
                    x <= x + 1;
                end
            end
        end 
endmodule
