<?php

// Response 'Content-Type' header
header('Content-Type: application/json');

// @see https://stackoverflow.com/a/61856861
header("Access-Control-Allow-Origin: *");
header('Access-Control-Allow-Methods: GET, POST, PATCH, PUT, DELETE, OPTIONS');
header("Access-Control-Allow-Headers: Content-Type, Accept, Origin, Access-Control-Allow-Headers");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    return;
}

// Flag that tells if the 'Accept' header in the request is invalid
$invalidAccept = '*/*' != $_SERVER['HTTP_ACCEPT'] && 'application/json' != $_SERVER['HTTP_ACCEPT'];

// Do not accept requests which 'Accept' header isn't one of the above
if ($invalidAccept) {
    header('HTTP/1.1 406 Not Acceptable');
    exit;
}

// Get request method and path
$method = strtolower($_SERVER['REQUEST_METHOD']);
$uri = parse_url($_SERVER['REQUEST_URI']);
$path = trim(trim($uri['path']), '/');

// Default 'resource' and 'id' values
$resource = 'root';
$id = null;

// Get 'resource' and 'id' values
if ($path) {
    $path = explode('/', $path);
    $resource = $path[0];
    if (!empty($path[1])) {
        $id = (int) $path[1];
    }
}

// Default 'input' value
$input = null;

// Get 'input' value
if ('post' == $method || 'put' == $method) {
    $input = file_get_contents('php://input');
}

// File name (convention) from where the logic will be loaded
$fileName = strtolower("{$method}_{$resource}");
$fileName.= $id ? '_id' : '';
$fileName.= '.php';

// The logic must be under the `code` directory
$fileName = "code/{$fileName}";

// Function name (convention) that handles the request
//
// The function will receive the following parameters:
//
// * Parameter 1: int|null    $id    The item ID (if it's present)
// * Parameter 2: string|null $input The input value (if it's present)
$functionName = 'handle_request';

// Load and call the logic that handles the request
if (is_readable($fileName)) {
    require_once($fileName);
    if (function_exists($functionName)) {
        $functionName($id, $input);
        exit;
    }
}

// Default (404) response code
header('HTTP/1.1 404 Not Found');
