import csv
import io
from picture import Picture
from pathlib import Path

# ------------------------------------------------------------------------------

csv.field_size_limit(10**10)

# ------------------------------------------------------------------------------

def get_pictures_from_csv(csv_file_path: Path):
    with csv_file_path.open('rb') as raw:
        total_lines = sum(1 for _ in raw) - 1
    print(f"[~] Total records in CSV: {total_lines}")

    pictures = []

    with csv_file_path.open('rb') as raw:
        wrapper = io.TextIOWrapper(raw, encoding='latin1', newline='')
        reader = csv.DictReader(wrapper, quotechar='"')

        for row in reader:
            try:
                nompic = int(row['NomPic'])
                width = int(row['PWidth'])
                height = int(row['PHeight'])

                pic_bytes = row['pic'].encode('latin1')

                if not pic_bytes.startswith(b'BM'):
                    pic_bytes = pic_bytes[82:]

                picture = Picture(nompic, pic_bytes, width, height)
                pictures.append(picture)

            except Exception as e:
                print(f"[!] Error parsing line: {e}")
                continue

    return pictures

# ------------------------------------------------------------------------------

def prepare_output_directory(directory_path: Path):
    if directory_path.exists() and directory_path.is_dir():
        for file_path in directory_path.iterdir():
            if file_path.is_file():
                try:
                    file_path.unlink()
                except Exception as e:
                    print(f"[!] Error removing {file_path}: {e}")
    else:
        print(f"[~] Directory '{directory_path}' does not exist. Creating...")
        directory_path.mkdir(parents=True, exist_ok=True)

# ------------------------------------------------------------------------------

def dump_pictures_from_csv():
    csv_path = Path("../../data/mdb_tables/CupPic/Per_Pic.csv")
    output_dir = Path("../../data/mdb_tables/CupPic/pictures")

    pictures = get_pictures_from_csv(csv_path)
    print(f"[~] Parse records: {len(pictures)}")

    prepare_output_directory(output_dir)

    for picture in pictures:
        picture.persist(output_dir)

# ------------------------------------------------------------------------------
