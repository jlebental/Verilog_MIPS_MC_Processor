`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2022 06:23:58 PM
// Design Name: 
// Module Name: MCP_MUX3
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


module MCP_MUX3 #(parameter WL = 32)
             (input wire [1:0] MUX_SEL,
              input wire [WL - 1:0] Din0, Din1, Din2,
              output reg [WL - 1:0] Dout);

//I guess this is just a case statement controlled by the SEL
    always @(MUX_SEL, Din0, Din1, Din2)
    begin
        case(MUX_SEL)
            2'b00: Dout = Din0;
            2'b01: Dout = Din1;
            2'b10: Dout = Din2;
        endcase
    end
endmodule
