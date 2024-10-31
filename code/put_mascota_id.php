<?php

function handle_request($id, $input)
{
    $input = json_decode($input, true);

    $db = new SQLite3('database.sqlite');
    $db->exec("UPDATE mascota SET nombre = '{$input['nombre']}', especie_id = '{$input['especie_id']}' WHERE id = {$id}");
    $db->close();

    $mascota = [
        'id' => $id,
        'nombre' => $input['nombre'],
        'especie_id' => $input['especie_id'],
    ];

    echo json_encode($mascota);
}
