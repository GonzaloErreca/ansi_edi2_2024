# language: es
Característica: Agregar un veterinario

  Dado el sistema de turnos para una veterinaria, como administrador, se carga
  un veterinario para atender las especies.

  Escenario: El administrador carga un veterinario
    Dado un veterinario que no se encuentra registrado en el sistema
    Cuando el admin carga un veterinario nuevo
    Y la acción se realiza a través de la API REST
    Y la llamada se hace a la ruta '/veterinario'
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
