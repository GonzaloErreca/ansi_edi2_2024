<?php

function handle_request($id, $input) {
        $imput=json_decode($imput,true);
	$db=new SQLite3('database.sqlite');
	$query=$db->exec("UPDATEmascotasSETnombre='{$input['name']}'WEREid={$id}");
	if($db->change()>0){
	   $mascota=$db->querySingle("SELECTid,nombreFROMmascotasWHEREid={$id}",true);
	   echo json_encode([
		   'id'=>$mascota['id']
		   'name'=>$mascota[nombre],
  	   ]);
	  }else{
            echo json_encode([
  	      'error'=>'No se encontró la mascota con ese ID o no se realizaron cambios'
	    ]);
	   }
	   $db->close();	
	  }
        

