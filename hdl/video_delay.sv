`timescale 1ps/1ps

module video_delay #()(
    input logic clk,
    input logic resetn,

    input logic btn_up,
    input logic btn_down,
    input logic btn_left,
    input logic btn_right,

    output logic [7:0] sevens_ca,
    output logic [7:0] sevens_an,

    output logic dvi_ck,
    output logic dvi_de,
    output logic dvi_vs,
    output logic dvi_hs,
    output logic [11:0] dvi_d,

    input logic sensor,
    output logic [15:0] led);

    logic dvi_resetn;
    logic dvi_locked;
    logic dvi_clk;
    dvi_clock the_dvi_clock(
        .resetn(resetn),
        .locked(dvi_locked),
        .clk_in(clk),
        .clk_out(dvi_clk));

    logic dvi_clk_delayed;
    dvi_clock_delayed the_dvi_clock_delayed(
        .resetn(resetn),
        .clk_in(dvi_clk),
        .clk_out(dvi_clk_delayed));

    logic btn_sync_up;
    logic btn_sync_down;
    logic btn_sync_left;
    logic btn_sync_right;
    synchronizer the_btn_up_synchronizer(
        .clk(clk),
        .resetn(resetn),
        .signal_in(btn_up),
        .signal_out(btn_sync_up));

    synchronizer the_btn_down_synchronizer(
        .clk(clk),
        .resetn(resetn),
        .signal_in(btn_down),
        .signal_out(btn_sync_down));

    synchronizer the_btn_left_synchronizer(
        .clk(clk),
        .resetn(resetn),
        .signal_in(btn_left),
        .signal_out(btn_sync_left));

    synchronizer the_btn_right_synchronizer(
        .clk(clk),
        .resetn(resetn),
        .signal_in(btn_right),
        .signal_out(btn_sync_right));

    logic [7:0] segments[8];
    sevens the_sevens(
        .clk(clk),
        .resetn(resetn),
        .segments(segments),
        .ca(sevens_ca),
        .an(sevens_an));

    logic [3:0] pattern;
    pattern_selector the_pattern_selector(
        .clk(clk),
        .resetn(resetn),
        .btn_up(btn_sync_up),
        .btn_down(btn_sync_down),
        .btn_left(btn_sync_left),
        .btn_right(btn_sync_right),
        .pattern(pattern));

    logic [7:0] pattern_segment;
    seven_pattern the_seven_pattern(
        .pattern(pattern),
        .ca(pattern_segment));

    logic dvi_enable;
    logic dvi_tick;
    dvi_driver the_dvi_driver(
        .clk(dvi_clk),
        .clk_delayed(dvi_clk_delayed),
        .resetn(resetn),
        .ready(dvi_locked),
        .dvi_ck(dvi_ck),
        .dvi_de(dvi_de),
        .dvi_vs(dvi_vs),
        .dvi_hs(dvi_hs),
        .dvi_d(dvi_d),
        .enable(dvi_enable),
        .pattern(pattern),
        .tick(dvi_tick));

    logic sensor_sync;
    synchronizer the_sensor_synchronizer(
        .clk(clk),
        .resetn(resetn),
        .signal_in(sensor),
        .signal_out(sensor_sync));

    logic [7:0] timer_segments[4];
    timer the_timer(
        .clk(clk),
        .resetn(resetn),
        .enable(dvi_enable),
        .send(dvi_tick),
        .receive(sensor_sync),
        .segments(timer_segments));

    always_comb begin
        led = sensor_sync ? '1 : '0;
        segments = '{
            timer_segments[0],
            timer_segments[1],
            timer_segments[2],
            timer_segments[3],
            8'd0,
            8'd0,
            8'd0,
            pattern_segment
        };
    end
endmodule
