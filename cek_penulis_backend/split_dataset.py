import argparse
import hashlib
import json
import random
import shutil
from pathlib import Path

from utils.config import DATASET_DIR, RINGKASAN_DATASET_PATH, EKSTENSI_GAMBAR


def hash_file(path):
    return hashlib.md5(path.read_bytes()).hexdigest()


def bagi(daftar, rasio_val, rasio_test):
    n = len(daftar)
    n_test = max(1, round(n * rasio_test))
    n_val = max(1, round(n * rasio_val))
    test = daftar[:n_test]
    val = daftar[n_test:n_test + n_val]
    train = daftar[n_test + n_val:]
    return train, val, test


def main():
    parser = argparse.ArgumentParser(description="Membagi dataset per penulis menjadi train, validation, dan test")
    parser.add_argument("--sumber", required=True, help="Folder berisi folder per penulis, contoh: MLA")
    parser.add_argument("--val", type=float, default=0.15)
    parser.add_argument("--test", type=float, default=0.15)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    sumber = Path(args.sumber)
    folder_kelas = sorted(p for p in sumber.iterdir() if p.is_dir())
    if not folder_kelas:
        print("Tidak ada folder penulis di", sumber)
        return

    for bagian in ("train", "validation", "test"):
        if (DATASET_DIR / bagian).exists():
            shutil.rmtree(DATASET_DIR / bagian)

    random.seed(args.seed)
    hash_terpakai = {}
    ringkasan = {"kelas": {}, "duplikat_dibuang": [], "total": {"train": 0, "validation": 0, "test": 0}}

    for folder in folder_kelas:
        file_unik = []
        for f in sorted(folder.iterdir()):
            if f.suffix.lower() not in EKSTENSI_GAMBAR:
                continue
            h = hash_file(f)
            # Gambar yang isinya sama persis hanya dipakai sekali,
            # supaya tidak ada gambar yang sama di train dan test
            if h in hash_terpakai:
                ringkasan["duplikat_dibuang"].append(f"{folder.name}/{f.name} = {hash_terpakai[h]}")
                continue
            hash_terpakai[h] = f"{folder.name}/{f.name}"
            file_unik.append(f)

        if len(file_unik) < 3:
            print(f"Lewati {folder.name}: gambar kurang dari 3")
            continue

        random.shuffle(file_unik)
        train, val, test = bagi(file_unik, args.val, args.test)

        for nama_bagian, daftar in (("train", train), ("validation", val), ("test", test)):
            tujuan = DATASET_DIR / nama_bagian / folder.name
            tujuan.mkdir(parents=True, exist_ok=True)
            for f in daftar:
                shutil.copy2(f, tujuan / f.name)
            ringkasan["total"][nama_bagian] += len(daftar)

        ringkasan["kelas"][folder.name] = {"train": len(train), "validation": len(val), "test": len(test)}

    RINGKASAN_DATASET_PATH.write_text(json.dumps(ringkasan, indent=2))

    print("Jumlah penulis :", len(ringkasan["kelas"]))
    print("Train          :", ringkasan["total"]["train"])
    print("Validation     :", ringkasan["total"]["validation"])
    print("Test           :", ringkasan["total"]["test"])
    print("Duplikat dibuang:", len(ringkasan["duplikat_dibuang"]))
    for d in ringkasan["duplikat_dibuang"]:
        print("  -", d)


if __name__ == "__main__":
    main()
