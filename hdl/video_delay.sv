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

    logic [7:0] segments[8];
    sevens the_sevens(
        .clk(clk),
        .resetn(resetn),
        .segments(segments),
        .ca(sevens_ca),
        .an(sevens_an));

    dvi_driver the_dvi_driver(
        .clk(dvi_clk),
        .clk_delayed(dvi_clk_delayed),
        .resetn(resetn),
        .ready(dvi_locked),
        .dvi_ck(dvi_ck),
        .dvi_de(dvi_de),
        .dvi_vs(dvi_vs),
        .dvi_hs(dvi_hs),
        .dvi_d(dvi_d));

    logic light_on;
    light_sensor the_light_sensor(
        .clk(clk),
        .resetn(resetn),
        .sensor(sensor),
        .on(light_on));

    sevens_demo the_sevens_demo(
        .clk(clk),
        .resetn(resetn),
        .btn_up(btn_up),
        .btn_down(btn_down),
        .btn_left(btn_left),
        .btn_right(btn_right),
        .segments(segments));

    always_comb begin
        led = light_on ? '1 : '0;
    end
endmodule
