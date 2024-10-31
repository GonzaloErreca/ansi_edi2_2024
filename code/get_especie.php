<?php

function handle_request()
{
    $list = [];

    $db = new SQLite3('database.sqlite');
    $result = $db->query('SELECT * FROM especie');

    while ($row = $result->fetchArray(SQLITE3_ASSOC)) {
        $list[] = [
            'id' => $row['id'],
            'nombre' => $row['nombre'],
        ];
    }

    $db->close();

    echo json_encode($list);
}
