<?php
session_start();
if ($_SERVER["REQUEST_METHOD"] == "POST") {
  $FName = $_POST["FName"];
  $LName = $_POST["LName"];
  $email = $_POST['email'];
  $passwd = $_POST['passwd'];
  $birth = $_POST['birth'];
  $gender = $_POST['gender'];
  $UserType = $_POST['type'];

  $serverName = $_SESSION["serverName"];
  $connectionOptions = $_SESSION["connectionOptions"];
  $conn = sqlsrv_connect($serverName, $connectionOptions);

  if ($conn === false) {
    die(print_r(sqlsrv_errors(), true));
  }

  $tsql = "{call spRegister_User (?, ?, ?, ?, ?, ?, ?)}";
  $params = array($birth, $UserType, $FName, $LName, $email, $passwd, $gender); // replace 'Electronics' with the category you want
  $getResults = sqlsrv_query($conn, $tsql, $params);
 
  if ($getResults === false) {
    echo '<script type="text/javascript">',
     'window.onload = function() {',
     '  alert("Email already exists. ");',
     '  window.location.href = "Register.php";',
     '};',
     '</script>';
  }else{
  echo '<script type="text/javascript">',
     'window.onload = function() {',
     '  alert("Succesfully Registered. ");',
     '  window.location.href = "Login.php";',
     '};',
     '</script>';
  }

  // Now you can use $email and $password
  // Remember to sanitize and validate these values before using them
}

?>

<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <title>Login Page with Background Image Example</title>
  <link rel="stylesheet" href="./css/Register.css">
  <link rel="stylesheet" href="vendor/jquery-ui/jquery-ui.min.css">
</head>

<body>
  <!-- partial:index.partial.html -->
  <div id="bg"></div>

  <form method="POST" action="">
    <div class="form-field">
      <input type="FName" name="FName" placeholder="First Name" required />
    </div>

    <div class="form-field">
      <input type="LName" name="LName" placeholder="Last Name" required />
    </div>

    <div class="form-field">
      <input type="email" name="email" placeholder="Email" required />
    </div>

    <div class="form-field">
      <input type="password" name="passwd" placeholder="Password" required />
    </div>

    <div class="form-field half left">
      <input type="text" id="birth" class="birth" name="birth" placeholder="Birthdate" required />
    </div>

    <div class="form-field half right">
    <select name="gender" required>
        <option value="">Gender</option>
        <option value="M">Male</option>
        <option value="F">Female</option>
        <option value="F">Attack Helicopter</option>
        <option value="F">Chair</option>
        <option value="F">PC</option>
        <option value="F">Kuma</option>
    </select>
  </div>

  <div class="form-field half center">
    <select name="type" required>
        <option value="">Type</option>
        <option value="Property Owner">Manager</option>
        <option value="Customer">Customer</option>
    </select>
  </div>

    <div class="form-field LoginButton">
      <button class="btn" type="submit">Register</button>
    </div>

    <div class="form-field Login">
      <a href="Login.php" class="Login">Already a user?Log In!</a>
    </div>
  </form>
  <!-- partial -->
  <script src="vendor/jquery/jquery.min.js"></script>
    <script src="vendor/jquery-ui/jquery-ui.min.js"></script>
    <script src="js/main.js"></script>
</body>

</html>