# language: es
Característica: Eliminar una mascota

  Dado el sistema de turnos para una veterinaria, como usuario o administrador,
  se eliminan las mascotas para ser atendidas por los veterinarios.

  Escenario: El usuario (dueño) elimina una mascota existente
    Dada una mascota cargada en el sistema
    E identificada por un ID
    Cuando el usuario elimina su mascota
    Y la acción se realiza a través de la API REST
    Y la llamada se hace a la ruta '/mascota/{ID}'
    Y el verbo HTTP es 'DELETE'
    Entonces el sistema retorna el código 200
    Y un objeto representando a la mascota eliminada
    Y el objeto es un JSON que respeta el formato:
    """
    {
      "id": [NUMBER],
      "especie_id": [NUMBER],
      "nombre": [STRING]
    }
    """
