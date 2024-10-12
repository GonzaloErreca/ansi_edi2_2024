# language: es
Característica: Crear una especie

  Dado el sistema de turnos para una veterinaria, como administrador, se crean
  las especies que pueden ser atendidas.

  Escenario: El administrador crea una especie nueva
    Dada una especie que no se encuentra registrada en el sistema
    Cuando el admin agrega la nueva especie
    Y la acción se realiza a través de la API REST
    Y la llamada se hace a la ruta '/especie'
    Y el verbo HTTP es 'POST'
    Y se envía un objeto JSON que respeta el formato:
    """
    {
      "nombre": [STRING]
    }
    """
    Entonces el sistema retorna el código 200
    Y un objeto representando a la especie nueva
    Y el objeto es un JSON que respeta el formato:
    """
    {
      "id": [NUMBER],
      "nombre": [STRING]
    }
    """

  Escenario: El administrador crea una especie existente
    Dada una especie previamente existente en el sistema
    Cuando el admin agrega la nueva especie
    Y la acción se realiza a través de la API REST
    Y la llamada se hace a la ruta '/especie'
    Y el verbo HTTP es 'POST'
    Y se envía un objeto JSON que respeta el formato:
    """
    {
      "nombre": [STRING]
    }
    """
    Entonces el sistema retorna el código 403
    Y un objeto con el mensaje
    """
    La especie que intenta agregar ya existe
    """
    Y el objeto es un JSON que respeta el formato:
    """
    {
      "mensaje": [STRING]
    }
    """

  Escenario: El administrador crea una especie inválida
    Dada una especie cuyo nombre sea mayor a 30 caracteres
    O que contenga números
    O que contenga caracteres inválidos
    Cuando el admin agrega la nueva especie
    Y la acción se realiza a través de la API REST
    Y la llamada se hace a la ruta '/especie'
    Y el verbo HTTP es 'POST'
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
