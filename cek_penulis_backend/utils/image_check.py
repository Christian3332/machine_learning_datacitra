import io

from PIL import Image

from utils.config import FORMAT_DIIZINKAN


def gambar_valid(isi_file):
    try:
        with Image.open(io.BytesIO(isi_file)) as img:
            img.verify()
            return img.format in FORMAT_DIIZINKAN
    except Exception:
        return False
