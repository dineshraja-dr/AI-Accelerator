
`timescale 1ns / 1ps
module accelerator_top_tb;

    reg clk;
    reg rst;
    reg start;

    wire done;
    wire signed [31:0] result_checksum;

    // =========================================================
    // DUT
    // =========================================================

    accelerator_top uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .result_checksum(result_checksum)
    );

    // =========================================================
    // CLOCK
    // 100 MHz = 10 ns period
    // =========================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // =========================================================
    // TEST
    // =========================================================

    initial begin

        rst   = 1'b1;
        start = 1'b0;

        // Reset
        #20;

        rst = 1'b0;

        // Start accelerator
        #20;
        start = 1'b1;

        #10;
        start = 1'b0;

        // Wait until accelerator finishes
        wait(done == 1'b1);

        #10;

        $display("========================================");
        $display("ACCELERATOR TEST COMPLETED");
        $display("========================================");
        $display("DONE     = %b", done);
        $display("CHECKSUM = %d", result_checksum);
        $display("CHECKSUM HEX = %h", result_checksum);
        $display("========================================");

        #20;
        $display("================================");
$display("RTL FINAL 4x4 TILE");
$display("%0d %0d %0d %0d", uut.result00, uut.result01, uut.result02, uut.result03);
$display("%0d %0d %0d %0d", uut.result10, uut.result11, uut.result12, uut.result13);
$display("%0d %0d %0d %0d", uut.result20, uut.result21, uut.result22, uut.result23);
$display("%0d %0d %0d %0d", uut.result30, uut.result31, uut.result32, uut.result33);
$display("RTL CHECKSUM = %0d", uut.result_checksum);

$display("================================");

        $finish;
    end

endmodule