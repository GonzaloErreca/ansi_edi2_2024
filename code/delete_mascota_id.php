<?php

function handle_request($id, $input)
{
    $db = new SQLite3('database.sqlite');
    $row = $db->querySingle("SELECT id, nombre, especie_id FROM mascota WHERE id = {$id}", true);
    $db->exec("DELETE FROM mascota WHERE id = {$id}");
    $db->close();

    $mascota = [
        'id' => $id,
        'nombre' => $row['nombre'],
        'especie_id' => $row['especie_id'],
    ];

    echo json_encode($mascota);
}
