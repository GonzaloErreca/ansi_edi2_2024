<?php

function handle_request($id, $input)
{
    $db = new SQLite3('database.sqlite');
    $row = $db->querySingle("SELECT id, nombre FROM especie WHERE id = {$id}", true);
    $db->exec("DELETE FROM especie WHERE id={$id}");
    $db->close();

    $especie = [
        'id' => $id,
        'nombre' => $row['nombre'],
    ];

    echo json_encode($especie);
}
