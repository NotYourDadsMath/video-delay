`timescale 1ps/1ps

module sevens_demo #()(
    input logic clk,
    input logic resetn,

    input logic btn_up,
    input logic btn_down,
    input logic btn_left,
    input logic btn_right,

    output logic [7:0] segments[8]);

    logic [3:0] digits[8];
    logic [3:0] digits_next[8];

    logic [2:0] cursor;
    logic [2:0] cursor_next;

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
            .signal_out(up));

    debouncer #(
        .HOLD("FALSE"))
        the_down_debouncer(
            .clk(clk),
            .resetn(resetn),
            .signal_in(btn_down),
            .signal_out(down));

    debouncer #(
        .HOLD("FALSE"))
        the_left_debouncer(
            .clk(clk),
            .resetn(resetn),
            .signal_in(btn_left),
            .signal_out(left));

    debouncer #(
        .HOLD("FALSE"))
        the_right_debouncer(
            .clk(clk),
            .resetn(resetn),
            .signal_in(btn_right),
            .signal_out(right));

    genvar i;
    generate
        for (i = 0; i < 8; i += 1) begin
            seven_decimal the_seven_decimal(
                .decimal(digits[i]),
                .point(1'b0),
                .ca(segments[i]));
        end
    endgenerate

    always_comb begin
        for (int i = 0; i < 8 ; i += 1) begin
            digits_next[i] = digits[i];
        end
        cursor_next = cursor;

        if (left) begin
            cursor_next = cursor + 1;
        end
        else if (right) begin
            cursor_next = cursor - 1;
        end
        else if (up) begin
            digits_next[cursor] = (
                digits[cursor] == 4'd9 ?
                    '0 :
                    digits[cursor] + 1);
        end
        else if (down) begin
            digits_next[cursor] = (
                digits[cursor] == 4'd0 ?
                    4'd9 :
                    digits[cursor] - 1);
        end
    end

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            digits <= '{default: 8'h0};
            cursor <= '0;
        end
        else begin
            for (int i = 0; i < 8; i += 1) begin
                digits[i] <= digits_next[i];
            end
            cursor <= cursor_next;
        end
    end
endmodule
