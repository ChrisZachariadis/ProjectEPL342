<?php
session_start();

if (isset($_POST['ID'])) {
// if($_SESSION['Logedin'] == false){
//     header("Location: login.php");
// }

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
    $getResults = sqlsrv_query($conn, $tsql, $params);


    if ($getResults === false) {
        die(print_r(sqlsrv_errors(), true));
    }
    while ($row = sqlsrv_fetch_array($getResults, SQLSRV_FETCH_ASSOC)) {
        print_r(sqlsrv_errors());
        if (isset($row['Reservation_ID'])) {
            $ans = $row['Reservation_ID'];
            print_r($ans);
        } else {
            echo "Reservation_ID does not exist in the row";
        }
        print_r($ans);
    }

    sqlsrv_free_stmt($getResults);
    sqlsrv_close($conn);
    
}

if (isset($_POST['RID'])) {
    $RID = $_POST['RID'];
    $REVIEW = 3;
    $TEXT = 'NO REVIEW';

    $serverName = $_SESSION["serverName"];
    $connectionOptions = $_SESSION["connectionOptions"];
    $conn = sqlsrv_connect($serverName, $connectionOptions);

    if ($conn === false) {
        die(print_r(sqlsrv_errors(), true));
    }

    $tsql = "{call makeReview (?)}";
    $params = array($RID, $TEXT, $REVIEW); // replace 'Electronics' with the category you want
    $ans = sqlsrv_query($conn, $tsql, $params);

    if ($and == false) {
        die(print_r(sqlsrv_errors(), true));
    }

    sqlsrv_free_stmt($getResults);
    sqlsrv_close($conn);
}
?>

<!DOCTYPE html>
<html>

<head>
    <title>Page Title</title>
</head>

<body>

    <form method="POST" action="booking.php">
        <input type="hidden" name="RID" value="<?php echo $ans; ?>">
        <input type="hidden" name="REVIEW" value="1">
        <button type="button" id='myButton' class='MyButton'>Click Me!</button>
</body>

</html>