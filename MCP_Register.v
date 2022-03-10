`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2022 06:13:52 PM
// Design Name: 
// Module Name: MCP_Register
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


module MCP_Register #(parameter WL = 32)
                            (input wire CLK, RST, EN,
                             input wire [WL - 1:0] reg_in,
                             output reg [WL - 1:0] reg_out);

    always @(posedge CLK) //or RST) this RST in the sensitivity list created the worst boundary case error ever
    begin
        if(RST) reg_out <= 0;
        else
        begin
            if(EN) reg_out <= reg_in;
        end
    end

endmodule
