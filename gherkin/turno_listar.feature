# language: es
Característica: Listar turnos pedidos

  Dado el sistema de turnos para una veterinaria, como administrador, se listan
  los turnos pedidos para atender a la mascota.

  Escenario: El administrador lista los turnos pedidos
    Dado el sistema con turnos pedidos
    O sin turnos pedidos
    Cuando el admin pide la lista de turnos pedidos
    Y la acción se realiza a través de la API REST
    Y la llamada se hace a la ruta '/turno'
    Y el verbo HTTP es 'GET'
    Entonces el sistema retorna el código 200
    Y un objeto representando la lista de especies
    Y el objeto es un JSON que respeta el formato:
    """
    [
      {
        "turno": [STRING],
        "mascota_id": [NUMBER],
        "veterinario_id": [NUMBER]
      }
    ]
    """
