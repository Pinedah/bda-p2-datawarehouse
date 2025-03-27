import os

def dividir_archivo(nombre_archivo, tamano_parte=90 * 1024 * 1024):
    os.makedirs("data", exist_ok=True)  # Ensure the 'data' folder exists
    archivo_nombre = nombre_archivo.split("/")[-1].split(".")[0]
    extension = nombre_archivo.split("/")[-1].split(".")[1]
    with open(nombre_archivo, 'rb') as archivo:
        parte = 0
        while True:
            datos = archivo.read(tamano_parte)
            if not datos:
                break
            with open(f"data/{archivo_nombre}_part{parte:03d}.{extension}", 'wb') as parte_archivo:
                parte_archivo.write(datos)
            parte += 1
    print(f"✅ Archivo dividido en {parte} partes y guardado en la carpeta 'data'.")

# 📌 Uso:
dividir_archivo("raw_data/SSNMX_catalogo_19000101_20250213.csv")
