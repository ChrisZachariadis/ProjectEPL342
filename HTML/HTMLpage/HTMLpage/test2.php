<?php
session_start();


$serverName = $_SESSION["serverName"];
$connectionOptions = $_SESSION["connectionOptions"];
$conn = sqlsrv_connect($serverName, $connectionOptions);


$tsql = "{call CalculateOccupancyRate(?, ?, ?, ?, ?)}";
//$params = array("1/1/2023", "12/31/2023", "empty", "empty", "empty");
$params = array('1/1/2023', '12/31/2023', 'empty', 'empty', 'empty');

$getResults = sqlsrv_query($conn, $tsql, $params);

if ($getResults === false) {
    die(print_r(sqlsrv_errors(), true));
}

do {
    while ($row = sqlsrv_fetch_array($getResults, SQLSRV_FETCH_ASSOC)) {
        print_r($row);
    }
} while (sqlsrv_next_result($getResults));

sqlsrv_free_stmt($getResults);
?>