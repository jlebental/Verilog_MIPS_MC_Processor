`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2022 06:19:42 PM
// Design Name: 
// Module Name: MCP_MUX2
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


module MCP_MUX2 #(parameter WL = 32)
             (input wire  MUX_SEL,
              input wire [WL - 1:0] Din0, Din1,
              output reg [WL - 1:0] Dout);

//I guess this is just a case statement controlled by the SEL
    always @(MUX_SEL, Din0, Din1)
    begin
        case(MUX_SEL)
            1'b0: Dout = Din0;
            1'b1: Dout = Din1;
        endcase
    end
endmodule
