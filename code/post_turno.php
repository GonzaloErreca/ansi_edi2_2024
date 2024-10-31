<?php

function handle_request($id, $input)
{
    $input = json_decode($input, true);
    $appointment = $input['turno'];
    $petId = $input['mascota_id'];

    $db = new SQLite3('database.sqlite');

    $veterinaries = [];

    $result = $db->query('SELECT id FROM veterinario');

    while ($row = $result->fetchArray(SQLITE3_ASSOC)) {
        $veterinaries[] = $row['id'];
    }

    $result = $db->query("SELECT veterinario_id FROM turno WHERE turno = '{$appointment}'");

    while ($row = $result->fetchArray(SQLITE3_ASSOC)) {
        $key = array_search($row['veterinario_id'], $veterinaries);
        if (false != $key) {
            unset($veterinaries[$key]);
        }
    }

    $veterinaryId = array_shift($veterinaries);

    $db->exec("INSERT INTO turno (turno, mascota_id, veterinario_id) VALUES ('{$appointment}', '{$petId}', '{$veterinaryId}')");

    $db->close();

    echo json_encode([
        'turno' => $appointment,
        'mascota_id' => $petId,
    ]);
}
