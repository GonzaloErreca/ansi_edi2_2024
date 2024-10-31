# SISTEMA DE VETERINARIA

## Descripción Del Sistema:

- Se requiere ingreso de especies que atiende la veterinaria.
- Identificación del profesional (id,nombre y apellido)que atiende la mascota.
- Turnos predefinidos, cantidad de turnos limitados (un turno por hora).
- El cliente puede agregar mascotas (id, nombre, especie)
- El cliente puede sacar un turno (ver los turnos disponibles y elegir fecha y horario)

## Requerimientos no funcionales

- Lenguaje: PHP
- Base de datos: SQlite
- Editor: vim
- API REST
- Interfaz de usuario web
- Método de desarrollo TDD

## Requerimientos funcionales

- CRUD (ABM) Especies
- CRUD Profesional
- CRUD Turnos
- CRUD Mascotas
- Turnos ilimitados por usuario
- Mascota es usuario
- Cada entidad tendrá su ID
- Cada turno dura una hora, tiene una mascota y un profesional
- Por día son 8 turnos, de cualquier profesional
- Visualización de turnos disponibles (horarios libres)

## Historias de usuario

- Como admin puedo crear, listar, actualizar y eliminar especies de animales.
- Como admin puedo crear, listar, actualizar y eliminar veterinarios.
- Como cliente/admin puedo crear, listar, actualizar y eliminar mascotas.
- Como cliente/admin puedo listar turnos disponibles.
- Como cliente/admin puedo crear, listar, actualizar y eliminar turnos.
 

## Alcance

- Tener una aplicación para sacar turnos en una veterinaria y que su interfaz sea una pagina web que consuma una API REST en la cual va a estar ubicada la lógica.
