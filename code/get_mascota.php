<?php

function handle_request()
{
    $list = [];

    $db = new SQLite3('database.sqlite');
    $result = $db->query('SELECT m.id AS mascota_id, m.nombre AS mascota_nombre, e.id AS especie_id FROM mascota m JOIN especie e ON m.especie_id = e.id');

    while ($row = $result->fetchArray(SQLITE3_ASSOC)) {
        $list[] = [
            'id' => $row['mascota_id'],
            'nombre' => $row['mascota_nombre'],
            'especie_id' => $row['especie_id'],
        ];
    }

    $db->close();

    echo json_encode($list);
}
