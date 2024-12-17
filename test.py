import serial
import random
import time

# Conexión al puerto serie
def connect_to_serial(port="COM8", baudrate=38400):
    try:
        ser = serial.Serial(port, baudrate, timeout=1)
        print("Conexión establecida con éxito.")
        return ser
    except serial.SerialException:
        print("Error al conectar con el puerto serie.")
        return None

# Función para obtener el opcode según la operación
def get_opcode(opcode_string):
    opcodes = {
        "ADD": b'\x20',
        "SUB": b'\x22',
        "AND": b'\x24',
        "OR": b'\x25',
        "XOR": b'\x26',
        "NOR": b'\x27',
        "SRL": b'\x02',
        "SRA": b'\x03',
    }
    return opcodes.get(opcode_string, b'\x68')  # Default to 'NOP'

# Función para calcular el resultado esperado
def calculate_expected_result(a, b, operation):
    if operation == "ADD":
        return (a + b) & 0xFF  # Módulo 256
    elif operation == "SUB":
        return (a - b) & 0xFF  # Módulo 256
    elif operation == "AND":
        return a & b
    elif operation == "OR":
        return a | b
    elif operation == "XOR":
        return a ^ b
    elif operation == "NOR":
        return ~(a | b) & 0xFF
    elif operation == "SRL":
        return (a >> b) & 0xFF  # SRL usa 'b' como el número de bits para desplazar
    elif operation == "SRA":
        return (a >> b) & 0xFF  # SRA también usa 'b' como el número de bits para desplazar

# Función para enviar datos al dispositivo
def send_data(ser, a, b, opcode):
    dA = a.to_bytes(1, "big")
    dB = b.to_bytes(1, "big")
    dO = get_opcode(opcode)
    dFull = dA + dB + dO
    ser.write(dFull)

# Función para recibir el resultado del dispositivo
def receive_data(ser):
    received = int.from_bytes(ser.readline(), byteorder='big') & 0xFF
    return received

# Función para comparar los resultados
def compare_result(a, b, operation, received, expected):
    if received == expected:
        print(f"Test exitoso: Operación = {operation}, A = {a}, B = {b}, Recibido = {received}, Esperado = {expected}")
    else:
        print(f"Test fallido: Operación = {operation}, A = {a}, B = {b}, Recibido = {received}, Esperado = {expected}")

# Función principal que ejecuta el test
def run_tests(num_tests=10):
    ser = connect_to_serial()
    if ser is None:
        return
    
    operations = ["ADD", "SUB", "AND", "OR", "XOR", "NOR", "SRL", "SRA"]

    for _ in range(num_tests):
        # Generar números aleatorios para a
        a = random.randint(0, 10) #cambiar a 255

        # Seleccionar la operación aleatoria
        opcode = random.choice(operations)

        # Si es SRL o SRA, b será entre 1 y 7
        if opcode in ["SRL", "SRA"]:
            b = random.randint(1, 7)
        else:
            b = random.randint(0, 10) #cambiar a 255

        # Calcular el resultado esperado
        expected = calculate_expected_result(a, b, opcode)

        # Enviar los datos al dispositivo
        send_data(ser, a, b, opcode)

        # Recibir el resultado del dispositivo
        time.sleep(0.1)  # Esperar un poco para recibir el dato
        received = receive_data(ser)

        # Comparar resultados
        compare_result(a, b, opcode, received, expected)

    # Cerrar la conexión del puerto serie
    ser.close()

# Ejecutar los tests
run_tests(num_tests=20)