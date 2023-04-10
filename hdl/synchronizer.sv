`timescale 1ps/1ps

module synchronizer #()(
    input logic clk,
    input logic resetn,

    input logic signal_in,
    output logic signal_out);

    (* ASYNC_REG = "TRUE" *) logic [1:0] signal_sync;

    always_comb begin
        signal_out = signal_sync[1];
    end

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            signal_sync <= '0;
        end
        else begin
            signal_sync <= {signal_sync[0], signal_in};
        end
    end
endmodule
