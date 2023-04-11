`timescale 1ps/1ps

module pattern_selector #()(
    input logic clk,
    input logic resetn,

    input logic btn_up,
    input logic btn_down,
    input logic btn_left,
    input logic btn_right,

    output logic [3:0] pattern);

    logic [3:0] pattern_next;

    logic up;
    logic down;
    logic left;
    logic right;

    debouncer #(
        .HOLD("FALSE"))
        the_up_debouncer(
            .clk(clk),
            .resetn(resetn),
            .signal_in(btn_up),
            .signal_out(up),
            .debouncing());

    debouncer #(
        .HOLD("FALSE"))
        the_down_debouncer(
            .clk(clk),
            .resetn(resetn),
            .signal_in(btn_down),
            .signal_out(down),
            .debouncing());

    debouncer #(
        .HOLD("FALSE"))
        the_left_debouncer(
            .clk(clk),
            .resetn(resetn),
            .signal_in(btn_left),
            .signal_out(left),
            .debouncing());

    debouncer #(
        .HOLD("FALSE"))
        the_right_debouncer(
            .clk(clk),
            .resetn(resetn),
            .signal_in(btn_right),
            .signal_out(right),
            .debouncing());

    always_comb begin
        pattern_next = pattern;

        if (up) begin
            if (pattern > 2) begin
                pattern_next = pattern - 3;
            end
        end
        else if (down) begin
            if (pattern < 6) begin
                pattern_next = pattern + 3;
            end
        end
        else if (left) begin
            case (pattern)
                4'd1,
                4'd2,
                4'd4,
                4'd5,
                4'd7,
                4'd8: pattern_next = pattern - 1;
                default: ;
            endcase
        end
        else if (right) begin
            case (pattern)
                4'd0,
                4'd1,
                4'd3,
                4'd4,
                4'd6,
                4'd7: pattern_next = pattern + 1;
                default: ;
            endcase
        end
    end

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            pattern <= 4'd4;
        end
        else begin
            pattern <= pattern_next;
        end
    end
endmodule
