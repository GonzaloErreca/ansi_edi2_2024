# language: es
Característica: Listar las especies

  Dado el sistema de turnos para una veterinaria, como administrador, se listan
  las especies que pueden ser atendidas.

  Escenario: El administrador lista las especies cargadas en el sistema
    Dado el sistema con especies cargadas
    O sin especies cargadas
    Cuando el admin pide la lista de especies
    Y la acción se realiza a través de la API REST
    Y la llamada se hace a la ruta '/especie'
    Y el verbo HTTP es 'GET'
    Entonces el sistema retorna el código 200
    Y un objeto representando la lista de especies
    Y el objeto es un JSON que respeta el formato:
    """
    [
      {
        "id": [NUMBER],
        "name": [STRING]
      }
    ]
    """
