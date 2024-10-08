# language: es
Característica: Crear una mascota

  Dado el sistema de turnos para una veterinaria, como usuario o administrador,
  se cargan las mascotas para ser atendidas por los veterinarios.

  Escenario: El usuario (dueño) carga una nueva mascota
    Dada una mascota que no se encuentra registrada en el sistema
    Y una especie registrada en el sistema
    Cuando el usuario agrega la nueva mascota
    Y la asocia con la especie registrada
    Y la acción se realiza a través de la API REST
    Y la llamada se hace a la ruta '/mascota'
    Y el verbo HTTP es 'POST'
    Y se envía un objeto JSON que respeta el formato:
    """
    {
      "especie_id": [NUMBER],
      "name": [STRING]
    }
    """
    Entonces el sistema retorna el código 200
    Y un objeto representando a la mascota nueva
    Y el objeto es un JSON que respeta el formato:
    """
    {
      "id": [NUMBER],
      "especie_id": [NUMBER],
      "name": [STRING]
    }
    """
