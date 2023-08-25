// Aca funciona que la salida se ponen en alto

#include <pic12f683.h>

#define boton GP3

// Función de retardo basada en ciclos
void delay(unsigned int ciclos)
{
    unsigned int i, j;
    for (i = 0; i < ciclos; i++)
        for (j = 0; j < 255; j++);
}

void main(void)
{
    GPIO   = 0x00;          // Configura todos los pines en bajo inicialmente
    TRISIO = 0b00001000;    // Configura GP3 como entrada y los demás como salidas
    ANSEL  = 0x00;          // Configura los pines como digitales

    unsigned char estado_anterior = 1; // Variable para rastrear el estado anterior de GP3
    unsigned char gp0_encendido = 0;   // Variable para rastrear el estado de GP0 (apagado por defecto)
    unsigned char gp1_encendido = 0;   // Variable para rastrear el estado de GP1 (apagado por defecto)
    unsigned char gp2_encendido = 0;   // Variable para rastrear el estado de GP2 (apagado por defecto)

    while (1)
    {
        // Verifica el cambio de estado de GP3 (botón)
        if (boton != estado_anterior)
        {
            if (boton == 0) // Cuando el botón cambia de alto a bajo (presionado)
            {
                // Alterna el estado de GP0, GP1 y GP2
                gp0_encendido = !gp0_encendido;
                gp1_encendido = !gp1_encendido;
                gp2_encendido = !gp2_encendido;

                // Actualiza el estado de los pines
                GPIO = (GPIO & 0b11111000) | (gp0_encendido << 0) | (gp1_encendido << 1) | (gp2_encendido << 2);

                // Espera un breve instante para que puedas ver el cambio (ajusta según tus necesidades)
                delay(100); // Este retardo es de 0.1 segundos
            }
        }

        // Actualiza el estado anterior del botón
        estado_anterior = boton;
    }
}



