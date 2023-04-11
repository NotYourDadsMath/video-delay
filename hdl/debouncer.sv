`timescale 1ps/1ps

module debouncer #(
    parameter HOLD="TRUE",
    parameter PERIOD=1000000)(

    input logic clk,
    input logic resetn,

    input logic signal_in,
    output logic signal_out,
    output logic debouncing);

    typedef enum logic [0:0] {
        READY,
        DEBOUNCING
    } state_e;

    logic signal_out_next;

    state_e state;
    state_e state_next;

    logic on;
    logic on_next;

    logic [$clog2(PERIOD)-1:0] count;
    logic [$clog2(PERIOD)-1:0] count_next;

    always_comb begin
        signal_out_next = (
            HOLD == "TRUE" ?
                on :
                '0);
        debouncing = state == DEBOUNCING;
        state_next = state;
        on_next = on;
        count_next = count;

        case (state)
            READY: begin
                if ((!on && signal_in) || (on && !signal_in)) begin
                    signal_out_next = signal_in;
                    state_next = DEBOUNCING;
                    on_next = signal_in;
                end
            end

            DEBOUNCING: begin
                if (count == PERIOD - 1) begin
                    state_next = READY;
                    count_next = '0;
                end
                else begin
                    count_next = count + 1;
                end
            end

            default: ;
        endcase
    end

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            signal_out <= '0;
            state <= READY;
            on <= '0;
            count <= '0;
        end
        else begin
            signal_out <= signal_out_next;
            state <= state_next;
            on <= on_next;
            count <= count_next;
        end
    end
endmodule
