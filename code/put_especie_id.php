<?php

function handle_request($id, $input)
{
    $input = json_decode($input, true);

    $db = new SQLite3('database.sqlite');
    $db->exec("UPDATE especie SET nombre='{$input['nombre']}' where id={$id}");
    $db->close();

    $especie = [
        'id' => $id,
        'nombre' => $input['nombre'],
    ];

    echo json_encode($especie);
}
