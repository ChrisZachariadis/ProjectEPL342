<?php
session_start();
if ($_SERVER["REQUEST_METHOD"] == "POST") {
  $email = $_POST['email'];
  $password = $_POST['password'];


  $serverName = $_SESSION["serverName"];
  $connectionOptions = $_SESSION["connectionOptions"];
  $conn = sqlsrv_connect($serverName, $connectionOptions);

  if ($conn === false) {
    die(print_r(sqlsrv_errors(), true));
  }

  // $tsql = "{call getProduct (?)}";
  // $params = array($Location); // replace 'Electronics' with the category you want
  // $getResults = sqlsrv_query($conn, $tsql, $params);
  // if ($getResults === false) {
  //   die(print_r(sqlsrv_errors(), true));
  // }

  // $row = sqlsrv_fetch_array($getResults, SQLSRV_FETCH_ASSOC);
  // $row = $row['User_ID'];
  $_SESSION['LogedIn'] = true;
  // $_SESSION['UserID'] = $row;
  echo '<script type="text/javascript">',
     'window.onload = function() {',
     '  alert("Succesfully Loged In.");',
     '  window.location.href = "Home.php";',
     '};',
     '</script>';

}

?>

<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <title>Login Page with Background Image Example</title>
  <link rel="stylesheet" href="./css/Login.css">

</head>

<body>
  <!-- partial:index.partial.html -->
  <div id="bg"></div>

  <form method="POST">
    <div class="form-field">
      <input type="email" placeholder="Email" required />
    </div>

    <div class="form-field">
      <input type="password" placeholder="Password" required />
    </div>

    <div class="form-field">
      <button class="btn" type="submit">Log in</button>
    </div>
  </form>
  <!-- partial -->

</body>

</html>