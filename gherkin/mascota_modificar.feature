# language: es
Característica: Modificar una mascota

  Dado el sistema de turnos para una veterinaria, como usuario o administrador,
  se editan las mascotas para ser atendidas por los veterinarios.

  Escenario: El usuario (dueño) modifica una mascota existente
    Dada una mascota cargada en el sistema
    E identificada por un ID
    Cuando el usuario edita el registro de su mascota
    Y el cambio es válido
    Y la acción se realiza a través de la API REST
    Y la llamada se hace a la ruta '/mascota/{ID}'
    Y el verbo HTTP es 'PUT'
    Y se envía un objeto JSON que respeta el formato:
    """
    {
      "especie_id": [NUMBER],
      "name": [STRING]
    }
    """
    Y al menos uno de los valores debe estar presente
    Entonces el sistema retorna el código 200
    Y un objeto representando a la mascota actualizada
    Y el objeto es un JSON que respeta el formato:
    """
    {
      "id": [NUMBER],
      "especie_id": [NUMBER],
      "name": [STRING]
    }
    """
