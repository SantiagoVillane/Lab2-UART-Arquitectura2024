import serial
import threading

# Parámetros de la comunicación UART
port = "COM4"
baudrate = 9600  # Velocidad de baudios
bytesize = serial.EIGHTBITS  # 8 bits de datos
parity = serial.PARITY_NONE  # Sin bit de paridad
stopbits = serial.STOPBITS_ONE  # 1 bit de stop

# Inicializa el objeto Serial
ser = serial.Serial(port=port, baudrate=baudrate, bytesize=bytesize, parity=parity, stopbits=stopbits)

def enviar_numero(numero):
    try:
        # Convierte el número a una cadena binaria de 8 bits con ceros a la izquierda
        binario = format(numero, '08b')

        # Convierte la cadena binaria de nuevo a bytes
        byte_a_enviar = int(binario, 2).to_bytes(1, byteorder='big')

        # Envía el byte a través de UART
        ser.write(byte_a_enviar)

        # Imprime el número decimal y su representación en binario
        print(f"Enviado (decimal): {numero}")
        print(f"Enviado (binario): {binario}")

    except Exception as e:
        print(f"Error al enviar: {str(e)}")

def recibir_numero():
    try:
        while True:
            # Espera y lee un byte desde UART
            byte_recibido = ser.read(1)
            
            if byte_recibido:
                # Convierte el byte recibido a un número decimal
                numero_recibido = int.from_bytes(byte_recibido, byteorder='big')
                
                # Imprime el número recibido
                print(f"Recibido (decimal): {numero_recibido}")

    except Exception as e:
        print(f"Error al recibir: {str(e)}")

# Inicia el thread para recibir datos
thread_recepcion = threading.Thread(target=recibir_numero)
thread_recepcion.daemon = True
thread_recepcion.start()

# Loop principal para enviar datos
while True:
    try:
        # Solicita al usuario ingresar un número para enviar
        numero = int(input("Ingrese un número para enviar: "))
        
        # Llama a la función para enviar el número
        enviar_numero(numero)

    except ValueError:
        print("Entrada no válida. Ingrese un número entero.")
    except KeyboardInterrupt:
        # Maneja la interrupción del teclado (Ctrl+C) para salir del programa
        print("\nPrograma finalizado.")
        break

# Cierra la conexión UART al salir del programa
ser.close()