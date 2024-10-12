<?php

function handle_put_request($id, $input) {
	    $input = json_decode($input, true);
	        $db = new SQLite3('database.sqlite');
	        $query = $db->exec("UPDATE veterinarios SET nombre = '{$input['name']}' WHERE id = {$id}");
		    if ($db->changes() > 0) {

			            $veterinario = $db->querySingle("SELECT id, nombre FROM veterinarios WHERE id = {$id}", true);

				            echo json_encode([
						                'id' => $veterinario['id'],
								            'name' => $veterinario['nombre'],
									            ]);
				        } else {
						        echo json_encode([
								            'error' => 'No se encontró el veterinario con ese ID o no se realizaron cambios.'
									            ]);
							    }
		    $db->close();
}
>


