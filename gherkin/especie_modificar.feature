# language: es
Característica: Modificar una especie

  Dado el sistema de turnos para una veterinaria, como administrador, se editan
  las especies que pueden ser atendidas.

  Escenario: El administrador modifica una especie existente
    Dada una especie cargada en el sistema
    E identificada por un ID
    Cuando el admin edita la especie
    Y el cambio es válido
    Y la acción se realiza a través de la API REST
    Y la llamada se hace a la ruta '/especie/{ID}'
    Y el verbo HTTP es 'PUT'
    Y se envía un objeto JSON que respeta el formato:
    """
    {
      "nombre": [STRING]
    }
    """
    Entonces el sistema retorna el código 200
    Y un objeto representando a la especie actualizada
    Y el objeto es un JSON que respeta el formato:
    """
    {
      "id": [NUMBER],
      "nombre": [STRING]
    }
    """

  Escenario: El administrador edita una especie y duplica una existente
    Dada una especie cargada en el sistema
    E identificada por un ID
    Cuando el admin edita la especie
    Y el nuevo nombre duplica una especie existente
    Y la acción se realiza a través de la API REST
    Y la llamada se hace a la ruta '/especie/{ID}'
    Y el verbo HTTP es 'PUT'
    Y se envía un objeto JSON que respeta el formato:
    """
    {
      "nombre": [STRING]
    }
    """
    Entonces el sistema retorna el código 403
    Y un objeto con el mensaje
    """
    La especie que intenta definir ya existe
    """
    Y el objeto es un JSON que respeta el formato:
    """
    {
      "mensaje": [STRING]
    }
    """

  Escenario: El administrador edita una especie con nombre inválido
    Dada una especie cargada en el sistema
    E identificada por un ID
    Cuando el admin edita la especie
    Y el nuevo nombre sea mayor a 30 caracteres
    O que contenga números
    O que contenga caracteres inválidos
    Y la acción se realiza a través de la API REST
    Y la llamada se hace a la ruta '/especie/{ID}'
    Y el verbo HTTP es 'PUT'
    Y se envía un objeto JSON que respeta el formato:
    """
    {
      "nombre": [STRING]
    }
    """
    Entonces el sistema retorna el código 422
    Y un objeto con el mensaje
    """
    Nombre de especie inválido
    """
    Y el objeto es un JSON que respeta el formato:
    """
    {
      "mensaje": [STRING]
    }
    """

  Escenario: El administrador modifica una especie inexistente
    Dado el ID de una especie inexistente
    Cuando el admin edita la especie
    Entonces el sistema retorna el código 404
    Y un objeto con el mensaje
    """
    ID invalido o inexistente
    """
    Y el objeto es un JSON que respeta el formato:
    """
    {
      "mensaje": [STRING]
    }
    """
