`timescale 1ns/1ps

module PWM_IP (
    input             clk,
    input             resetn,
    input             sel,
    input      [1:0]  reg_addr,
    input             wstrb,
    input      [31:0] wdata,
    output reg [31:0] rdata,

    output            pwm_out
);

    reg [31:0] ctrl;
    reg [31:0] period;
    reg [31:0] duty;

    reg [31:0] counter;

    always @(posedge clk) begin
        if (!resetn) begin
            ctrl   <= 32'b0;
            period <= 32'd100;
            duty   <= 32'b0;
        end else if (sel & wstrb) begin
            case (reg_addr)
                2'b00: ctrl   <= wdata;
                2'b01: period <= wdata;
                2'b10: duty   <= wdata;
            endcase
        end
    end

    wire en  = ctrl[0];
    wire pol = ctrl[1];

    always @(posedge clk) begin
        if (!resetn) begin
            counter <= 32'b0;
        end else if (en) begin
            if (counter >= period - 1)
                counter <= 32'b0;
            else
                counter <= counter + 1;
        end else begin
            counter <= 32'b0;
        end
    end

    wire pwm_raw = (counter < duty);

    assign pwm_out = en ? (pol ? ~pwm_raw : pwm_raw) : (pol ? 1'b1 : 1'b0);

    always @(*) begin
        if (sel) begin
            case (reg_addr)
                2'b00: rdata = ctrl;
                2'b01: rdata = period;
                2'b10: rdata = duty;
                2'b11: rdata = {counter[15:0], 15'b0, en};
                default: rdata = 32'b0;
            endcase
        end else begin
            rdata = 32'b0;
        end
    end

endmodule
