# language: es
Característica: Listar las mascotas

  Dado el sistema de turnos para una veterinaria, como usuario o administrador,
  se listan las mascotas para ser atendidas por los veterinarios.

  Escenario: El usuario (dueño) lista las mascotas cargadas en el sistema
    Dado el sistema con mascotas cargadas
    O sin mascotas cargadas
    Cuando el usuario pide la lista de mascotas
    Y la acción se realiza a través de la API REST
    Y la llamada se hace a la ruta '/mascota'
    Y el verbo HTTP es 'GET'
    Entonces el sistema retorna el código 200
    Y un objeto representando la lista de mascotas
    Y el objeto es un JSON que respeta el formato:
    """
    [
      {
        "id": [NUMBER],
        "especie_id": [NUMBER],
        "nombre": [STRING]
      }
    ]
    """
