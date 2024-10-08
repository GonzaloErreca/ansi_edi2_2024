# language: es
Característica: Pedir un turno

  Dado el sistema de turnos para una veterinaria, como usuario (dueño), se
  pide un turno para atender a la mascota.

  Escenario: El usuario pide un turno
    Dado el sistema con veterinarios cargados
    Y turnos disponibles
    Y una mascota cargada en el sistema
    E identificada por un ID
    Cuando el usuario pide un turno
    Y la acción se realiza a través de la API REST
    Y la llamada se hace a la ruta '/turno'
    Y el verbo HTTP es 'POST'
    Y se envía un objeto JSON que respeta el formato:
    """
    {
      "turno": [STRING],
      "mascota_id": [NUMBER]
    }
    """
    Entonces el sistema retorna el código 200
    Y un objeto representando el turno pedido
    Y el objeto es un JSON que respeta el formato:
    """
    {
      "turno": [STRING],
      "mascota_id": [NUMBER]
    }
    """
