`timescale 1ns / 1ps

module pe_int8 (

    input wire clk,
    input wire rst,
    input wire enable,
    input wire clear_acc,

    input wire signed [7:0] a_in,
    input wire signed [7:0] b_in,

    output reg signed [7:0] a_out,
    output reg signed [7:0] b_out,

    output reg signed [31:0] acc

);

    reg signed [15:0] product_reg;
    reg product_valid;

    wire signed [15:0] product;

    assign product = a_in * b_in;


    always @(posedge clk) begin

        if (rst) begin

            a_out         <= 8'sd0;
            b_out         <= 8'sd0;
            product_reg   <= 16'sd0;
            product_valid <= 1'b0;
            acc           <= 32'sd0;
        end

        else begin

            // =================================================
            // DEBUG
            // =================================================

            if ((a_in == 8'sd16) && (b_in == 8'sd16)) begin

                $display("");
                $display("******** PE DEBUG: 16 x 16 ********");
                $display("TIME          = %0t", $time);
                $display("a_in          = %0d", a_in);
                $display("b_in          = %0d", b_in);
                $display("product       = %0d", product);
                $display("product_reg   = %0d", product_reg);
                $display("product_valid = %0d", product_valid);
                $display("acc BEFORE    = %0d", acc);
                $display("enable        = %0d", enable);
                $display("clear_acc     = %0d", clear_acc);
                $display("************************************");
                $display("");

            end


            // =================================================
            // ACCUMULATION
            // =================================================

            if (clear_acc) begin

                acc <= 32'sd0;

            end

            else if (product_valid) begin

                acc <= acc +
                       {{16{product_reg[15]}}, product_reg};

            end


            // =================================================
            // MULTIPLY + PROPAGATION
            // =================================================

            if (enable) begin

                a_out <= a_in;
                b_out <= b_in;

                product_reg <= product;

                product_valid <= 1'b1;

            end

            else begin

                a_out <= 8'sd0;
                b_out <= 8'sd0;

                product_valid <= 1'b0;

            end

        end

    end

endmodule