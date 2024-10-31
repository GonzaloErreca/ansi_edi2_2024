CREATE TABLE IF NOT EXISTS veterinario (
    id INTEGER PRIMARY KEY NOT NULL,
    nombre TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS especie (
    id INTEGER PRIMARY KEY NOT NULL,
    nombre TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS mascota (
    id INTEGER PRIMARY KEY NOT NULL,
    nombre TEXT NOT NULL,
    especie_id INTEGER NOT NULL,
    FOREIGN KEY (especie_id)
        REFERENCES especie (id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS turno (
    turno TEXT NOT NULL,
    mascota_id INTEGER NOT NULL,
    veterinario_id INTEGER NOT NULL,
    PRIMARY KEY (turno, mascota_id, veterinario_id),
    FOREIGN KEY (mascota_id)
        REFERENCES mascota (id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    FOREIGN KEY (veterinario_id)
        REFERENCES veterinario (id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION
);
