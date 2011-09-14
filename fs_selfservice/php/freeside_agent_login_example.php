<?

require('freeside.class.php');
$freeside = new FreesideSelfService();

$response = $freeside->agent_login( array( 
  'username' => strtolower($_POST['username']),
  'password' => strtolower($_POST['password']),
) );

error_log("[login] received response from freeside: $response");
$error = $response['error'];

if ( ! $error ) {

    // sucessful login

    $session_id = $response['session_id'];

    error_log("[login] agent logged into freeside with session_id=$session_id");

    // store session id in your session store, to be used for other calls

} else {

    // unsucessful login

    error_log("[login] error logging agent into freeside: $error");

    // display error message to user

}

?>
