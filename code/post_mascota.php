<?php

function handle_request($id, $input)
{
    $input = json_decode($input, true);

    $db = new SQLite3('database.sqlite');
    $db->exec("INSERT INTO mascota (nombre, especie_id) VALUES ('{$input['nombre']}', '{$input['especie_id']}')");
    $id = $db->lastInsertRowID();
    $db->close();

    echo json_encode([
        'id' => $id,
        'nombre' => $input['nombre'],
        'especie_id' => $input['especie_id'],
    ]);
}
