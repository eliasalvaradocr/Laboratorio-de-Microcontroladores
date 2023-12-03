/**
 * @file sismografo.c
 * @authors 
 *      - Sofia Villalta Jinesta
 *      - Elias Alvarado Vargas
 * @brief Programa que simula un sismografo digital
 * @version 0.1
 * @date 2023-10-27
 * @copyright Copyright (c) 2023
 * 
 */

// Librerias utilizadas
#include <stdint.h>
#include <stdio.h>
#include <string.h>
// Includes de lcd-serial
#include "lcd-spi.h"
#include "clock.h"
#include "console.h"
#include "sdram.h"
#include "gfx.h"
#include "grp.h"
#include "gyr_spi.c"
#include "gyr_spi.h"
#include "usart.h"

#include <libopencm3/stm32/spi.h>
#include <libopencm3/stm32/rcc.h>
#include <libopencm3/stm32/gpio.h>
#include <libopencm3/stm32/adc.h>

// Definicion de variables
#define VREF 3.3f
#define ADC_MAX_VALUE 4095.0f
#define CONVERSION_FACTOR 2.703f  // Actualizado el factor de conversión
#define NUM_SAMPLES 100
#define BATTERY_THRESHOLD 7.5f  // Umbral de tensión para encender el LED
#define LED_BLINK_INTERVAL 100000 //medio segundo

float battery_voltage;

/**
 * @brief Configura los pines GPIO para el LED rojo.
 */

void gpio_setup_for_ledR(void) {
    rcc_periph_clock_enable(RCC_GPIOG);
    gpio_mode_setup(GPIOG, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE, GPIO14);
}

/**
 * @brief Configura los pines GPIO para el LED verde.
 */
void gpio_setup_for_ledG(void) {
    rcc_periph_clock_enable(RCC_GPIOG);
    gpio_mode_setup(GPIOG, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE, GPIO13);
}

/**
 * @brief Realiza una lectura del ADC.
 * @param channel El canal ADC a leer.
 * @return El valor leído.
 */

static uint16_t read_adc_naiive(uint8_t channel) {
    uint8_t channel_array[16];
    channel_array[0] = channel;
    adc_set_regular_sequence(ADC1, 1, channel_array);
    adc_start_conversion_regular(ADC1);
    while (!adc_eoc(ADC1));
    return adc_read_regular(ADC1);
}

/**
 * @brief Realiza múltiples lecturas del ADC y promedia los resultados.
 * @param channel El canal ADC a leer.
 * @return El valor promediado.
 */

uint16_t read_adc_average(uint8_t channel) {
    uint32_t sum = 0;
    for (int i = 0; i < NUM_SAMPLES; i++) {
        sum += read_adc_naiive(channel);
    }
    return sum / NUM_SAMPLES;
}

/**
 * @brief Configura el USART para la comunicación serie.
 */

static void usart_setup(void)
{
	/* Setup GPIO pins for USART1 transmit. */
	gpio_mode_setup(GPIOA, GPIO_MODE_AF, GPIO_PUPD_NONE, GPIO9);

	/* Setup USART1 TX pin as alternate function. */
	
	gpio_set_af(GPIOA, GPIO_AF7, GPIO9);

	usart_set_baudrate(USART1, 115200);
	usart_set_databits(USART1, 8);
	usart_set_stopbits(USART1, USART_STOPBITS_1);
	usart_set_mode(USART1, USART_MODE_TX);
	usart_set_parity(USART1, USART_PARITY_NONE);
	usart_set_flow_control(USART1, USART_FLOWCONTROL_NONE);
	/* Finally enable the USART. */
	usart_enable(USART1);
    gpio_set(GPIOG, GPIO13);
}

/**
 * @brief Envía una cadena de caracteres a través del USART.
 * @param str La cadena de caracteres a enviar.
 */
void usart_send_string(char* str)
{
    while(*str)
    {
        usart_send_blocking(USART1, *str++);
        gpio_toggle(GPIOG, GPIO13);  // Hace que el LED parpadee
            for (int i = 0; i < LED_BLINK_INTERVAL; i++) {
                __asm__("nop");
        }
    }
}

/**
 * @brief Convierte un valor ADC en una tensión.
 * @param adc_value El valor ADC a convertir.
 * @return La tensión correspondiente.
 */

float adc_to_voltage(uint16_t adc_value) {
    float voltage = (adc_value / ADC_MAX_VALUE) * VREF;
    return voltage * CONVERSION_FACTOR;
}

