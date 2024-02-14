<?php
// echo "We are unsubscribe you.<br>\n";

if (!(isset($_GET['mail']) && isset($_GET['token']))) {
	exitError("Missing parameters");
}
$mail = $_GET['mail'];
$token = $_GET['token'];
if (!preg_match('/^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$/', $mail)) {
	exitError("Wrong mail ($mail)");
}
if (!preg_match('/^[a-zA-Z-0-9]{64}$/', $token)) {
	exitError("Wrong token ($token)");
}

$cnx = newConnection();
$sql = 'UPDATE openproduct.producer
	SET sendEmail="Never"
	WHERE email="'.$mail.'"
		AND tokenAccess="'.$token.'"';
try {
	// echo "SQL:$sql;<br>\n";
	$res = $cnx->query($sql);
	if ($res===false) {
		exitError("QueryError");
	}
	// $obj = $res->fetchObject();

	echo "'$mail' ne reçevra plus d'email de notre part.<br>\n";
} catch(Exception $e) {
	exitError("Catch : ".$e->getMessage());
}

function exitError($msg) {
	global $mail, $token;
	echo "ERROR $msg.";
	exit();
}
function newConnection() {
	$cfgfile = 'db/connection.yml';
	$cfg = yaml_parse_file($cfgfile);
	$mycfg = $cfg['prod'];
	$conn = new mysqli($mycfg['host'], $mycfg['username'], $mycfg['password'], $mycfg['database']);
	// Check connection
	if ($conn -> connect_errno) {
	  echo "Failed to connect to MySQL: " . $mysqli -> connect_error;
	  exit();
	}
	return $conn;
}

