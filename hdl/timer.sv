`timescale 1ps/1ps

module timer #()(
    input logic clk,
    input logic resetn,

    output logic enable,
    input logic send,
    input logic receive,

    output logic [7:0] segments[4]);

    localparam PERIOD = 10_000;
    localparam PAUSE = 10_000_000;

    logic enable_next;
    logic [7:0] segments_next[4];

    typedef enum logic [1:0] {
        SENDING,
        RECEIVING,
        PAUSING
    } state_e;

    state_e state;
    state_e state_next;

    logic [$clog2(PERIOD)-1:0] count;
    logic [$clog2(PERIOD)-1:0] count_next;

    logic [$clog2(PAUSE)-1:0] pause;
    logic [$clog2(PAUSE)-1:0] pause_next;

    logic [3:0] measurement[4];
    logic [3:0] measurement_next[4];

    logic send_sync;
    synchronizer the_send_synchronizer(
        .clk(clk),
        .resetn(resetn),
        .signal_in(send),
        .signal_out(send_sync));

    logic receive_debounce;
    logic receive_debouncing;
    debouncer #(
        .PERIOD(10000))
        the_receive_debouncer(
            .clk(clk),
            .resetn(resetn),
            .signal_in(receive),
            .signal_out(receive_debounce),
            .debouncing(receive_debouncing));

    logic [7:0] segment_0;
    seven_decimal the_decimal_0(
        .decimal(measurement[0]),
        .point(1'b0),
        .ca(segment_0));

    logic [7:0] segment_1;
    seven_decimal the_decimal_1(
        .decimal(measurement[1]),
        .point(1'b1),
        .ca(segment_1));

    logic [7:0] segment_2;
    seven_decimal the_decimal_2(
        .decimal(measurement[2]),
        .point(1'b0),
        .ca(segment_2));

    logic [7:0] segment_3;
    seven_decimal the_decimal_3(
        .decimal(measurement[3]),
        .point(1'b0),
        .ca(segment_3));

    always_comb begin
        enable_next = enable;
        for (int i = 0; i < 4; i += 1) begin
            segments_next[i] = segments[i];
        end
        state_next = state;
        count_next = count;
        pause_next = pause;
        for (int i = 0; i < 4; i += 1) begin
            measurement_next[i] = measurement[i];
        end

        case (state)
            SENDING: begin
                if (receive_debounce || receive_debouncing) begin
                    enable_next = '0;
                end
                else begin
                    enable_next = '1;
                    if (send_sync) begin
                        state_next = RECEIVING;
                        count_next = '0;
                        measurement_next = '{default: 8'h0};
                    end
                end
            end

            RECEIVING: begin
                if (receive_debounce) begin
                    enable_next = '0;
                    segments_next[0] = segment_0;
                    segments_next[1] = segment_1;
                    segments_next[2] = segment_2;
                    segments_next[3] = segment_3;
                    state_next = PAUSING;
                    pause_next = '0;
                end
                else begin
                    if (count == PERIOD - 1) begin
                        count_next = '0;
                        if (measurement[0] == 4'd9) begin
                            measurement_next[0] = '0;
                            if (measurement[1] == 4'd9) begin
                                measurement_next[1] = '0;
                                if (measurement[2] == 4'd9) begin
                                    measurement_next[2] = '0;
                                    if (measurement[3] == 4'd9) begin
                                        measurement_next = '{default: 4'd9};
                                    end
                                    else begin
                                        measurement_next[3] = measurement[3] + 1;
                                    end
                                end
                                else begin
                                    measurement_next[2] = measurement[2] + 1;
                                end
                            end
                            else begin
                                measurement_next[1] = measurement[1] + 1;
                            end
                        end
                        else begin
                            measurement_next[0] = measurement[0] + 1;
                        end
                    end
                    else begin
                        count_next = count + 1;
                    end
                end
            end

            PAUSING: begin
                if (pause == PAUSE - 1) begin
                    state_next = SENDING;
                end
                else begin
                    pause_next = pause + 1;
                end
            end

            default: ;
        endcase
    end

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            enable <= '0;
            segments <= '{default: 8'h0};
            state <= SENDING;
            count <= '0;
            pause <= '0;
            measurement <= '{default: 8'h0};
        end
        else begin
            enable <= enable_next;
            for (int i = 0; i < 4; i += 1) begin
                segments[i] <= segments_next[i];
            end
            state <= state_next;
            count <= count_next;
            pause <= pause_next;
            for (int i = 0; i < 4; i += 1) begin
                measurement[i] <= measurement_next[i];
            end
        end
    end
endmodule
