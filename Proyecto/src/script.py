# Laboratorio de Microcontroladores
# Proyecto Final
# Sofia Villalta Jinesta B88565
# Elias Alvarado Vargas B80372

# Este script en python tiene como objetivo
# conectarse con la plataforma Iot thingsboard
# por lo que mediante un widget se logre observar
# en la interfaz gráfica la nota captada, después de 
# ejecutar el archivo Proyecto.ino donde se realiza el upload al arduino
# de nuestra librería del modelo entrenado de Machine Learning.

import serial
import re
import sys
import select
import paho.mqtt.client as mqtt
import json

# Inicia conexión serial
ser = serial.Serial('/dev/ttyACM0', 115200)

# Configuración MQTT para Thingsboard
broker = "iot.eie.ucr.ac.cr"
port = 1883
token = "n4j4928th9gtlnnhngee"  # Tu token real
device_id = "31db47c0-8728-11ee-9e77-a52136d4a347"  # Tu Device ID

client = mqtt.Client()
client.username_pw_set(token)
client.connect(broker, port, 60)
client.loop_start()

def on_publish(client, userdata, result):
    print("Data published to Thingsboard")
    pass

client.on_publish = on_publish

# Expresión regular para capturar las etiquetas y valores
pattern = re.compile(r"(\w+): (\d+\.\d+)")

# Variables globales para almacenar la nota con la mayor probabilidad
highest_prob_note = None
highest_probability = 0.0

# Función para procesar las etiquetas detectadas
def process_detected_labels():
    global highest_prob_note, highest_probability

    if highest_prob_note:
        print(f"Nota detectada con mayor probabilidad: {highest_prob_note}")
        message = {"note": highest_prob_note}  # 'Nota' como clave de los datos
        client.publish(f"v1/devices/me/telemetry", json.dumps(message))

# Espera por datos
print("Esperando datos... Presiona Enter para salir.")

# Procesa las líneas que vienen del serial
while True:
    if ser.in_waiting > 0:
        line = ser.readline().decode('utf-8').rstrip()
        print(f"{line}")  # Visualizar datos de entrada

        # Busca coincidencias en la línea actual
        matches = pattern.findall(line)

        # Resetear valores para la nueva línea
        highest_prob_note = None
        highest_probability = 0.0

        # Procesa todas las coincidencias
        for match in matches:
            label, value = match
            probability = float(value)

            if probability > highest_probability:
                highest_probability = probability
                highest_prob_note = label

        # Procesa la nota detectada con la mayor probabilidad
        process_detected_labels()

    # Verifica si se ha presionado Enter para salir del bucle
    if sys.stdin in select.select([sys.stdin], [], [], 0)[0]:
        line = input()
        if line == '':
            break

ser.close()
client.loop_stop()
