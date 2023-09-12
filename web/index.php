<?php

if ($_SERVER['REQUEST_URI'] == '/') {
  http_response_code(307);
  header('Location: https://github.com/darrarski/darrarski-app');
} else {
  http_response_code(404);
  echo("not found");
}

exit();
