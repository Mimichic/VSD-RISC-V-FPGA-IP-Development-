#include <stdint.h>

#define UART_DAT  (*(volatile uint32_t*)0x400008)

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

    PWM_PERIOD = 20;

    PWM_DUTY = 5;

    PWM_CTRL = 0x01;

    if (PWM_STATUS & 0x01) {
        uart_puts("PWM Engine is RUNNING! [ PASS ]\r\n");
    } else {
        uart_puts("PWM Engine is stopped. [ FAIL ]\r\n");
    }

    volatile int delay;
    for(delay = 0; delay < 1000; delay++);

    return 0;
}
