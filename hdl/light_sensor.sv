`timescale 1ps/1ps

module light_sensor #()(
    input logic clk,
    input logic resetn,

    input logic sensor,
    output logic on);

    (* ASYNC_REG = "TRUE" *) logic [1:0] sensor_sync;

    always_comb begin
        on = sensor_sync[1];
    end

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            sensor_sync <= '0;
        end
        else begin
            sensor_sync <= {sensor_sync[0], sensor};
        end
    end
endmodule
