`timescale 1ns / 1ps

module input_memory (
    input wire              clk,
    input wire              en,
    input wire [18:0]       addr,
    output reg signed [7:0] data
);

    localparam DEPTH = 401408;

    reg signed [7:0] mem [0:DEPTH-1];

    initial begin
        $readmemh("input.mem", mem);
    end

    always @(posedge clk) begin
        if (en)
            data <= mem[addr];
    end

endmodule