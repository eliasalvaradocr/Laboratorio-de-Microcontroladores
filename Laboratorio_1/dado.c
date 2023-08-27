/**
 * @file dado.c
 * @author Elias Alvarado Vargas B80372
 * @brief 
 * @version 0.1
 * @date 2023-08-27
 * 
 */

// Para el PIC12f683Z
#include <pic12f675.h>

// Ahora se declara un parametro que esta relacionado con el pin GP3
#define boton GP3

// Variable para modificar el registro config.
typedef unsigned int word;

// Lo siguiente corresponde a la configuracion del PIC
word __at 0x2007 __CONFIG = (_BODEN_OFF & _WDTE_OFF & _WDT_OFF & _MCLRE_OFF);

void delay(unsigned int tiempo);

// Seguidamente la variable para los valores aleatorios de salida actual es el siguiente, el cual inicia 
// con las señales en 000(bajas)
unsigned char valor_actual = 0b000;
// Y la variable para los valores aleatorios de salida anteriores, inician en 000 (bajos)
unsigned char valor_anterior = 0b000;

/**
 * @brief Funcion principal del programa
 * 
 */
void main(void) {

    // Se colocan todos los pines como salidas, pero el GP3 no porque es una entrada.
    TRISIO = 0b00001000; 
    // Coloca todos los pines en bajo
    GPIO = 0x00; 

    // Lo siguiente, configura el TMRO para que incremente en cada ciclo de reloj
    // con la idea de generar valores aleatorios de las salidas
    OPTION_REG = 0b00000100; 
    unsigned int time = 100;

    // Bucle para condiciones de entrada (Boton), lo cual genera valores aleatorios en las salidas
    while (1) {

        // Para cuando GP3(Boton se encuentra en 0V, es decir presionado)
        if (boton == 0) {
            // Se usa el valor actual del "temporizador" como valor aleatorio
            unsigned char valor_aleatorio = TMR0; 

            if (valor_aleatorio != valor_actual) {
                // Condiciones para valores aleatorios:

                // Se almacena el patrón actual como uno anterior
                valor_anterior = valor_actual; 
                // Ahora, genera una actualizacion del patron actual con el valor aleatorio
                valor_actual = valor_aleatorio; 
                // Y, realiza una configuracion de GP0,GP1 y GP2 con el nuevo patrón por ver
                GPIO = (0b11000000 | valor_actual);
            }

            delay(time);
            
            // Para cuando GP3, el boton regresa a 5V (sin presionar)
        } else { 
            if (valor_actual != valor_anterior) {
                // Para saber que cara de dado queda, la siguiente linea mantiene el ultimo valor aleatorio generado
                GPIO = (0b11000000 | valor_actual);
                // Y ahora realiza una actualizacion del valor aleatorio anterior
                valor_anterior = valor_actual; 
            }
        }
    }
}

/**
 * @brief Función para generar el retraso de tiempo
 * 
 * @param tiempo, Representa el tiempo en milisegundos por esperar, dada por el profesor
 */

void delay(unsigned int tiempo) {
    unsigned int i;
    unsigned int j;

    for (i = 0; i < tiempo; i++)
        for (j = 0; j < 1275; j++);
}
