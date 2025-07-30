import base64

from pathlib import Path
from classes.crosspic__class import Crosspic

# ------------------------------------------------------------------------------

def get_crosspic_array() -> [Crosspic]:
    crosspic_dir = Path("../../data/mdb_tables/CupPic/pictures")
    crosspic_array = []

    for picture_entry in crosspic_dir.iterdir():
        if not picture_entry.name.endswith(".bmp"):
            continue

        name_parts = picture_entry.stem.split("_")
        if len(name_parts) != 3:
            print(f"[!] Invalid filename format: {picture_entry.name}")
            continue

        pic_id = name_parts[1]
        axis_width, axis_height = map(int, name_parts[2].split("-"))

        with open(picture_entry, "rb") as f:
            binary_data = f.read()

        buffer_b64 = base64.b64encode(binary_data)

        crosspic = Crosspic(
            perinf_id=int(pic_id),
            buffer=buffer_b64,
            axis_width=axis_width,
            axis_height=axis_height
        )

        crosspic_array.append(crosspic)

    return crosspic_array

# ------------------------------------------------------------------------------
