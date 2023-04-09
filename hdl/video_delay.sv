`timescale 1ps/1ps

module video_delay #()(
    input logic clk,
    input logic resetn,

    input logic sensor,
    output logic [15:0] led);

    logic light_on;

    light_sensor the_light_sensor(
        .clk(clk),
        .resetn(resetn),
        .sensor(sensor),
        .on(light_on));

    always_comb begin
        led = light_on ? '1 : '0;
    end
endmodule
