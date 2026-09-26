
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.09.2026 21:43:38
// Design Name: 
// Module Name: weight1
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
`timescale 1ns / 1ps

module weight_memory (
    input  wire              clk,
    input  wire              en,
    input  wire [8:0]        addr,
    output reg signed [7:0]  data
);

    localparam DEPTH = 512;

    reg signed [7:0] mem [0:DEPTH-1];

    initial begin
        $readmemh("weights.mem", mem);
    end

    always @(posedge clk) begin
        if (en)
            data <= mem[addr];
    end

endmodule
