#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <inttypes.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/queue.h"
#include "driver/gpio.h"
#include "sdkconfig.h"
#include "esp_log.h"

#define LED_GPIO CONFIG_LED_GPIO
#define BUTTON_GPIO CONFIG_BUTTON_GPIO
#define BUTTON_DEBOUNCE_TIME CONFIG_BUTTON_DEBOUNCE_TIME

#define ESP_INTR_FLAG_DEFAULT 0

// Queue to handle GPIO and button press events
static QueueHandle_t gpio_event_queue = NULL;
static QueueHandle_t button_event_queue = NULL;

static bool ignore_presses = false;

// ISR handler to deal with GPIO interrupt events
static void IRAM_ATTR gpio_isr_handler(void* arg) {
    uint32_t gpio_num = (uint32_t) arg;
    xQueueSendFromISR(gpio_event_queue, &gpio_num, NULL);
}

// Task to handle GPIO events
static void gpio_event(void* arg)
{
    uint32_t io_num;
    for(;;) {
        if(xQueueReceive(gpio_event_queue, &io_num, portMAX_DELAY)) {
            if (ignore_presses || io_num != BUTTON_GPIO) {
                continue;
            }
            ignore_presses = true;

            // Send a message to the button press task
            xQueueSend(button_event_queue, &io_num, 0);
        }
    }
}

// Task to handle button press when the button is pressed
static void button_press_event(void *arg) {
    uint32_t buf;
    for(;;) {
        if(xQueueReceive(button_event_queue, &buf, portMAX_DELAY)) {
            // Turn on the LED
            gpio_set_level(LED_GPIO, 1);

            // Delay for BUTTON_DEBOUNCE_TIME seconds to debounce the button
            vTaskDelay(BUTTON_DEBOUNCE_TIME / portTICK_PERIOD_MS);

            ignore_presses = false;
            gpio_set_level(LED_GPIO, 0);
        }
    }
}

void app_main(void)
{
    // Set up the GPIO used to read the button
    gpio_config_t io_conf = {};
    io_conf.pin_bit_mask = (1ULL << BUTTON_GPIO);
    io_conf.mode = GPIO_MODE_INPUT;
    io_conf.pull_up_en = GPIO_PULLUP_ENABLE;
    io_conf.pull_down_en = GPIO_PULLDOWN_DISABLE;
    io_conf.intr_type = GPIO_INTR_POSEDGE;
    gpio_config(&io_conf);

    // Set up the LED pins
    gpio_reset_pin(LED_GPIO);
    gpio_set_direction(LED_GPIO, GPIO_MODE_OUTPUT);

    // Initialize the GPIO ISR handler
    gpio_event_queue = xQueueCreate(10, sizeof(uint32_t));
    button_event_queue = xQueueCreate(10, sizeof(uint32_t));
    xTaskCreate(gpio_event, "gpio_event", 2048, NULL, 10, NULL);
    xTaskCreate(button_press_event, "button_press_event", 2048, NULL, 10, NULL);

    // Initialize the GPIO ISR handler
    gpio_install_isr_service(ESP_INTR_FLAG_DEFAULT);
    gpio_isr_handler_add(BUTTON_GPIO, gpio_isr_handler, (void*) BUTTON_GPIO);
}
