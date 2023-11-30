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

  $tsql = "{call spLOGIN (?, ?)}";
  $params = array($email, $password); // replace 'Electronics' with the category you want
  $getResults = sqlsrv_query($conn, $tsql, $params);

  if ($getResults === false) {
    $message = "Wrong credentials."; // Your message
echo "<script type='text/javascript'>",
     "window.onload = function() {",
     "  setTimeout(function() {",
     "    alert('$message');",
     "    window.location.href = 'Login.php';",
     "  }, 1000);", // Delays the alert by 1000 milliseconds (1 second)
     "};",
     "</script>";    
    exit;
  }

  $row = sqlsrv_fetch_array($getResults, SQLSRV_FETCH_ASSOC);
  var_dump($row);
  $_SESSION['UserID'] = $row['user_id'];
  $_SESSION['UserType'] = $row['User_Type'];
  $_SESSION['LoggedIn'] = true;
if ($row['User_Type'] == 'Admin') {
  echo '<script type="text/javascript">',
    'window.onload = function() {',
    '  alert("Succesfully Loged In.(ADMIN) ");',
    '  window.location.href = "AdminCatalogueProperties.php";',
    '};',
    '</script>';
    exit;
    }


if($row['User_Type'] == 'Property Owner' && $row['Approved'] == 'Y'){
  echo '<script type="text/javascript">',
    'window.onload = function() {',
    '  alert("Succesfully Loged In.(Property Owner) ");',
    '  window.location.href = "AdminCatalogueProperties.php";',
    '};',
    '</script>';
    exit;
}else if($row['Approved'] == 'N'){
  echo '<script type="text/javascript">',
    'window.onload = function() {',
    '  alert("Not Approved ");',
    '  window.location.href = "Login.php";',
    '};',
    '</script>';
    exit;
}

echo '<script type="text/javascript">',
    'window.onload = function() {',
    '  alert("Not Approved ");',
    '  window.location.href = "BookSearch.php";',
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

  <form method="POST" action="Login.php">
    <div class="form-field">
      <input type="email" name="email" placeholder="Email" required />
    </div>

    <div class="form-field">
      <input type="password" name="password" placeholder="Password" required />
    </div>

    <div class="form-field left">
      <button class="btn" type="submit">Log in</button>
    </div>

    <div class="form-field">
      <a href="Register.php" class="Register">New User? Register</a>
    </div>
  </form>
  <!-- partial -->

</body>

</html>