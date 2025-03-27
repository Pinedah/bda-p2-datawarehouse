import os
import pandas as pd
from collections import defaultdict

def juntar_archivos_csv(carpeta_entrada="data", carpeta_salida="CSVs"):
    os.makedirs(carpeta_salida, exist_ok=True)  # Ensure the 'CSVs' folder exists
    archivos = [f for f in os.listdir(carpeta_entrada) if f.endswith('.csv')]
    
    if not archivos:
        print("❌ No se encontraron archivos CSV en la carpeta de entrada.")
        return

    archivos_por_grupo = defaultdict(list)
    for archivo in archivos:
        base_nombre = "_".join(archivo.split("_part")[:-1])  # Extract base name before '_part'
        archivos_por_grupo[base_nombre].append(archivo)

    for base_nombre, partes in archivos_por_grupo.items():
        dataframes = []
        for parte in sorted(partes):  # Ensure parts are processed in order
            ruta_parte = os.path.join(carpeta_entrada, parte)
            df = pd.read_csv(ruta_parte, low_memory=False, na_values="*")  # Treat '*' as NaN
            dataframes.append(df)

        archivo_unido = pd.concat(dataframes, ignore_index=True)
        ruta_salida = os.path.join(carpeta_salida, f"{base_nombre}.csv")
        archivo_unido.to_csv(ruta_salida, index=False)
        print(f"✅ Archivos del grupo '{base_nombre}' unidos y guardados en: {ruta_salida}")

# 📌 Uso:
juntar_archivos_csv()
