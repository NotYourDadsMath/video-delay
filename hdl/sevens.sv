`timescale 1ps/1ps

module sevens #()(
    input logic clk,
    input logic resetn,

    input logic [7:0] segments[8],

    output logic [7:0] ca,
    output logic [7:0] an);

    localparam PERIOD = 12500;

    logic [7:0] ca_next;
    logic [7:0] an_next;

    logic [$clog2(PERIOD)-1:0] count;
    logic [$clog2(PERIOD)-1:0] count_next;

    logic [2:0] segment;
    logic [2:0] segment_next;

    always_comb begin
        ca_next = ~segments[segment];
        an_next = ~{8'h1 << segment};

        count_next = count;
        segment_next = segment;

        if (count == PERIOD - 1) begin
            count_next = '0;
            segment_next = segment + 1;
        end
        else begin
            count_next = count + 1;
        end
    end

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            ca <= '1;
            an <= '1;
            count <= '0;
            segment <= '0;
        end
        else begin
            ca <= ca_next;
            an <= an_next;
            count <= count_next;
            segment <= segment_next;
        end
    end
endmodule
