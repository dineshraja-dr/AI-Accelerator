`timescale 1ns / 1ps

module accelerator_top (
    input  wire clk,
    input  wire rst,
    input  wire start,
    output wire done,
output wire signed [31:0] result_checksum
);

    // =========================================================
    // Controller <-> Memory signals
    // =========================================================

    wire signed [7:0] weight_data;
    wire signed [7:0] input_data;

    wire weight_en;
    wire input_en;

    wire [8:0]  weight_addr;
    wire [18:0] input_addr;


    // =========================================================
    // Controller <-> Systolic Array signals
    // =========================================================

    wire enable;
    wire clear_acc;

    wire signed [7:0] a0;
    wire signed [7:0] a1;
    wire signed [7:0] a2;
    wire signed [7:0] a3;

    wire signed [7:0] b0;
    wire signed [7:0] b1;
    wire signed [7:0] b2;
    wire signed [7:0] b3;


    // =========================================================
    // Systolic Array outputs
    // =========================================================

    wire signed [31:0] result00;
    wire signed [31:0] result01;
    wire signed [31:0] result02;
    wire signed [31:0] result03;

    wire signed [31:0] result10;
    wire signed [31:0] result11;
    wire signed [31:0] result12;
    wire signed [31:0] result13;

    wire signed [31:0] result20;
    wire signed [31:0] result21;
    wire signed [31:0] result22;
    wire signed [31:0] result23;

    wire signed [31:0] result30;
    wire signed [31:0] result31;
    wire signed [31:0] result32;
    wire signed [31:0] result33;


    // =========================================================
    // INPUT MEMORY
    //
    // X = 32 x 12544
    // Total = 401408 INT8 values
    // =========================================================

    input_memory input_mem (
        .clk(clk),
        .en(input_en),
        .addr(input_addr),
        .data(input_data)
    );


    // =========================================================
    // WEIGHT MEMORY
    //
    // W = 16 x 32
    // Total = 512 INT8 values
    // =========================================================

    weight_memory weight_mem (
        .clk(clk),
        .en(weight_en),
        .addr(weight_addr),
        .data(weight_data)
    );


    // =========================================================
    // SYSTOLIC CONTROLLER
    // =========================================================

    systolic_controller controller (
        .clk(clk),
        .rst(rst),
        .start(start),

        // Memory data
        .weight_data(weight_data),
        .input_data(input_data),

        // Memory control
        .weight_en(weight_en),
        .input_en(input_en),

        .weight_addr(weight_addr),
        .input_addr(input_addr),

        // Array control
        .enable(enable),
        .clear_acc(clear_acc),

        // Array inputs
        .a0(a0),
        .a1(a1),
        .a2(a2),
        .a3(a3),

        .b0(b0),
        .b1(b1),
        .b2(b2),
        .b3(b3),

        .done(done)
    );


    // =========================================================
    // 4x4 INT8 SYSTOLIC ARRAY
    // =========================================================

    systolic_4x4 array (
        .clk(clk),
        .rst(rst),

        .enable(enable),
        .clear_acc(clear_acc),

        .a0(a0),
        .a1(a1),
        .a2(a2),
        .a3(a3),

        .b0(b0),
        .b1(b1),
        .b2(b2),
        .b3(b3),

        .c00(result00),
        .c01(result01),
        .c02(result02),
        .c03(result03),

        .c10(result10),
        .c11(result11),
        .c12(result12),
        .c13(result13),

        .c20(result20),
        .c21(result21),
        .c22(result22),
        .c23(result23),

        .c30(result30),
        .c31(result31),
        .c32(result32),
        .c33(result33)
    );
    // =========================================================
// RESULT CHECKSUM
// Keeps systolic-array output observable
// =========================================================

assign result_checksum =
        result00 + result01 + result02 + result03 +
        result10 + result11 + result12 + result13 +
        result20 + result21 + result22 + result23 +
        result30 + result31 + result32 + result33;

endmodule