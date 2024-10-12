<?php

function handle_request($id, $input) {
    $input = json_decode($input, true);

    $db = new SQLite3('database.sqlite');
    $db->exec("INSERT INTO especies (nombre) VALUES ('{$input['name']}')");
    $id = $db->lastInsertRowID();
    $especie = $db->querySingle("SELECT id, nombre FROM especies WHERE id = {$id}", true);
    $db->close();

    echo json_encode([
        'id' => $especie['id'],
        'name' => $especie['nombre'],
    ]);
}
>
