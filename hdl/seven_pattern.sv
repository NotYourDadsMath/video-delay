`timescale 1ps/1ps

module seven_pattern #()(
    input logic [3:0] pattern,
    output logic [7:0] ca);

    always_comb begin
        case (pattern)
            4'd0: ca = 8'b0010_0001;
            4'd1: ca = 8'b0000_0001;
            4'd2: ca = 8'b0000_0011;
            4'd3: ca = 8'b0011_0000;
            4'd4: ca = 8'b0100_0000;
            4'd5: ca = 8'b0000_0110;
            4'd6: ca = 8'b0001_1000;
            4'd7: ca = 8'b0000_1000;
            4'd8: ca = 8'b0000_1100;
            default: ca = '0;
        endcase
    end
endmodule
