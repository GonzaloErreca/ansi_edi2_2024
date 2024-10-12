# language: es
Característica: Listar los veterinarios

  Dado el sistema de turnos para una veterinaria, como administrador, se listan
  los veterinario que atiende las especies.

  Escenario: El administrador lista los veterinarios cargados en el sistema
    Dado el sistema con veterinarios cargados
    O sin veterinarios cargados
    Cuando el admin pide la lista de veterinarios
    Y la acción se realiza a través de la API REST
    Y la llamada se hace a la ruta '/veterinario'
    Y el verbo HTTP es 'GET'
    Entonces el sistema retorna el código 200
    Y un objeto representando la lista de especies
    Y el objeto es un JSON que respeta el formato:
    """
    [
      {
        "id": [NUMBER],
        "nombre": [STRING]
      }
    ]
    """
