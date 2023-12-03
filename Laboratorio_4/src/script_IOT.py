import paho.mqtt.client as mqtt
import serial
import json
import time

serial_port = serial.Serial(port="/dev/ttyACM0", baudrate=115200, timeout=1)

# Configuración MQTT para Thingsboard
broker = "iot.eie.ucr.ac.cr"
port = 1883  
token = "e0823x0mia7dawj45ebl"

username = "STM32"


client = mqtt.Client()
client.username_pw_set(token)
client.connect(broker, port, 60)
client.loop_start()

def on_publish(client, userdata, result):
    print("data published to thingsboard")
    pass

client.on_publish = on_publish

while True:
    if serial_port.in_waiting > 0:
        line = serial_port.readline().decode('utf-8').strip()
        values = line.split("\t")  # Dividir los datos por tabulaciones

        # Suponiendo que tienes valores x, y, z y batería en ese orden
        data = {
            "x": float(values[0]),
            "y": float(values[1]),
            "z": float(values[2]),
            "battery": float(values[3])
        }

        client.publish("v1/devices/me/telemetry", json.dumps(data), 1)
        time.sleep(1)

serial_port.close()
client.loop_stop()
