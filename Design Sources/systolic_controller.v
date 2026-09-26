//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11.09.2026
// Design Name:
// Module Name: systolic_controller
// Project Name:
// Target Devices: xc7a100tcsg324-1
//
// Description:
//              Controller for 4x4 INT8 Systolic Array
//
//              Matrix dimensions:
//
//                  W = 16 x 32
//                  X = 32 x 12544
//                  Y = 16 x 12544
//
//              Tiling:
//
//                  M tiles = 4
//                  K tiles = 8
//                  N tiles = 3136
//
//              Systolic pipeline timing:
//
//                  Compute cycles : 0 - 6
//                  Flush cycles   : 7 - 9
//                  DRAIN cycles   : 4
//
//              IMPORTANT:
//              The memories are synchronous. Therefore the final
//              memory value must be captured when the load counter
//              reaches 16.
//
//              The previous version did not capture [3][3] because
//              the counter==16 condition bypassed the case statement.
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module systolic_controller (

    input wire clk,
    input wire rst,
    input wire start,

    // =========================================================
    // MEMORY DATA
    // =========================================================

    input wire signed [7:0] weight_data,
    input wire signed [7:0] input_data,

    // =========================================================
    // MEMORY CONTROL
    // =========================================================

    output reg weight_en,
    output reg input_en,

    output reg [8:0] weight_addr,
    output reg [18:0] input_addr,

    // =========================================================
    // SYSTOLIC ARRAY CONTROL
    // =========================================================

    output reg enable,
    output reg clear_acc,

    // =========================================================
    // A INPUTS
    // =========================================================

    output reg signed [7:0] a0,
    output reg signed [7:0] a1,
    output reg signed [7:0] a2,
    output reg signed [7:0] a3,

    // =========================================================
    // B INPUTS
    // =========================================================

    output reg signed [7:0] b0,
    output reg signed [7:0] b1,
    output reg signed [7:0] b2,
    output reg signed [7:0] b3,

    // =========================================================
    // COMPLETION
    // =========================================================

    output reg done
);

    // =========================================================
    // STATES
    // =========================================================

    localparam IDLE      = 4'd0;
    localparam LOAD_W    = 4'd1;
    localparam LOAD_X    = 4'd2;
    localparam CLEAR     = 4'd3;
    localparam COMPUTE   = 4'd4;
    localparam DRAIN     = 4'd5;
    localparam NEXT_TILE = 4'd6;
    localparam FINISH    = 4'd7;

    reg [3:0] state;

    // =========================================================
    // TILE COUNTERS
    // =========================================================

    reg [1:0]  m_tile;
    reg [2:0]  k_tile;
    reg [11:0] n_tile;

    // =========================================================
    // LOAD COUNTERS
    // =========================================================

    reg [4:0] load_w_count;
    reg [4:0] load_x_count;

    // =========================================================
    // COMPUTE COUNTER
    //
    // 0-6 = useful data
    // 7-9 = zero flush
    //
    // =========================================================

    reg [3:0] compute_count;

    // =========================================================
    // DRAIN COUNTER
    // =========================================================

    reg [2:0] drain_count;

    // =========================================================
    // REGISTERED MEMORY BASE ADDRESSES
    // =========================================================

    reg [18:0] input_k_base;
    reg [18:0] input_n_base;

    reg [8:0] weight_base;

    // =========================================================
    // LOCAL TILES
    // =========================================================

    reg signed [7:0] w_tile [0:3][0:3];
    reg signed [7:0] x_tile [0:3][0:3];

    // =========================================================
    // ADDRESS OFFSETS
    // =========================================================

    reg [8:0]  weight_offset;
    reg [18:0] input_offset;


    // =========================================================
    // COMBINATIONAL OUTPUT LOGIC
    // =========================================================

    always @(*) begin

        // -----------------------------------------------------
        // DEFAULT VALUES
        // -----------------------------------------------------

        weight_en = 1'b0;
        input_en  = 1'b0;

        weight_addr = weight_base;
        input_addr  = input_k_base + input_n_base;

        enable    = 1'b0;
        clear_acc = 1'b0;

        a0 = 8'sd0;
        a1 = 8'sd0;
        a2 = 8'sd0;
        a3 = 8'sd0;

        b0 = 8'sd0;
        b1 = 8'sd0;
        b2 = 8'sd0;
        b3 = 8'sd0;

        done = 1'b0;

        // =====================================================
        // WEIGHT MEMORY OFFSETS
        // =====================================================

        case (load_w_count)

            5'd0:  weight_offset = 9'd0;
            5'd1:  weight_offset = 9'd1;
            5'd2:  weight_offset = 9'd2;
            5'd3:  weight_offset = 9'd3;

            5'd4:  weight_offset = 9'd32;
            5'd5:  weight_offset = 9'd33;
            5'd6:  weight_offset = 9'd34;
            5'd7:  weight_offset = 9'd35;

            5'd8:  weight_offset = 9'd64;
            5'd9:  weight_offset = 9'd65;
            5'd10: weight_offset = 9'd66;
            5'd11: weight_offset = 9'd67;

            5'd12: weight_offset = 9'd96;
            5'd13: weight_offset = 9'd97;
            5'd14: weight_offset = 9'd98;
            5'd15: weight_offset = 9'd99;

            default:
                weight_offset = 9'd0;

        endcase

        // =====================================================
        // INPUT MEMORY OFFSETS
        // =====================================================

        case (load_x_count)

            5'd0:
                input_offset = 19'd0;

            5'd1:
                input_offset = 19'd1;

            5'd2:
                input_offset = 19'd2;

            5'd3:
                input_offset = 19'd3;

            5'd4:
                input_offset = 19'd12544;

            5'd5:
                input_offset = 19'd12545;

            5'd6:
                input_offset = 19'd12546;

            5'd7:
                input_offset = 19'd12547;

            5'd8:
                input_offset = 19'd25088;

            5'd9:
                input_offset = 19'd25089;

            5'd10:
                input_offset = 19'd25090;

            5'd11:
                input_offset = 19'd25091;

            5'd12:
                input_offset = 19'd37632;

            5'd13:
                input_offset = 19'd37633;

            5'd14:
                input_offset = 19'd37634;

            5'd15:
                input_offset = 19'd37635;

            default:
                input_offset = 19'd0;

        endcase

        // =====================================================
        // FINAL MEMORY ADDRESSES
        // =====================================================

        weight_addr =
            weight_base + weight_offset;

        input_addr =
            input_k_base +
            input_n_base +
            input_offset;

        // =====================================================
        // STATE OUTPUTS
        // =====================================================

        case (state)

            // =================================================
            // IDLE
            // =================================================

            IDLE: begin

                weight_en = 1'b0;
                input_en  = 1'b0;

                enable    = 1'b0;
                clear_acc = 1'b0;

            end

            // =================================================
            // LOAD WEIGHTS
            // =================================================

            LOAD_W: begin

                if (load_w_count < 5'd16)
                    weight_en = 1'b1;
                else
                    weight_en = 1'b0;

            end

            // =================================================
            // LOAD INPUT
            // =================================================

            LOAD_X: begin

                if (load_x_count < 5'd16)
                    input_en = 1'b1;
                else
                    input_en = 1'b0;

            end

            // =================================================
            // CLEAR
            // =================================================

            CLEAR: begin

                enable    = 1'b0;
                clear_acc = 1'b1;

            end

            // =================================================
            // COMPUTE
            // =================================================

            COMPUTE: begin

                enable    = 1'b1;
                clear_acc = 1'b0;

                case (compute_count)

                    // -----------------------------------------
                    // CYCLE 0
                    // -----------------------------------------

                    4'd0: begin

                        a0 = w_tile[0][0];
                        a1 = 8'sd0;
                        a2 = 8'sd0;
                        a3 = 8'sd0;

                        b0 = x_tile[0][0];
                        b1 = 8'sd0;
                        b2 = 8'sd0;
                        b3 = 8'sd0;

                    end

                    // -----------------------------------------
                    // CYCLE 1
                    // -----------------------------------------

                    4'd1: begin

                        a0 = w_tile[0][1];
                        a1 = w_tile[1][0];
                        a2 = 8'sd0;
                        a3 = 8'sd0;

                        b0 = x_tile[1][0];
                        b1 = x_tile[0][1];
                        b2 = 8'sd0;
                        b3 = 8'sd0;

                    end

                    // -----------------------------------------
                    // CYCLE 2
                    // -----------------------------------------

                    4'd2: begin

                        a0 = w_tile[0][2];
                        a1 = w_tile[1][1];
                        a2 = w_tile[2][0];
                        a3 = 8'sd0;

                        b0 = x_tile[2][0];
                        b1 = x_tile[1][1];
                        b2 = x_tile[0][2];
                        b3 = 8'sd0;

                    end

                    // -----------------------------------------
                    // CYCLE 3
                    // -----------------------------------------

                    4'd3: begin

                        a0 = w_tile[0][3];
                        a1 = w_tile[1][2];
                        a2 = w_tile[2][1];
                        a3 = w_tile[3][0];

                        b0 = x_tile[3][0];
                        b1 = x_tile[2][1];
                        b2 = x_tile[1][2];
                        b3 = x_tile[0][3];

                    end

                    // -----------------------------------------
                    // CYCLE 4
                    // -----------------------------------------

                    4'd4: begin

                        a0 = 8'sd0;
                        a1 = w_tile[1][3];
                        a2 = w_tile[2][2];
                        a3 = w_tile[3][1];

                        b0 = 8'sd0;
                        b1 = x_tile[3][1];
                        b2 = x_tile[2][2];
                        b3 = x_tile[1][3];

                    end

                    // -----------------------------------------
                    // CYCLE 5
                    // -----------------------------------------

                    4'd5: begin

                        a0 = 8'sd0;
                        a1 = 8'sd0;
                        a2 = w_tile[2][3];
                        a3 = w_tile[3][2];

                        b0 = 8'sd0;
                        b1 = 8'sd0;
                        b2 = x_tile[3][2];
                        b3 = x_tile[2][3];

                    end

                    // -----------------------------------------
                    // CYCLE 6
                    // -----------------------------------------

                    4'd6: begin

                        a0 = 8'sd0;
                        a1 = 8'sd0;
                        a2 = 8'sd0;
                        a3 = w_tile[3][3];

                        b0 = 8'sd0;
                        b1 = 8'sd0;
                        b2 = 8'sd0;
                        b3 = x_tile[3][3];

                    end

                    // -----------------------------------------
                    // CYCLE 7 - FLUSH
                    // -----------------------------------------

                    4'd7: begin

                        a0 = 8'sd0;
                        a1 = 8'sd0;
                        a2 = 8'sd0;
                        a3 = 8'sd0;

                        b0 = 8'sd0;
                        b1 = 8'sd0;
                        b2 = 8'sd0;
                        b3 = 8'sd0;

                    end

                    // -----------------------------------------
                    // CYCLE 8 - FLUSH
                    // -----------------------------------------

                    4'd8: begin

                        a0 = 8'sd0;
                        a1 = 8'sd0;
                        a2 = 8'sd0;
                        a3 = 8'sd0;

                        b0 = 8'sd0;
                        b1 = 8'sd0;
                        b2 = 8'sd0;
                        b3 = 8'sd0;

                    end

                    // -----------------------------------------
                    // CYCLE 9 - FLUSH
                    // -----------------------------------------

                    4'd9: begin

                        a0 = 8'sd0;
                        a1 = 8'sd0;
                        a2 = 8'sd0;
                        a3 = 8'sd0;

                        b0 = 8'sd0;
                        b1 = 8'sd0;
                        b2 = 8'sd0;
                        b3 = 8'sd0;

                    end

                    // -----------------------------------------
                    // DEFAULT
                    // -----------------------------------------

                    default: begin

                        a0 = 8'sd0;
                        a1 = 8'sd0;
                        a2 = 8'sd0;
                        a3 = 8'sd0;

                        b0 = 8'sd0;
                        b1 = 8'sd0;
                        b2 = 8'sd0;
                        b3 = 8'sd0;

                    end

                endcase

            end

            // =================================================
            // DRAIN
            // =================================================

            DRAIN: begin

                enable    = 1'b0;
                clear_acc = 1'b0;

            end

            // =================================================
            // NEXT TILE
            // =================================================

            NEXT_TILE: begin

                enable    = 1'b0;
                clear_acc = 1'b0;

            end

            // =================================================
            // FINISH
            // =================================================

            FINISH: begin

                done = 1'b1;

            end

            default: begin

                enable    = 1'b0;
                clear_acc = 1'b0;

            end

        endcase

    end


    // =========================================================
    // SEQUENTIAL STATE MACHINE
    // =========================================================

    always @(posedge clk) begin

        // =====================================================
        // RESET
        // =====================================================

        if (rst) begin

            state <= IDLE;

            m_tile <= 2'd0;
            k_tile <= 3'd0;
            n_tile <= 12'd0;

            load_w_count <= 5'd0;
            load_x_count <= 5'd0;

            compute_count <= 4'd0;
            drain_count   <= 3'd0;

            input_k_base <= 19'd0;
            input_n_base <= 19'd0;

            weight_base <= 9'd0;

            // -------------------------------------------------
            // INITIALIZE WEIGHT TILE
            // -------------------------------------------------

            w_tile[0][0] <= 8'sd0;
            w_tile[0][1] <= 8'sd0;
            w_tile[0][2] <= 8'sd0;
            w_tile[0][3] <= 8'sd0;

            w_tile[1][0] <= 8'sd0;
            w_tile[1][1] <= 8'sd0;
            w_tile[1][2] <= 8'sd0;
            w_tile[1][3] <= 8'sd0;

            w_tile[2][0] <= 8'sd0;
            w_tile[2][1] <= 8'sd0;
            w_tile[2][2] <= 8'sd0;
            w_tile[2][3] <= 8'sd0;

            w_tile[3][0] <= 8'sd0;
            w_tile[3][1] <= 8'sd0;
            w_tile[3][2] <= 8'sd0;
            w_tile[3][3] <= 8'sd0;

            // -------------------------------------------------
            // INITIALIZE INPUT TILE
            // -------------------------------------------------

            x_tile[0][0] <= 8'sd0;
            x_tile[0][1] <= 8'sd0;
            x_tile[0][2] <= 8'sd0;
            x_tile[0][3] <= 8'sd0;

            x_tile[1][0] <= 8'sd0;
            x_tile[1][1] <= 8'sd0;
            x_tile[1][2] <= 8'sd0;
            x_tile[1][3] <= 8'sd0;

            x_tile[2][0] <= 8'sd0;
            x_tile[2][1] <= 8'sd0;
            x_tile[2][2] <= 8'sd0;
            x_tile[2][3] <= 8'sd0;

            x_tile[3][0] <= 8'sd0;
            x_tile[3][1] <= 8'sd0;
            x_tile[3][2] <= 8'sd0;
            x_tile[3][3] <= 8'sd0;

        end

        // =====================================================
        // NORMAL OPERATION
        // =====================================================

        else begin

            case (state)

                // =================================================
                // IDLE
                // =================================================

                IDLE: begin

                    if (start) begin

                        m_tile <= 2'd0;
                        k_tile <= 3'd0;
                        n_tile <= 12'd0;

                        input_k_base <= 19'd0;
                        input_n_base <= 19'd0;

                        weight_base <= 9'd0;

                        load_w_count <= 5'd0;
                        load_x_count <= 5'd0;

                        compute_count <= 4'd0;
                        drain_count   <= 3'd0;

                        state <= LOAD_W;

                    end

                end

                // =================================================
                // LOAD WEIGHTS
                // =================================================

                LOAD_W: begin

                    if (load_w_count == 5'd16) begin

                        // =================================================
                        // IMPORTANT FIX
                        //
                        // The synchronous memory output at this
                        // point contains the final requested value.
                        //
                        // Previously this value was never captured
                        // because the counter==16 branch skipped
                        // the case statement.
                        // =================================================

                        w_tile[3][3] <= weight_data;

                        load_w_count <= 5'd0;
                        load_x_count <= 5'd0;

                        state <= LOAD_X;

                    end

                    else begin

                        if (load_w_count > 5'd0) begin

                            case (load_w_count)

                                5'd1:
                                    w_tile[0][0] <= weight_data;

                                5'd2:
                                    w_tile[0][1] <= weight_data;

                                5'd3:
                                    w_tile[0][2] <= weight_data;

                                5'd4:
                                    w_tile[0][3] <= weight_data;

                                5'd5:
                                    w_tile[1][0] <= weight_data;

                                5'd6:
                                    w_tile[1][1] <= weight_data;

                                5'd7:
                                    w_tile[1][2] <= weight_data;

                                5'd8:
                                    w_tile[1][3] <= weight_data;

                                5'd9:
                                    w_tile[2][0] <= weight_data;

                                5'd10:
                                    w_tile[2][1] <= weight_data;

                                5'd11:
                                    w_tile[2][2] <= weight_data;

                                5'd12:
                                    w_tile[2][3] <= weight_data;

                                5'd13:
                                    w_tile[3][0] <= weight_data;

                                5'd14:
                                    w_tile[3][1] <= weight_data;

                                5'd15:
                                    w_tile[3][2] <= weight_data;

                                default: begin
                                end

                            endcase

                        end

                        load_w_count <= load_w_count + 1'b1;

                    end

                end

                // =================================================
                // LOAD INPUT
                // =================================================

                LOAD_X: begin

                    if (load_x_count == 5'd16) begin

                        // =================================================
                        // IMPORTANT FIX
                        //
                        // Capture the final X tile element.
                        // =================================================

                        x_tile[3][3] <= input_data;

                        load_x_count <= 5'd0;
                        compute_count <= 4'd0;
                        drain_count   <= 3'd0;

                        if (k_tile == 3'd0)
                            state <= CLEAR;
                        else
                            state <= COMPUTE;

                    end

                    else begin

                        if (load_x_count > 5'd0) begin

                            case (load_x_count)

                                5'd1:
                                    x_tile[0][0] <= input_data;

                                5'd2:
                                    x_tile[0][1] <= input_data;

                                5'd3:
                                    x_tile[0][2] <= input_data;

                                5'd4:
                                    x_tile[0][3] <= input_data;

                                5'd5:
                                    x_tile[1][0] <= input_data;

                                5'd6:
                                    x_tile[1][1] <= input_data;

                                5'd7:
                                    x_tile[1][2] <= input_data;

                                5'd8:
                                    x_tile[1][3] <= input_data;

                                5'd9:
                                    x_tile[2][0] <= input_data;

                                5'd10:
                                    x_tile[2][1] <= input_data;

                                5'd11:
                                    x_tile[2][2] <= input_data;

                                5'd12:
                                    x_tile[2][3] <= input_data;

                                5'd13:
                                    x_tile[3][0] <= input_data;

                                5'd14:
                                    x_tile[3][1] <= input_data;

                                5'd15:
                                    x_tile[3][2] <= input_data;

                                default: begin
                                end

                            endcase

                        end

                        load_x_count <= load_x_count + 1'b1;

                    end

                end

                // =================================================
                // CLEAR
                // =================================================

                CLEAR: begin

                    compute_count <= 4'd0;
                    drain_count   <= 3'd0;

                    state <= COMPUTE;

                end

                // =================================================
                // COMPUTE
                //
                // Cycles 0-9:
                //   0-6 = useful data
                //   7-9 = zero flush
                //
                // =================================================

                COMPUTE: begin

                    if (compute_count == 4'd9) begin

                        compute_count <= 4'd0;
                        drain_count   <= 3'd0;

                        state <= DRAIN;

                    end

                    else begin

                        compute_count <= compute_count + 1'b1;

                    end

                end

                // =================================================
                // DRAIN
                // =================================================

                DRAIN: begin

                    if (drain_count == 3'd3) begin

                        drain_count <= 3'd0;

                        state <= NEXT_TILE;

                    end

                    else begin

                        drain_count <= drain_count + 1'b1;

                    end

                end

                // =================================================
                // NEXT TILE
                // =================================================

                NEXT_TILE: begin

                    // -------------------------------------------------
                    // NEXT K TILE
                    // -------------------------------------------------

                    if (k_tile < 3'd7) begin

                        k_tile <= k_tile + 1'b1;

                        // Move X by 4 rows.
                        input_k_base <=
                            input_k_base + 19'd50176;

                        // Move W by 4 columns.
                        weight_base <=
                            weight_base + 9'd4;

                        state <= LOAD_W;

                    end

                    // -------------------------------------------------
                    // NEXT N TILE
                    // -------------------------------------------------

                    else if (n_tile < 12'd3135) begin

                        k_tile <= 3'd0;

                        n_tile <= n_tile + 1'b1;

                        input_k_base <= 19'd0;

                        // Move to next group of 4 columns.
                        input_n_base <=
                            input_n_base + 19'd4;

                        // Return W to beginning of current M tile.
                        case (m_tile)

                            2'd0:
                                weight_base <= 9'd0;

                            2'd1:
                                weight_base <= 9'd128;

                            2'd2:
                                weight_base <= 9'd256;

                            2'd3:
                                weight_base <= 9'd384;

                            default:
                                weight_base <= 9'd0;

                        endcase

                        state <= LOAD_W;

                    end

                    // -------------------------------------------------
                    // NEXT M TILE
                    // -------------------------------------------------

                    else if (m_tile < 2'd3) begin

                        m_tile <= m_tile + 1'b1;

                        k_tile <= 3'd0;
                        n_tile <= 12'd0;

                        input_k_base <= 19'd0;
                        input_n_base <= 19'd0;

                        case (m_tile)

                            2'd0:
                                weight_base <= 9'd128;

                            2'd1:
                                weight_base <= 9'd256;

                            2'd2:
                                weight_base <= 9'd384;

                            default:
                                weight_base <= 9'd0;

                        endcase

                        state <= LOAD_W;

                    end

                    // -------------------------------------------------
                    // ALL TILES COMPLETE
                    // -------------------------------------------------

                    else begin

                        state <= FINISH;

                    end

                end

                // =================================================
                // FINISH
                // =================================================

                FINISH: begin

                    state <= IDLE;

                end

                // =================================================
                // DEFAULT
                // =================================================

                default: begin

                    state <= IDLE;

                end

            endcase

        end

    end

endmodule