`timescale 1ps/1ps

module seven_decimal #()(
    input logic [3:0] decimal,
    input logic point,

    output logic [7:0] ca);

    always_comb begin
        case (decimal)
            4'd0: ca[6:0] = 7'b011_1111;
            4'd1: ca[6:0] = 7'b000_0110;
            4'd2: ca[6:0] = 7'b101_1011;
            4'd3: ca[6:0] = 7'b100_1111;
            4'd4: ca[6:0] = 7'b110_0110;
            4'd5: ca[6:0] = 7'b110_1101;
            4'd6: ca[6:0] = 7'b111_1101;
            4'd7: ca[6:0] = 7'b000_0111;
            4'd8: ca[6:0] = 7'b111_1111;
            4'd9: ca[6:0] = 7'b110_1111;
            default: ca[6:0] = '0;
        endcase
        ca[7] = point;
    end
endmodule
