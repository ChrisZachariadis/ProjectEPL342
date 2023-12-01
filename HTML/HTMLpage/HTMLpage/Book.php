<?php
session_start();

if($_SESSION['LoggedIn'] == false){
    echo '<script type="text/javascript">',
    'window.onload = function() {',
    '  alert("You need to Log In to book.");',
    '  window.location.href = "Login.php";',
    '};',
    '</script>';
    exit;
}


$ID = $_POST['ID'];
$date_from = $_SESSION['date_from'];
$date_to = $_SESSION['date_to'];

$UserID = $_SESSION['UserID'];

$serverName = $_SESSION["serverName"];
$connectionOptions = $_SESSION["connectionOptions"];
$conn = sqlsrv_connect($serverName, $connectionOptions);

if ($conn === false) {
    die(print_r(sqlsrv_errors(), true));
}

$tsql = "{call makeReservation (?, ?, ?, ?)}";
$params = array($ID, $UserID, $date_from, $date_to);

$getResults = sqlsrv_query($conn, $tsql, $params);
if ($getResults === false) {
    die(print_r(sqlsrv_errors(), true));
}

sqlsrv_free_stmt($getResults);
sqlsrv_close($conn);


header('Location: reservations.php');
?>