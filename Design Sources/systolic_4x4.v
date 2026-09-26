//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Design Name: 4x4 INT8 Systolic Array
// Module Name: systolic_4x4
//
// Description:
//              4x4 INT8 Systolic Array
//
//              A values propagate horizontally.
//              B values propagate vertically.
//
//              Each PE contains a pipelined INT8 MAC.
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module systolic_4x4 (

    input wire clk,
    input wire rst,
    input wire enable,
    input wire clear_acc,

    // =========================================================
    // A INPUTS
    // =========================================================

    input wire signed [7:0] a0,
    input wire signed [7:0] a1,
    input wire signed [7:0] a2,
    input wire signed [7:0] a3,

    // =========================================================
    // B INPUTS
    // =========================================================

    input wire signed [7:0] b0,
    input wire signed [7:0] b1,
    input wire signed [7:0] b2,
    input wire signed [7:0] b3,

    // =========================================================
    // OUTPUT ACCUMULATORS
    // =========================================================

    output wire signed [31:0] c00,
    output wire signed [31:0] c01,
    output wire signed [31:0] c02,
    output wire signed [31:0] c03,

    output wire signed [31:0] c10,
    output wire signed [31:0] c11,
    output wire signed [31:0] c12,
    output wire signed [31:0] c13,

    output wire signed [31:0] c20,
    output wire signed [31:0] c21,
    output wire signed [31:0] c22,
    output wire signed [31:0] c23,

    output wire signed [31:0] c30,
    output wire signed [31:0] c31,
    output wire signed [31:0] c32,
    output wire signed [31:0] c33

);

    // =========================================================
    // HORIZONTAL A CONNECTIONS
    // =========================================================

    wire signed [7:0] a01;
    wire signed [7:0] a02;
    wire signed [7:0] a03;

    wire signed [7:0] a11;
    wire signed [7:0] a12;
    wire signed [7:0] a13;

    wire signed [7:0] a21;
    wire signed [7:0] a22;
    wire signed [7:0] a23;

    wire signed [7:0] a31;
    wire signed [7:0] a32;
    wire signed [7:0] a33;


    // =========================================================
    // VERTICAL B CONNECTIONS
    // =========================================================

    wire signed [7:0] b10;
    wire signed [7:0] b20;
    wire signed [7:0] b30;

    wire signed [7:0] b11;
    wire signed [7:0] b21;
    wire signed [7:0] b31;

    wire signed [7:0] b12;
    wire signed [7:0] b22;
    wire signed [7:0] b32;

    wire signed [7:0] b13;
    wire signed [7:0] b23;
    wire signed [7:0] b33;


    // =========================================================
    // ROW 0
    // =========================================================

    pe_int8 pe00 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .clear_acc(clear_acc),
        .a_in(a0),
        .b_in(b0),
        .a_out(a01),
        .b_out(b10),
        .acc(c00)
    );

    pe_int8 pe01 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .clear_acc(clear_acc),
        .a_in(a01),
        .b_in(b1),
        .a_out(a02),
        .b_out(b11),
        .acc(c01)
    );

    pe_int8 pe02 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .clear_acc(clear_acc),
        .a_in(a02),
        .b_in(b2),
        .a_out(a03),
        .b_out(b12),
        .acc(c02)
    );

    pe_int8 pe03 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .clear_acc(clear_acc),
        .a_in(a03),
        .b_in(b3),
        .a_out(),
        .b_out(b13),
        .acc(c03)
    );


    // =========================================================
    // ROW 1
    // =========================================================

    pe_int8 pe10 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .clear_acc(clear_acc),
        .a_in(a1),
        .b_in(b10),
        .a_out(a11),
        .b_out(b20),
        .acc(c10)
    );

    pe_int8 pe11 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .clear_acc(clear_acc),
        .a_in(a11),
        .b_in(b11),
        .a_out(a12),
        .b_out(b21),
        .acc(c11)
    );

    pe_int8 pe12 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .clear_acc(clear_acc),
        .a_in(a12),
        .b_in(b12),
        .a_out(a13),
        .b_out(b22),
        .acc(c12)
    );

    pe_int8 pe13 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .clear_acc(clear_acc),
        .a_in(a13),
        .b_in(b13),
        .a_out(),
        .b_out(b23),
        .acc(c13)
    );


    // =========================================================
    // ROW 2
    // =========================================================

    pe_int8 pe20 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .clear_acc(clear_acc),
        .a_in(a2),
        .b_in(b20),
        .a_out(a21),
        .b_out(b30),
        .acc(c20)
    );

    pe_int8 pe21 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .clear_acc(clear_acc),
        .a_in(a21),
        .b_in(b21),
        .a_out(a22),
        .b_out(b31),
        .acc(c21)
    );

    pe_int8 pe22 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .clear_acc(clear_acc),
        .a_in(a22),
        .b_in(b22),
        .a_out(a23),
        .b_out(b32),
        .acc(c22)
    );

    pe_int8 pe23 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .clear_acc(clear_acc),
        .a_in(a23),
        .b_in(b23),
        .a_out(),
        .b_out(b33),
        .acc(c23)
    );


    // =========================================================
    // ROW 3
    // =========================================================

    pe_int8 pe30 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .clear_acc(clear_acc),
        .a_in(a3),
        .b_in(b30),
        .a_out(a31),
        .b_out(),
        .acc(c30)
    );

    pe_int8 pe31 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .clear_acc(clear_acc),
        .a_in(a31),
        .b_in(b31),
        .a_out(a32),
        .b_out(),
        .acc(c31)
    );

    pe_int8 pe32 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .clear_acc(clear_acc),
        .a_in(a32),
        .b_in(b32),
        .a_out(a33),
        .b_out(),
        .acc(c32)
    );

    pe_int8 pe33 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .clear_acc(clear_acc),
        .a_in(a33),
        .b_in(b33),
        .a_out(),
        .b_out(),
        .acc(c33)
    );

endmodule