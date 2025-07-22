import os
from PIL import Image

# Ruta de la carpeta con imágenes originales
carpeta_entrada = 'data/data_frejol_rojo'
#carpeta_entrada = 'media/img-test'
# Ruta donde se guardarán las imágenes corregidas (puede ser la misma)
carpeta_salida = 'data/data_frejol_rojo'
#carpeta_salida = 'media/img-test'

# Crear carpeta de salida si no existe
os.makedirs(carpeta_salida, exist_ok=True)

# Extensiones válidas
extensiones_validas = ['.jpg', '.jpeg', '.png', '.bmp', '.tiff']

# Obtener lista de archivos válidos
imagenes = [f for f in os.listdir(carpeta_entrada)
            if os.path.splitext(f)[1].lower() in extensiones_validas]

# Procesar cada imagen
for i, nombre_archivo in enumerate(sorted(imagenes), 1):
    ruta_img = os.path.join(carpeta_entrada, nombre_archivo)
    try:
        with Image.open(ruta_img) as img:
            ancho, alto = img.size
            # Rotar solo si la imagen está en vertical
            if alto > ancho:
                img = img.rotate(-90, expand=True)

            # Obtener extensión original
            _, ext = os.path.splitext(nombre_archivo)
            ext = ext.lower()

            # Guardar con nuevo nombre: img1.jpg, img2.png, etc.
            nuevo_nombre = f'img{i}{ext}'
            ruta_salida = os.path.join(carpeta_salida, nuevo_nombre)
            img.save(ruta_salida)

            print(f"[OK] Guardado: {nuevo_nombre}")
    except Exception as e:
        print(f"[ERROR] Al procesar {nombre_archivo}: {e}")
