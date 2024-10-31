<?php

function handle_request($id, $input)
{
    $input = json_decode($input, true);

    $db = new SQLite3('database.sqlite');
    $db->exec("UPDATE veterinario SET nombre='{$input['nombre']}' where id={$id}");
    $db->close();

    $veterinario = [
        'id' => $id,
        'nombre' => $input['nombre'],
    ];

    echo json_encode($veterinario);
}
