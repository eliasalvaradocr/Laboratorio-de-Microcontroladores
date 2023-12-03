# Laboratorio 5
# Sofia Villalta Jinesta B88565
# Elias Alvarado Vargas B80372

# El programa realiza una conexion con la plataforma thingsboard de Iot 
# con el objetivo de que la ultima palabra detecta, es decir el comando
# de voz o clase detectado se envie a esta plataforma y se observe
# en el dashboard como un card el comando.

import paho.mqtt.client as mqtt
import serial
import json
import re
import sys
import select
import time

serial_port = serial.Serial(port="/dev/ttyACM0", baudrate=115200, timeout=1)

# Configuración MQTT para Thingsboard
broker = "iot.eie.ucr.ac.cr"
port = 1883
token = "wpkptsjr859rj2z10iqo"

client = mqtt.Client()
client.username_pw_set(token)
client.connect(broker, port, 60)
client.loop_start()

# Expresión regular para capturar las etiquetas y valores
pattern = re.compile(r"(\w+pr): (\d+\.\d+)")

# Variable global para almacenar la última palabra detectada
last_detected_word = None

def on_publish(client, userdata, result):
    print("data published to thingsboard")
    pass

client.on_publish = on_publish

# Definición de la función para procesar etiquetas detectadas
def process_detected_labels(current_label, probability):
    global last_detected_word

    # Elimina los últimos dos caracteres 'pr' de la etiqueta
    cleaned_label = current_label[:-2]

    # Verifica si la probabilidad supera el umbral
    if probability > 0.80:
        last_detected_word = cleaned_label

def countdown(t):
    while t:
        print(t)
        time.sleep(1)
        t -= 1
    print("¡Habla ahora!")

while True:
    if serial_port.in_waiting > 0:
        line = serial_port.readline().decode('utf-8').rstrip()
        print(f"Dato recibido: {line}")

        # Iniciar cuenta regresiva si el Arduino está a punto de grabar
        if "Starting inferencing in 2 seconds..." in line:
            countdown(3)  # Cuenta regresiva de 3 segundos

        # Busca coincidencias en la línea actual
        matches = pattern.findall(line)

        # Procesa las etiquetas detectadas
        for match in matches:
            label, value = match
            probability = float(value)
            process_detected_labels(label, probability)

        # Toma decisiones basadas en la última palabra detectada
        if last_detected_word:
            print(f"Última palabra detectada: {last_detected_word}")
            message = {"word": last_detected_word}
            client.publish(f"v1/devices/me/telemetry", json.dumps(message), 1)

    # Verifica si se ha presionado Enter para salir del bucle
    if sys.stdin in select.select([sys.stdin], [], [], 0)[0]:
        line = input()
        if line == '':
            break

serial_port.close()
client.loop_stop()
