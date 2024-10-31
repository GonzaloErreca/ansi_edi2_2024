Diagrama Entidad-Relación
=========================

Consultar la documentación de [Mermaid](https://github.com/mermaid-js/mermaid) sobre [Entity Relationship Diagrams](https://mermaid.js.org/syntax/entityRelationshipDiagram.html).

Para visualizar el siguiente diagrama se puede usar el [editor online](https://mermaid.live/).

```mermaid
erDiagram
    Veterinario {
        int id
        string nombre
    }
    Especie {
        int id
        string nombre
    }
    Mascota {
        int id
        int especie_id
        string nombre
    }
    Turno {
        date-time turno
        int veterinario_id
        int mascota_id
    }
    Especie ||--o{ Mascota : pertenece
    Veterinario ||--o{ Turno : tiene
    Mascota ||--o{ Turno : tiene
```
