<?php

function handle_request($id, $input)
{
    $input = json_decode($input, true);

    $db = new SQLite3('database.sqlite');
    $db->exec("INSERT INTO veterinario (nombre) VALUES ('{$input['nombre']}')");
    $id = $db->lastInsertRowID();
    $db->close();

    echo json_encode([
        'id' => $id,
        'nombre' => $input['nombre'],
    ]);
}
