Desarrollo y Ejecución del Sistema
==================================


## Dependencias de PHP

Las dependencias de PHP (herramientas o librerías) se administran con [composer](https://getcomposer.org).

Para instalar las dependencias de PHP usar el siguiente comando:

```bash
composer install
```


## Sintaxis y Estilo

La sintaxis del código PHP se puede controlar usando el siguiente comando:

```bash
php -l [ARCHIVO.PHP]
```

Se puede corregir el estilo del código con [Laravel Pint](https://laravel.com/docs/11.x/pint):

```bash
vendor/bin/pint --preset symfony [ARCHIVO.PHP]
```


## SQLite

Primero hay que [instalar sqlite](https://codigofacilito.com/articulos/configurando-sqlite).

Para ([termux](https://termux.dev/en/)), el comando para instalar SQLite es:

```
$ pkg install sqlite
```

Controlar que SQLite esté [habilitado en PHP](https://www.php.net/manual/es/sqlite3.installation.php).

```
$ php -i | grep -i 'sqlite' | grep -i 'ena'
PDO Driver for SQLite 3.x => enabled
SQLite3 support => enabled
```

Crear la base de datos con el siguiente comando:

```
$ sqlite3 database.sqlite < esquema-ddbb.sql
```

En la siguiente página se puede aprender un poco más sobre SQLite: [SQLite PHP](https://desarrolloweb.com/articulos/sqlite-php).


## Ejecutar la aplicación

La aplicación (servicio) se puede ejecutar con el siguiente comando:

```bash
php -S 0.0.0.0:8080 rest-api.php
```

Donde:

* `0.0.0.0`: Es la IP desde donde se puede usar el servicio. En éste caso se puede usar desde cualquier IP.
* `8080`: Es el puerto en el cual escucha el servicio.
* `rest-api.php`: Es el archivo que se ejecutará cada vez que se realice una llamada al servicio.