/**
 * @brief Configura el ADC para la lectura de la tensión de la batería.
 */

void adc_setup(void) {
    rcc_periph_clock_enable(RCC_ADC1);
    gpio_mode_setup(GPIOA, GPIO_MODE_ANALOG, GPIO_PUPD_NONE, GPIO7);  
    adc_power_off(ADC1);
    adc_enable_scan_mode(ADC1);
    adc_set_continuous_conversion_mode(ADC1);
    adc_disable_external_trigger_regular(ADC1);
    adc_set_right_aligned(ADC1);
    adc_set_sample_time_on_all_channels(ADC1, ADC_SMPR_SMP_28CYC);
    adc_power_on(ADC1);
}

/**
 * @brief Configura un botón para su uso.
 */

void button_setup(void) {
    rcc_periph_clock_enable(RCC_GPIOA);
    gpio_mode_setup(GPIOA, GPIO_MODE_INPUT, GPIO_PUPD_NONE, GPIO0); 
}


/**
 * @brief Verifica si el botón está presionado.
 * @return true si el botón está presionado, false en caso contrario.
 */

bool is_button_pressed(void) {
    return gpio_get(GPIOA, GPIO0);
    }

/**
 * @brief Función principal del programa.
 *
 * Esta función es el punto de entrada principal del programa y realiza las siguientes tareas:
 * - Inicializa diversos periféricos, como la pantalla LCD, el ADC y la comunicación USART.
 * - Realiza lecturas del acelerómetro (gyr) y del voltaje de la batería.
 * - Muestra información en la pantalla LCD.
 * - Controla el parpadeo de LEDs en función de la tensión de la batería.
 * - Envia datos a través de la comunicación USART cuando se presiona un botón.
 *
 */

int main(void) {
    char lcd_out[100];
    char usart_out[200]; 
    int16_t x, y, z;

    // Configuración inicial de periféricos
    clock_setup();
    console_setup(115200);
    sdram_init();
    gyr_setup();
    adc_setup();
    lcd_spi_init();
    gfx_init(lcd_draw_pixel, 240, 320);
    gpio_setup_for_ledR();
    gpio_setup_for_ledG();
    usart_setup();

    while (1) {
        // Limpiar la pantalla y mostrar el título
        gfx_fillScreen(LCD_WHITE);
        gfx_setTextSize(2);
        gfx_setCursor(25, 15);
        gfx_puts("Sismografo");

        // Lecturas del acelerómetro
        x = gyr_readX();
        y = gyr_readY();
        z = gyr_readZ();

        // Mostrar lecturas en la pantalla
        sprintf(lcd_out, "X: %.2f", (float)x/100); 
        gfx_setCursor(15, 36);
        gfx_puts(lcd_out);
        sprintf(lcd_out, "Y: %.2f", (float)y/100); 
        gfx_setCursor(15, 90);
        gfx_puts(lcd_out);
        sprintf(lcd_out, "Z: %.2f", (float)z/100);
        gfx_setCursor(15, 144);
        gfx_puts(lcd_out);

        // Lectura del voltaje de la batería a través del ADC
        uint16_t raw_adc_value = read_adc_average(7); // Canal 7
        battery_voltage = adc_to_voltage(raw_adc_value);

        // Control del LED en función de la tensión de la batería
        if (battery_voltage < 7.0f) {
            gpio_toggle(GPIOG, GPIO14);  // Hace que el LED parpadee
            for (int i = 0; i < LED_BLINK_INTERVAL; i++) {
                __asm__("nop");
            }
        } else {
            gpio_clear(GPIOG, GPIO14);  // Apaga el LED
        }

        // Mostrar lecturas del ADC y el voltaje de la batería en la pantalla
        sprintf(lcd_out, "Raw ADC: %d", raw_adc_value);
        gfx_setCursor(15, 198);
        gfx_puts(lcd_out);
        
        sprintf(lcd_out, "Voltaje: %.2fV", battery_voltage);
        gfx_setCursor(15, 250);
        gfx_puts(lcd_out);
        
        // Envío de datos a través del USART cuando se presiona el botón
        if (is_button_pressed()) {
        sprintf(usart_out, "%.2f\t%.2f\t%.2f\t%.2f\r\n", (float)x/100, (float)y/100, (float)z/100, battery_voltage);
        usart_send_string(usart_out);  
        }

        // Actualización de la pantalla y espera
        lcd_show_frame();

        for (int i = 0; i < 8000; i++) {
            __asm__("nop");
        }
    }
    return 0;
}
