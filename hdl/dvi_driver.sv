`timescale 1ps/1ps

module dvi_driver #()(
    input logic clk,
    input logic clk_delayed,
    input logic resetn,
    input logic ready,

    output logic dvi_ck,
    output logic dvi_de,
    output logic dvi_vs,
    output logic dvi_hs,
    output logic [11:0] dvi_d);

    localparam V_BACK_PORCH = 20;
    localparam V_ACTIVE = 720;
    localparam V_FRONT_PORCH = 5;
    localparam V_SYNC = 5;

    localparam H_BACK_PORCH = 220;
    localparam H_ACTIVE = 1280;
    localparam H_FRONT_PORCH = 110;
    localparam H_SYNC = 40;

    typedef enum logic [1:0] {
        STATE_BACK_PORCH,
        STATE_ACTIVE,
        STATE_FRONT_PORCH,
        STATE_SYNC
    } state_e;

    state_e v_state;
    state_e v_state_next;
    logic [$clog2(V_ACTIVE)-1:0] v_count;
    logic [$clog2(V_ACTIVE)-1:0] v_count_next;

    state_e h_state;
    state_e h_state_next;
    logic [$clog2(H_ACTIVE)-1:0] h_count;
    logic [$clog2(H_ACTIVE)-1:0] h_count_next;

    logic active;
    logic active_next;
    logic vsync;
    logic vsync_next;
    logic hsync;
    logic hsync_next;
    logic [23:0] data;
    logic [23:0] data_next;

    genvar i;
    generate
        for (i = 0; i < 12; i += 1) begin
            ODDR #(
                .DDR_CLK_EDGE("SAME_EDGE"),
                .INIT(1'b0),
                .SRTYPE("ASYNC"))
                the_dvi_d_oddr(
                    .Q(dvi_d[i]),
                    .C(clk),
                    .CE(ready),
                    .D1(data[i]),
                    .D2(data[i + 12]),
                    .R(!resetn),
                    .S(1'b0));
        end
    endgenerate

    ODDR #(
        .DDR_CLK_EDGE("SAME_EDGE"),
        .INIT(1'b0),
        .SRTYPE("ASYNC"))
        the_dvi_de_oddr(
            .Q(dvi_de),
            .C(clk),
            .CE(ready),
            .D1(active),
            .D2(active),
            .R(!resetn),
            .S(1'b0));

    ODDR #(
        .DDR_CLK_EDGE("SAME_EDGE"),
        .INIT(1'b0),
        .SRTYPE("ASYNC"))
        the_dvi_vs_oddr(
            .Q(dvi_vs),
            .C(clk),
            .CE(ready),
            .D1(vsync),
            .D2(vsync),
            .R(!resetn),
            .S(1'b0));

    ODDR #(
        .DDR_CLK_EDGE("SAME_EDGE"),
        .INIT(1'b0),
        .SRTYPE("ASYNC"))
        the_dvi_hs_oddr(
            .Q(dvi_hs),
            .C(clk),
            .CE(ready),
            .D1(hsync),
            .D2(hsync),
            .R(!resetn),
            .S(1'b0));

    ODDR #(
        .DDR_CLK_EDGE("SAME_EDGE"),
        .INIT(1'b0),
        .SRTYPE("ASYNC"))
        the_dvi_ck_oddr(
            .Q(dvi_ck),
            .C(clk_delayed),
            .CE(ready),
            .D1(1'b1),
            .D2(1'b0),
            .R(!resetn),
            .S(1'b0));

    always_comb begin
        v_state_next = v_state;
        v_count_next = v_count;
        h_state_next = h_state;
        h_count_next = h_count;
        active_next = active;
        vsync_next = vsync;
        hsync_next = hsync;
        data_next = data;

        if (ready) begin
            case (h_state)
                STATE_BACK_PORCH: begin
                    if (h_count == H_BACK_PORCH - 1) begin
                        h_state_next = STATE_ACTIVE;
                        h_count_next = '0;
                    end
                    else begin
                        h_count_next = h_count + 1;
                    end
                end

                STATE_ACTIVE: begin
                    if (h_count == H_ACTIVE - 1) begin
                        h_state_next = STATE_FRONT_PORCH;
                        h_count_next = '0;
                    end
                    else begin
                        h_count_next = h_count + 1;
                    end
                end

                STATE_FRONT_PORCH: begin
                    if (h_count == H_FRONT_PORCH - 1) begin
                        h_state_next = STATE_SYNC;
                        h_count_next = '0;
                    end
                    else begin
                        h_count_next = h_count + 1;
                    end
                end

                STATE_SYNC: begin
                    if (h_count == H_SYNC - 1) begin
                        h_state_next = STATE_BACK_PORCH;
                        h_count_next = '0;
                        case (v_state)
                            STATE_BACK_PORCH: begin
                                if (v_count == V_BACK_PORCH - 1) begin
                                    v_state_next = STATE_ACTIVE;
                                    v_count_next = '0;
                                end
                                else begin
                                    v_count_next = v_count + 1;
                                end
                            end

                            STATE_ACTIVE: begin
                                if (v_count == V_ACTIVE - 1) begin
                                    v_state_next = STATE_FRONT_PORCH;
                                    v_count_next = '0;
                                end
                                else begin
                                    v_count_next = v_count + 1;
                                end
                            end

                            STATE_FRONT_PORCH: begin
                                if (v_count == V_FRONT_PORCH - 1) begin
                                    v_state_next = STATE_SYNC;
                                    v_count_next = '0;
                                end
                                else begin
                                    v_count_next = v_count + 1;
                                end
                            end

                            STATE_SYNC: begin
                                if (v_count == V_SYNC - 1) begin
                                    v_state_next = STATE_BACK_PORCH;
                                    v_count_next = '0;
                                end
                                else begin
                                    v_count_next = v_count + 1;
                                end
                            end

                            default: ;
                        endcase
                    end
                    else begin
                        h_count_next = h_count + 1;
                    end
                end

                default: ;
            endcase

            active_next = v_state == STATE_ACTIVE && h_state == STATE_ACTIVE;
            vsync_next = v_state == STATE_SYNC;
            hsync_next = h_state == STATE_SYNC;
            data_next = (
                active_next ?
                    {
                        h_count[10:8] <= 1 ?
                            h_count[7:0] :
                            8'h0,

                        h_count[10:8] >= 1 && h_count[10:8] <= 3 ?
                            h_count[7:0] :
                            8'h0,

                        h_count[10:8] >= 3 ?
                            h_count[7:0] :
                            8'h0
                    } :
                    '0);
        end
    end

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            v_state <= STATE_BACK_PORCH;
            v_count <= '0;
            h_state <= STATE_BACK_PORCH;
            h_count <= '0;
            active <= '0;
            vsync <= '0;
            hsync <= '0;
            data <= '0;
        end
        else begin
            v_state <= v_state_next;
            v_count <= v_count_next;
            h_state <= h_state_next;
            h_count <= h_count_next;
            active <= active_next;
            vsync <= vsync_next;
            hsync <= hsync_next;
            data <= data_next;
        end
    end
endmodule
