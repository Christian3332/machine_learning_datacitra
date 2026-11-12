from tensorflow import keras
from tensorflow.keras import layers

from utils.config import TINGGI, LEBAR


def buat_model(n_kelas, bobot="imagenet"):
    # include_preprocessing bawaan EfficientNetV2B0 aktif, jadi input tetap bernilai 0-255
    base = keras.applications.EfficientNetV2B0(
        include_top=False, weights=bobot, input_shape=(TINGGI, LEBAR, 3)
    )

    inp = keras.Input(shape=(TINGGI, LEBAR, 3))
    x = base(inp, training=False)
    x = layers.GlobalAveragePooling2D(name="gap")(x)
    x = layers.Dropout(0.3, name="dropout")(x)
    out = layers.Dense(n_kelas, activation="softmax", name="prediksi")(x)

    model = keras.Model(inp, out)
    model.compile(
        optimizer=keras.optimizers.Adam(1e-4),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"],
    )
    return model


def ambil_backbone(model):
    for layer in model.layers:
        if isinstance(layer, keras.Model):
            return layer
    raise ValueError("Backbone EfficientNetV2B0 tidak ditemukan di model")
