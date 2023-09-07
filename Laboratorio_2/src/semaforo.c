/**
 * @file semaforo.c
 * @authors 
 *      - Sofia Villalta Jinesta
 *      - Elias Alvarado Vargas
 * @brief Programa para controlar un semáforo en un microcontrolador ATtiny4313.
 * @version 0.1
 * @date 2023-09-06
 * 
 * @copyright Copyright (c) 2023
 * 
 */

#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdbool.h>

// Definiciones de estados
#define estado_inicio           1
#define parpadeo_amarillo       2
#define rojo_semaforo_vehicular 3
#define verde_semaforo_peatonal 4
#define parpadeo_peatonal       5

// Variables Globales
int actual_me;
int next_me;
bool button_pressed = false;
volatile int contador = 0;
volatile int delay_counter = 0;
volatile int button_counter = 0;
volatile bool button_triggered = false;
volatile int blink_counter = 0;

// Prototipo de funcion
void me();

/**
 * @brief Función principal del programa.
 * 
 * @return int Valor de retorno del programa.
 */

int main(void) {
    next_me = estado_inicio;
    actual_me = next_me;

    // Configuración de puertos y pines
    PORTB = 0b00000000;
    PIND = 0b00000000;
    PORTD = 0b00000000;

    DDRB = 0b01111111;
    DDRD = 0b11110011;

    // Configuración de interrupciones externas para botones
    GIMSK |= (1 << INT0); // Botón 1
    GIMSK |= (1 << INT1);  // Botón 2
    MCUCR |= (1 << ISC00) | (1 << ISC01);
    MCUCR |= (1 << ISC10) | (1 << ISC11);  // Configurar INT1 para flanco de subida

    // Configurar Timer0 para interrupción cada 1 ms
    TCCR0A = 0;
    TCCR0B = (1 << CS02) | (1 << CS00); // Preescalador 
    TIMSK |= (1 << TOIE0); // Habilitar interrupción de desbordamiento

    sei(); // Habilitar interrupciones globales

    while (1) {
        me();
    }

    return 0;
}

/**
 * @brief Función para manejar la lógica de la máquina de estados.
 * 
 */


void me() {
    switch (actual_me) {

    case estado_inicio:
        PORTB = 0b00101001;  // Estado inicial
        if (delay_counter >= 680 && button_triggered) { //10 segundos
            PORTB &= ~(1 << PB0);  // Asegurarse que B0 esté apagado
            next_me = parpadeo_amarillo;
            delay_counter = 0;
            button_triggered = false;
        }
        break;

    case parpadeo_amarillo:
        if (delay_counter < 204) { // Después de 3 segundos
            // Parpadea cada segundo para que sea visible
            if (blink_counter % 2 == 0) {
                PORTB |= (1 << PB1);  // Encender LED B1
            } else {
                PORTB &= ~(1 << PB1);  // Apagar LED B1
            }

            // Incrementar el contador de parpadeo cada segundo
            if (delay_counter != blink_counter) {
                blink_counter = delay_counter;
            }
        } else {
            PORTB &= ~(1 << PB1);  // Apagar LED B1 después de 3 segundos
            next_me = rojo_semaforo_vehicular;
            delay_counter = 0;  // Resetear el contador
        }
        break;

    case rojo_semaforo_vehicular:
        PORTB &= ~(1 << PB1);  // Asegurarse que B1 esté apagado
        PORTB |= (1 << PB2);  // Encender LED B2, tráfico detendio
        if (delay_counter >= 80) {  // Pasar al siguiente estado después de 1 segundo
            next_me = verde_semaforo_peatonal;
            delay_counter = 0;  // Resetear el contador
        }
        break;

    case verde_semaforo_peatonal:
        PORTB |= (1 << PB2);  // Asegurarse que B2 esté encendido
        PORTB &= ~(1 << PB5);  // Asegurarse que B5 esté apagado, semaforo peatonal rojo
        PORTB &= ~(1 << PB0);  // Asegurarse que B0 esté apagado, paso de vehículos
        PORTB &= ~(1 << PB3);  // Asegurarse que B5 esté apagado, semaforo peatonal rojo
        PORTB |= (1 << PB6);
        PORTB |= (1 << PB4);
        if (delay_counter >= 680) { //10 segundos
                PORTB &= ~(1 << PB6);  // Asegurarse que B0 esté apagado
                next_me = parpadeo_peatonal;
                delay_counter = 0;
            
            }
        break;
        
    case parpadeo_peatonal:
    if (delay_counter < 204) { // Después de 3s
        // Parpadea cada segundo para que sea visible
        if (blink_counter % 2 == 0) {
            PORTB |= (1 << PB6) | (1 << PB4);  // Encender LED B6 y B4
        } else {
            PORTB &= ~((1 << PB6) | (1 << PB4));  // Apagar LED B6 y B4
        }

        // Incrementar el contador de parpadeo cada segundo
        if (delay_counter != blink_counter) {
            blink_counter = delay_counter;
        }
    } else {
        PORTB &= ~((1 << PB6) | (1 << PB4));  // Apagar LED B6 y B4 después de 3 segundos
        next_me = estado_inicio;
        delay_counter = 0;  // Resetear el contador
    }
    break;    
}
actual_me = next_me;

}


// Manejadores de interrupcion
ISR(INT0_vect) {
    button_triggered = true;
}

ISR(INT1_vect) {
    button_triggered = true;
}


ISR(TIMER0_OVF_vect) {
    delay_counter++;
}

