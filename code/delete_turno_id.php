<?php

function handle_request($id, $input)
{
    $turno = $id[0];
    $petId = $id[1];

    $db = new SQLite3('database.sqlite');
    $row = $db->querySingle("SELECT * FROM turno WHERE turno = '{$turno}' and mascota_id = {$petId}", true);
    $db->exec("DELETE FROM turno WHERE turno = '{$turno}' and mascota_id = {$petId}");
    $db->close();

    echo json_encode([
        'turno' => $row['turno'],
        'mascota_id' => $row['mascota_id'],
    ]);
}
