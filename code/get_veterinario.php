<?php

function handle_request($id, $input) {
    $list = [];

    $db = new SQLite3('database.sqlite');
    $result = $db->query("SELECT * FROM veterinarios");

    while ($row = $result->fetchArray(SQLITE3_ASSOC)) {
        $list[] = [
            'id' => $row['id'],
            'name' => $row['nombre'],
	
        ];
    }

    $db->close();
