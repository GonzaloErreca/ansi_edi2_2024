# language: es
Característica: Modificar un veterinario

  Dado el sistema de turnos para una veterinaria, como administrador, se editan
  los veterinario que atiende las especies.

  Escenario: El administrador modifica un veterinario existente
    Dado un veterinario cargado en el sistema
    E identificado por un ID
    Cuando el admin edita el registro del veterinario
    Y el cambio es válido
    Y la acción se realiza a través de la API REST
    Y la llamada se hace a la ruta '/veterinario/{ID}'
    Y el verbo HTTP es 'PUT'
    Y se envía un objeto JSON que respeta el formato:
    """
    {
      "name": [STRING]
    }
    """
    Entonces el sistema retorna el código 200
    Y un objeto representando a la especie actualizada
    Y el objeto es un JSON que respeta el formato:
    """
    {
      "id": [NUMBER],
      "name": [STRING]
    }
    """
