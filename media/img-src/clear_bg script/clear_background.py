import cv2
import numpy as np
from PIL import Image
import os

# Ruta de la imagen original
image_path = "d:/git/MATLAB-LegumeClassifier/media/img-src/es.png"

# Cargar la imagen con OpenCV (BGR) para procesar los píxeles
img_cv = cv2.imread(image_path)
if img_cv is None:
    raise FileNotFoundError(f"No se pudo cargar la imagen: {image_path}")

# También cargamos la imagen con PIL en modo RGBA para poder manipular su canal alfa
img_pil = Image.open(image_path).convert("RGBA")
data = np.array(img_pil)

# Creamos una máscara que detecte solo los píxeles que sean blanco puro (255,255,255)
white_mask = cv2.inRange(img_cv, (255, 255, 255), (255, 255, 255))

# Buscamos componentes conectados en la máscara blanca para identificar bloques grandes
num_labels, labels, stats, _ = cv2.connectedComponentsWithStats(
    white_mask, connectivity=8
)

# Inicializamos una máscara vacía que solo marcará los componentes blancos grandes
mask_big_white = np.zeros_like(white_mask)

# Recorremos todos los componentes detectados (excepto el fondo que es el índice 0)
for i in range(1, num_labels):
    area = stats[i, cv2.CC_STAT_AREA]  # Área del componente en píxeles
    if area > 5000:
        # Si el componente es suficientemente grande, lo añadimos a la máscara final
        mask_big_white[labels == i] = 255

# Usamos la máscara para establecer la transparencia en los bloques blancos grandes
# Ponemos alfa = 0 solo donde corresponda a blanco puro grande
data[mask_big_white == 255] = [255, 255, 255, 0]

# Guardamos el resultado en el mismo directorio que la imagen original
output_path = os.path.join(
    os.path.dirname(image_path),
    "background-es.png"
)
Image.fromarray(data).save(output_path)

print(f" Imagen procesada y guardada en: {output_path}")
