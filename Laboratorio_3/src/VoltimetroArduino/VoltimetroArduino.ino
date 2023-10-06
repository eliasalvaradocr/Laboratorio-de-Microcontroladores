/**
 * @file VoltimetroArduino.ino
 * @authors 
 *      - Sofia Villalta Jinesta
 *      - Elias Alvarado Vargas
 * @brief Programa que simula un multimetro de 4 canales
 * @version 0.1
 * @date 2023-10-4
 * 
 * Este programa lee voltajes de cuatro canales analógicos, 
 * muestra los valores en una pantalla PCB y enciende LEDs 
 * de alarma si los voltajes están fuera de un rango especificado. 
 * Además, puede imprimir los valores en el Monitor Serie cuando se activa un disparador externo en el pin 12.
 * @copyright Copyright (c) 2023
 * 
 */
#include <Adafruit_PCD8544.h>

#include <SPI.h>

// Conexiones del PCD8544
#define SCLK 13
#define DIN 11
#define DC 10
#define CS 9
#define RST 8

// Pines de verificación de signo
#define SIGN_CHANNEL1 7
#define SIGN_CHANNEL2 2
#define SIGN_CHANNEL3 A5
#define SIGN_CHANNEL4 A4

// Pines para LEDs de alarma y entradas analógicas
#define LED1 3
#define LED2 4
#define LED3 5
#define LED4 6
#define CHANNEL1 A3
#define CHANNEL2 A2
#define CHANNEL3 A1
#define CHANNEL4 A0

#define TRIGGER_PIN 12 // Pin de entrada a verificar (en este caso, pin 12)

Adafruit_PCD8544 display = Adafruit_PCD8544(SCLK, DIN, DC, CS, RST);

/**
 * @brief Configuración inicial del programa.
 * 
 * En esta función, se inicia la comunicación serial, se configuran 
 * los pines y se inicializa la pantalla PCB
 */
void setup() {

  Serial.begin(9600); // Inicializa la comunicación serial
  pinMode(RST, OUTPUT);
  pinMode(CS, OUTPUT);
  pinMode(DC, OUTPUT);
  pinMode(DIN, OUTPUT);
  pinMode(SCLK, OUTPUT);


  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);
  pinMode(LED4, OUTPUT);

  pinMode(SIGN_CHANNEL1, INPUT);
  pinMode(SIGN_CHANNEL2, INPUT);
  pinMode(SIGN_CHANNEL3, INPUT);
  pinMode(SIGN_CHANNEL4, INPUT);

  // Inicializa la pantalla y configura el contraste
  display.begin();
  display.setContrast(50); 
  display.clearDisplay();


}

/**
 * @brief Lee un voltaje de un canal analógico y ajusta el signo si es necesario.
 * 
 * @param pin El pin analógico del cual se leerá el voltaje.
 * @param signPin El pin que indica el signo del voltaje (positivo o negativo).
 * @return El valor del voltaje leído ajustado según el signo.
 */

float readVoltage(int pin, int signPin) {
  // Lee el valor analógico y conviértelo a voltaje
  float voltage = analogRead(pin) * (5.0 / 1023.0);

  // Aplica la regla de tres para obtener el valor original
  // condiciones de diseño fueron consideradas a nivel analogico
  float originalValue = (voltage * 24)/5;

    // Verifica el pin de signo y ajusta el valor si es negativo
  if (digitalRead(signPin) == LOW) {  // Si es negativo
    originalValue *= -1;
  }

  return originalValue;
}

/**
 * @brief Función principal que se ejecuta bucle.
 * 
 * Esta función realiza la medición de voltajes, activa las alarmas y muestra los resultados en la pantalla PCB.
 * También imprime los valores en el Monitor Serie si se activa el disparador externo en el pin 12.
 */
void loop() {
    float voltages[4];
    voltages[0] = readVoltage(CHANNEL1, SIGN_CHANNEL1);
    voltages[1] = readVoltage(CHANNEL2, SIGN_CHANNEL2);
    voltages[2] = readVoltage(CHANNEL3, SIGN_CHANNEL3);
    voltages[3] = readVoltage(CHANNEL4, SIGN_CHANNEL4);

    // Verifica los voltajes y enciende los LEDs de alarma si es necesario
    for (int i = 0; i < 4; i++) {
      if (voltages[i] < -20 || voltages[i] > 20) {
        digitalWrite(LED1 + i, HIGH); // Enciende el LED de alarma
      } else {
        digitalWrite(LED1 + i, LOW); // Apaga el LED de alarma
      }
      displayVoltages(voltages); // Muestra los voltajes en la pantalla
    }

    
    if (digitalRead(TRIGGER_PIN) == HIGH) {
    // Impresión de los valores en el Monitor Serie solo cuando el pin 12 está en alto
    for (int i = 0; i < 4; i++) {
      Serial.print("Ch");
      Serial.print(i + 1);
      Serial.print(": ");
      Serial.print(voltages[i]);
      Serial.println("V");
    }
  } else {

  }

  delay(1); // Espera un segundo antes de volver a verificar
}

/**
 * @brief Muestra los valores de voltaje en la pantalla PCB.
 * 
 * @param voltages Un arreglo con los valores de voltaje a mostrar.
 */
void displayVoltages(float voltages[4]) {
  display.clearDisplay();
  for (int i = 0; i < 4; i++) {
    display.setCursor(0, i * 8);
    display.print("Ch");
    display.print(i + 1);
    display.print(": ");
    display.print(voltages[i]);
    display.print("V");
 
  }
  display.display(); 
  delay(1);
  display.clearDisplay();

}
