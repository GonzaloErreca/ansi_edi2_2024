<?php 

function handle_request($id,$input) {
	    $input = json_decode($input, true);

	        $db = new SQLite3('database.sqlite');

	        $db->exec("INSERT INTO mascotas (nombre) VALUES ('{$input['name']}')");
		$id=$db->lastInsertRowId();
		$mascota=$db->querySingle("SELECT id,nombre FROM mascotas WHERE id={$id}",true);
		$db->close();

		echo json_encode([
			'id' => $mascota['id],
			'name'=> $mascota ['nombre'],
			]);,
 }
?>

