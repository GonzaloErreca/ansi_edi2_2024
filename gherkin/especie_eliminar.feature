# language: es
Característica: Eliminar una especie

  Dado el sistema de turnos para una veterinaria, como administrador, se
  eliminan las especies que pueden ser atendidas.

  Escenario: El administrador elimina una especie existente
    Dada una especie cargada en el sistema
    E identificada por un ID
    Cuando el admin elimina la especie
    Y la acción se realiza a través de la API REST
    Y la llamada se hace a la ruta '/especie/{ID}'
    Y el verbo HTTP es 'DELETE'
    Entonces el sistema retorna el código 200
    Y un objeto representando a la especie eliminada
    Y el objeto es un JSON que respeta el formato:
    """
    {
      "id": [NUMBER],
      "name": [STRING]
    }
    """

  Escenario: El administrador elimina una especie no existente
    Dado el ID de una especie inexistente
    Cuando el admin elimina la especie
    Y la acción se realiza a través de la API REST
    Y la llamada se hace a la ruta '/especie/{ID}'
    Y el verbo HTTP es 'DELETE'
    Entonces el sistema retorna el código 404
    Y un objeto con el mensaje
    """
    ID invalido o inexistente
    """
    Y el objeto es un JSON que respeta el formato:
    """
    {
      "message": [STRING]
    }
    """
