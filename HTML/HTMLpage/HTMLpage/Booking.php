<?php
session_start();

if (isset($_POST['ID'])) {


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
    $ID=5;
    $UserID=1;
    $date_from='2023-01-22';
    $date_to='2023-01-22';
    $params = array($ID, $UserID, $date_from, $date_to);
    sqlsrv_query($conn, $tsql, $params);

    $tsql ="{call getID}";
    $getResults = sqlsrv_query($conn, $tsql);
    var_dump($getResults);
    if ($getResults === false) {
        die(print_r(sqlsrv_errors(), true));
    }
    $row = sqlsrv_fetch_array($getResults, SQLSRV_FETCH_ASSOC);
    $ans = $row['Reservation_ID'];
    sqlsrv_free_stmt($getResults);
    sqlsrv_close($conn);
    
}

if (isset($_POST['RID'])) {
    $RID = (int)$_POST['RID'];
    $REVIEW = 3;
    $TEXT = 'NO REVIEW';

    $serverName = $_SESSION["serverName"];
    $connectionOptions = $_SESSION["connectionOptions"];
    $conn = sqlsrv_connect($serverName, $connectionOptions);

    if ($conn === false) {
        die(print_r(sqlsrv_errors(), true));
    }

    $tsql = "{call makeReview (?, ?, ?)}";
    $params = array($RID, $TEXT, $REVIEW); // replace 'Electronics' with the category you want
    $ans = sqlsrv_query($conn, $tsql, $params);
    var_dump($ans);
    if ($ans == false) {
        die(print_r(sqlsrv_errors(), true));
    }

    sqlsrv_free_stmt($ans);
    sqlsrv_close($conn);
}
?>

<!DOCTYPE html>
<html>

<head>
    <title>Page Title</title>
</head>

<body>
<?php 
if($_SESSION['Logedin'] == false){
    echo '<script type="text/javascript">',
    'window.onload = function() {',
    '  alert("You need to Log In to book.");',
    '  window.location.href = "Login.php";',
    '};',
    '</script>';
}
?>
    <form method="POST" action="Booking.php">
        <input type="hidden" name="RID" value="<?php echo $ans; ?>">
        <input type="hidden" name="REVIEW" value="1">
        <button type="submit" id='myButton' class='MyButton'>Click Me!</button>
</body>

</html>