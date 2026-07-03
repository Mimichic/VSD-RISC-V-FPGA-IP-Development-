#include <stdint.h>

// UART Registers
#define UART_DAT  (*(volatile uint32_t*)0x400008)

// PWM IP Register Map (FIXED BASE ADDRESS: 0x400040)
#define PWM_BASE   0x400040
#define PWM_CTRL   (*(volatile uint32_t*)(PWM_BASE + 0x00))
#define PWM_PERIOD (*(volatile uint32_t*)(PWM_BASE + 0x04))
#define PWM_DUTY   (*(volatile uint32_t*)(PWM_BASE + 0x08))
#define PWM_STATUS (*(volatile uint32_t*)(PWM_BASE + 0x0C))

void uart_puts(const char *str) {
    while (*str) {
        UART_DAT = *str++;
    }
}

int main(void) {
    uart_puts("\r\n=== PWM IP Verification ===\r\n");

    // 1. Set the PWM Period to 20 clock ticks
    PWM_PERIOD = 20;

    // 2. Set the Duty Cycle to 5 clock ticks (25% Duty Cycle)
    PWM_DUTY = 5;

    // 3. Enable the PWM (Bit 0 = 1), Polarity Active-High (Bit 1 = 0)
    PWM_CTRL = 0x01; 

    // 4. Verify it's running by checking STATUS
    if (PWM_STATUS & 0x01) {
        uart_puts("PWM Engine is RUNNING! [ PASS ]\r\n");
    } else {
        uart_puts("PWM Engine is stopped. [ FAIL ]\r\n");
    }

    // Hang in a loop so simulation doesn't end prematurely
    volatile int delay;
    for(delay = 0; delay < 1000; delay++); 

    return 0;
}