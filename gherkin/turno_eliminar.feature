# language: es
Característica: Liberar (eliminar) un turno pedido

  Dado el sistema de turnos para una veterinaria, como administrador, se
  eliminan los turnos tomados.

  Escenario: El administrador elimina un turno pedido
    Dado un turno tomado por un usuario
    E identificado por la fecha y hora
    Cuando el admin elimina el turno
    Y la acción se realiza a través de la API REST
    Y la llamada se hace a la ruta '/turno/{YYYYMMDDThhmmssZ}/{mascota_id}'
    Y el verbo HTTP es 'DELETE'
    Entonces el sistema retorna el código 200
    Y un objeto representando al turno liberado
    Y el objeto es un JSON que respeta el formato:
    """
    {
      "turno": [STRING],
      "mascota_id": [NUMBER]
    }
    """
