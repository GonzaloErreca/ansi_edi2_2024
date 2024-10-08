# language: es
Característica: Eliminar un veterinario

  Dado el sistema de turnos para una veterinaria, como administrador, se elimina
  un veterinario que atiende las especies.

  Escenario: El administrador elimina un veterinario existente
    Dado un veterinario cargado en el sistema
    E identificado por un ID
    Cuando el admin elimina al veterinario
    Y la acción se realiza a través de la API REST
    Y la llamada se hace a la ruta '/veterinario/{ID}'
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
