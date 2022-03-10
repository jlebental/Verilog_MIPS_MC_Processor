`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2022 06:28:55 PM
// Design Name: 
// Module Name: MCP_OR_Gate
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


module MCP_OR_Gate (input wire in1, in2,
                output reg and_out);
    always @*
    begin
        and_out = in1 || in2;
    end
endmodule
