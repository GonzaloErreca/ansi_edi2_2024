<?php

function handle_request($id, $input) {
	    $input = json_decode($input, true);

	        $db = new SQLite3('database.sqlite');
	        $db->exec("INSERT INTO veterinarios (nombre) VALUES ('{$input['name']}')");
		    $id = $db->lastInsertRowID();
		    $veterinario = $db->querySingle("SELECT id, nombre FROM veterinarios WHERE id = {$id}", true);
		        $db->close();

		        echo json_encode([
				        'id' => $veterinario['id'],
					        'name' => $veterinario['nombre'],
						    ]);
}
>

