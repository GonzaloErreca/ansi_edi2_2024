<?php

function handle_request($id, $input) {
    $db = new SQLite3('database.sqlite');
    $id = $db->querySingle("SELECT id FROM mascotas WHERE id = {$id}");

    if (empty($id)) {
        header('HTTP/1.1 404 Not Found');
    } else {
        $db->exec("SELECT FROM mascotas WHERE id = {$id}");     
    }

    $db->close();
}
