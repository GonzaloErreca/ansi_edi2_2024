<?php

function handle_request()
{
    $list = [];

    $db = new SQLite3('database.sqlite');
    $result = $db->query('SELECT * FROM turno');

    while ($row = $result->fetchArray(SQLITE3_ASSOC)) {
        $list[] = [
            'turno' => $row['turno'],
            'mascota_id' => $row['mascota_id'],
            'veterinario_id' => $row['veterinario_id'],
        ];
    }

    $db->close();

    echo json_encode($list);
}
