`timescale 1ns/1ps

module PWM_IP (
    input             clk,       // System clock
    input             resetn,    // Active-low reset
    input             sel,       // Base address select line
    input      [1:0]  reg_addr,  // Offset address (mem_addr[3:2])
    input             wstrb,     // Write enable strobe
    input      [31:0] wdata,     // Parallel data from CPU
    output reg [31:0] rdata,     // Combinational readback to CPU
    
    // Physical Output
    output            pwm_out    // The actual PWM signal
);


    reg [31:0] ctrl;    // Bit 0: EN, Bit 1: POL
    reg [31:0] period;  // PWM period in clock ticks
    reg [31:0] duty;    // PWM high time in clock ticks
    
    reg [31:0] counter; // Internal counter for PWM generation

    always @(posedge clk) begin
        if (!resetn) begin
            ctrl   <= 32'b0;
            period <= 32'd100; // Safe default period
            duty   <= 32'b0;
        end else if (sel & wstrb) begin
            case (reg_addr)
                2'b00: ctrl   <= wdata;   // Offset 0x00: CTRL
                2'b01: period <= wdata;   // Offset 0x04: PERIOD
                2'b10: duty   <= wdata;   // Offset 0x08: DUTY
                // Offset 0x0C (STATUS) is read-only
            endcase
        end
    end

    wire en  = ctrl[0];
    wire pol = ctrl[1];

    always @(posedge clk) begin
        if (!resetn) begin
            counter <= 32'b0;
        end else if (en) begin
            // Count up to PERIOD-1, then wrap around
            if (counter >= period - 1)
                counter <= 32'b0;
            else
                counter <= counter + 1;
        end else begin
            counter <= 32'b0; // Reset counter when disabled
        end
    end

    // PWM Generation Rule
    wire pwm_raw = (counter < duty);
    
    // If enabled, apply polarity. If disabled, force to inactive state based on polarity.
    assign pwm_out = en ? (pol ? ~pwm_raw : pwm_raw) : (pol ? 1'b1 : 1'b0);

    always @(*) begin
        if (sel) begin
            case (reg_addr)
                2'b00: rdata = ctrl;
                2'b01: rdata = period;
                2'b10: rdata = duty;
                // STATUS: Bits [31:16] = Counter, Bit 0 = RUNNING (EN)
                2'b11: rdata = {counter[15:0], 15'b0, en}; 
                default: rdata = 32'b0;
            endcase
        end else begin
            rdata = 32'b0;
        end
    end

endmodule