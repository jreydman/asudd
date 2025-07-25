import base64
from pathlib import Path

per_pic_path = Path('../../data/mdb_tables_test/CupCip/pictures/pic_9_7920-6195.bmp')
__per_pic_filename = per_pic_path.name.split('.')[0]
per_pic_bsave_path = Path(per_pic_path.parent, __per_pic_filename  + '_binary.txt')

def codec():
    with open(per_pic_path, "rb") as f:
        base64_data = base64.b64encode(f.read()).decode('utf-8')

    with open(per_pic_bsave_path, "w") as out_file:
        out_file.write(base64_data)
