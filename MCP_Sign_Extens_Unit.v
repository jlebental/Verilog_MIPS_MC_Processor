`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2022 06:21:25 PM
// Design Name: 
// Module Name: MCP_Sign_Extens_Unit
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


module MCP_Sign_Extens_Unit #(parameter WL = 32)
                          (input wire [15:0] Imm,
                           output reg [WL - 1:0] Simm);
//this just makes a word named immediate the legnth of WL while keeping the sign right
    reg sign;
    reg [WL-1:0] i;
    
    always @(Imm)
    begin
        sign = Imm[15];
        Simm = Imm;
        for(i = 15; i < WL; i = i + 1) Simm[i] = sign;
    end

endmodule
