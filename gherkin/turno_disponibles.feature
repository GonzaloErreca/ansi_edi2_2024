# language: es
Característica: Listar turnos disponibles

  Dado el sistema de turnos para una veterinaria, como usuario (dueño), se
  listan los turnos disponibles para atender las mascotas.

  Escenario: El usuario lista los turnos disponibles
    Dado el sistema con veterinarios cargados
    Cuando el usuario pide la lista de turnos disponibles
    Y la acción se realiza a través de la API REST
    Y la llamada se hace a la ruta '/disponibles'
    Y el verbo HTTP es 'GET'
    Entonces el sistema retorna el código 200
    Y un objeto representando la lista de turnos
    Y el objeto es un JSON que respeta el formato:
    """
    [
      [STRING]
    ]
    """
    Y cada turno respeta el estándar ISO 8601 con el formato "YYYY-MM-DDThh:mm:ss±hh:mm"
