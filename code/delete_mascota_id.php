<?php
	function handle_request($id,$imput) {
		$db=new
		SQlite3('database.sqlite');
		$id=$db->querySingle("SELECT id FROM especies WHERE id = {$id}");
		
		if (empty($id)){
			header('HTTP/1.1 404 Not Found');
		}else{
			$db->exec("DELETE FROM especies WHERE id = {$id}";
			#$db->exec("DELETE FROM turnos WHERE especie_id = {$id};}
			$db->close();
				
		
		}

