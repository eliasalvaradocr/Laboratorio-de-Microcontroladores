#!/usr/bin/python3
import serial
import time
import csv

#El nombre del archivo creado es salida.csv
fileName = "salida.csv"

# encabezado del archivo
header = "Primer Canal; Segundo Canal; Tercer Canal; Cuarto Canal\n"

ser = serial.Serial(
    port='/tmp/ttyS1',\
    baudrate=9600,\
    parity=serial.PARITY_NONE,\
    stopbits=serial.STOPBITS_ONE,\
    bytesize=serial.EIGHTBITS,\
    timeout=20\
    )


print("Archivo csv creado")

i = 0
valores = []
file = open(fileName, mode='w', newline='')
file.write(header)
datos = 120   
counter = 0  # Contador de datos recibidos

while True:
    lines = ser.readline().decode().strip()
    valores.extend(lines.split(','))
    print(valores)

    if len(valores) >= 4:
        while len(valores) >= 4:
            linea = ";".join([str(valor) for valor in valores[:4]])
            file.write(linea)
            file.write("\n")
            valores = valores[4:]
            i += 4

    counter += 1   
    if counter>= datos:
        break
 
ser.close()
file.close()