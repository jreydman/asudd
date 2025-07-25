from pathlib import Path
import struct

def get_bmp_dimensions(filepath):
    try:
        with open(filepath, 'rb') as f:
            if f.read(2) != b'BM':
                raise ValueError("Файл не является валидным BMP изображением")

            f.seek(18)

            width_bytes = f.read(4)
            height_bytes = f.read(4)

            width = struct.unpack('<i', width_bytes)[0]
            height = struct.unpack('<i', height_bytes)[0]

            return width, height
    except Exception as e:
        print(f"Ошибка при чтении файла: {e}")
        return None, None


def read_bmp():
    bmp_path = Path('../../data/mdb_tables/CupPic/pictures/pic_9_7920-6195.bmp')
    width, height = get_bmp_dimensions(bmp_path)

    if width is not None and height is not None:
        print(f"Ширина изображения: {width} пикселей")
        print(f"Высота изображения: {height} пикселей")
