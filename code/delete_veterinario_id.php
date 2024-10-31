<?php

function handle_request($id, $input)
{
    $db = new SQLite3('database.sqlite');
    $row = $db->querySingle("SELECT id, nombre FROM veterinario WHERE id = {$id}", true);
    $db->exec("DELETE FROM veterinario WHERE id={$id}");
    $db->close();

    $veterinario = [
        'id' => $id,
        'nombre' => $row['nombre'],
    ];

    echo json_encode($veterinario);
}
