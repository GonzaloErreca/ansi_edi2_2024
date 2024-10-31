Diccionario de Datos
===================

* (1) Crear especie
    - nombre: string

* (2) Listar especies
    - lista:
        + id: integer
        + nombre: string

* (3) Editar especie
    - id: integer
    - nombre: string

* (4) Eliminar especie
    - id: integer

* (5) Crear veterinario
    - nombre: string

* (6) Listar veterinarios
    - lista:
        + id: integer
        + nombre: string

* (7) Editar veterinario
    - id: integer
    - nombre: string

* (8) Eliminar veterinario
    - id: integer

* (9) Crear mascota
    - nombre: string
    - id_especie: integer

* (10) Listar mascotas
    - lista:
        + id: integer
        + nombre: string
        + id_especie: integer

* (11) Editar mascota
    - id: integer
    - nombre: string
    - id_especie: integer

* (12) Eliminar mascota
    - id: integer

* (13) Turnos disponibles
    - lista: fecha-hora

* (14) Tomar turno
    - turno: fecha-hora
    - mascota_id: integer

* (15) Listar turnos
    - lista:
        + turno: fecha-hora
        + mascota_id: integer
        + veterinario_id: integer

* (16) Cancelar turno
    - turno: fecha-hora
    - mascota_id: integer

* (17) Guardar especie == (1) Crear especie

* (18) Obtener especies == (2) Listar especies

* (19) Actualizar especie == (3) Editar especie

* (20) Eliminar especie == (4) Eliminar especie

* (21) Guardar veterinario == (5) Crear veterinario

* (22) Obtener veterinarios == (6) Listar veterinarios

* (23) Actualizar veterinario == (7) Editar veterinario

* (24) Eliminar veterinario == (8) Eliminar veterinario

* (25) Guardar mascota == (9) Crear mascota

* (26) Obtener mascotas == (10) Listar mascotas

* (27) Actualizar mascota == (11) Editar mascota

* (28) Eliminar mascota == (12) Eliminar mascota

* (29) Guardar turno
    - turno: fecha-hora
    - mascota_id: integer
    - veterinario_id: integer

* (30) Obtener turnos == (15) Listar turnos

* (31) Eliminar turno == (16) Cancelar turno
