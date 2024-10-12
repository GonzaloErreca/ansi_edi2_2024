<?php

function handle_put_request($id, $input) {
    $input = json_decode($input, true);
    $db = new SQLite3('database.sqlite');
    $query = $db->exec("UPDATE especies SET nombre = '{$input['name']}' WHERE id = {$id}");
    if ($db->changes() > 0) {

        $especie = $db->querySingle("SELECT id, nombre FROM especies WHERE id = {$id}", true);

        echo json_encode([
            'id' => $especie['id'],
            'name' => $especie['nombre'],
        ]);
    } else {
        echo json_encode([
            'error' => 'No se encontró la especie con ese ID o no se realizaron cambios.'
        ]);
    }
    $db->close();
}
>
