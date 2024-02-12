<?php
require_once dirname( __FILE__ ) . '/includes/PHPVersionCheck.php';
require __DIR__ . '/includes/WebStart.php';

use MediaWiki\MediaWikiServices;
use Wikimedia\Rdbms\Database;
use Wikimedia\Rdbms\DatabaseMysqlBase;
use Wikimedia\Rdbms\DBQueryDisconnectedError;
use Wikimedia\Rdbms\DBQueryError;
use Wikimedia\Rdbms\DBQueryTimeoutError;
use Wikimedia\Rdbms\DBSessionStateError;
use Wikimedia\Rdbms\DBTransactionStateError;
use Wikimedia\Rdbms\DBUnexpectedError;
use Wikimedia\Rdbms\IDatabase;
use Wikimedia\Rdbms\TransactionManager;

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
	$res = $cnx->query($sql, __METHOD__);
	if ($res===false) {
		exitError("QueryError");
	}
	// $obj = $res->fetchObject();

	echo "'$mail' ne reçevra plus d'email de notre part.<br>\n";
} catch(Exception $e) {
	exitError("Catch : ".$e->getMessage());
}

function exitError($msg) {
	echo "ERROR $msg.";
	exit();
}
function newConnection() {
	$lb = MediaWikiServices::getInstance()->getDBLoadBalancer();
	$dbFactory = MediaWikiServices::getInstance()->getDatabaseFactory();
	/** @var DatabaseMysqlBase $conn */
	$conn = $dbFactory->create(
		'mysql',    
		array_merge(
			$lb->getServerInfo( 0 ),
			[
				'dbname' => null,
				'schema' => null,
				'tablePrefix' => '',
			]
		)
	);
			
	return $conn;
}

