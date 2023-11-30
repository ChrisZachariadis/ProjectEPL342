<?php
session_start();

if (isset($_POST['Approve'])) {
  $serverName = $_SESSION["serverName"];
  $connectionOptions = $_SESSION["connectionOptions"];
  $conn = sqlsrv_connect($serverName, $connectionOptions);

  if ($conn === false) {
    die(print_r(sqlsrv_errors(), true));

  }

  $tsql = "{call spApproveUser (?)}";
  $params = array($_POST['ID']);
  $getResults = sqlsrv_query($conn, $tsql, $params);
  if ($getResults === false) {
    die(print_r(sqlsrv_errors(), true));
  }
  sqlsrv_free_stmt($getResults);
  sqlsrv_close($conn);
  header("Location: unapproved-owners.php");
}
function display()
{

  $serverName = $_SESSION["serverName"];
  $connectionOptions = $_SESSION["connectionOptions"];
  $conn = sqlsrv_connect($serverName, $connectionOptions);

  if ($conn === false) {
    die(print_r(sqlsrv_errors(), true));

  }

  $tsql = "{call spView_Unapproved ()}";
  $getResults = sqlsrv_query($conn, $tsql);
  if ($getResults === false) {
    die(print_r(sqlsrv_errors(), true));
  }


  while ($row = sqlsrv_fetch_array($getResults, SQLSRV_FETCH_ASSOC)) {
    $UserID = $row["User_ID"];
    $DOB = $row["Date_of_Birth"];
    $FName = $row["First_Name"];
    $LName = $row["Last_Name"];
    $Email = $row["Email"];
    $DOB = $row["Date_of_Birth"]->format('Y-m-d');

    echo "<div class='row'>
<div class='col-md-12'>
<div class=\"unapproved-owners-product\">
<span class=\"unapproved-owners-user-id\">
  <span>User ID</span>
  <br />
</span>
<span class=\"unapproved-owners-date\">
  <span>Date Of Birth</span>
  <br />
</span>
<span class=\"unapproved-owners-fname\">First Name</span>
<span class=\"unapproved-owners-id-value\">
  <span>$UserID</span>
  <br />
</span>
<span class=\"unapproved-owners-date-value\">$DOB</span>
<span class=\"unapproved-owners-f-name-value\">$FName</span>
<span class=\"unapproved-owners-l-name-value\">$LName</span>
<span class=\"unapproved-owners-email-value\">
  $Email
</span>
<span class=\"unapproved-owners-last-name\">
  <span>Last Name</span>
  <br />
</span>
<span class=\"unapproved-owners-email\">
  <span>Email</span>
  <br />
</span>
<form method=\"post\">

<input type=\"hidden\" name=\"ID\" value=\"$UserID\">
<input type=\"hidden\" name=\"Approve\" value=\"1\">

<button type=\"submit\" class=\"unapproved-owners-approve button\">
  <span class=\"unapproved-owners-text11\">
    <span>Approve</span>
    <br />
  </span>
</button>
</form>
</div>
</div>
</div>";
  }

  sqlsrv_free_stmt($getResults);
  sqlsrv_close($conn);
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
  <title>UnapprovedOwners - Comfortable Favorite Mongoose</title>
  <meta property="og:title" content="UnapprovedOwners - Comfortable Favorite Mongoose" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta charset="utf-8" />
  <meta property="twitter:card" content="summary_large_image" />

  <style data-tag="reset-style-sheet">
    html {
      line-height: 1.15;
    }

    body {
      margin: 0;
    }

    * {
      box-sizing: border-box;
      border-width: 0;
      border-style: solid;
    }

    p,
    li,
    ul,
    pre,
    div,
    h1,
    h2,
    h3,
    h4,
    h5,
    h6,
    figure,
    blockquote,
    figcaption {
      margin: 0;
      padding: 0;
    }

    button {
      background-color: transparent;
    }

    button,
    input,
    optgroup,
    select,
    textarea {
      font-family: inherit;
      font-size: 100%;
      line-height: 1.15;
      margin: 0;
    }

    button,
    select {
      text-transform: none;
    }

    button,
    [type="button"],
    [type="reset"],
    [type="submit"] {
      -webkit-appearance: button;
    }

    button::-moz-focus-inner,
    [type="button"]::-moz-focus-inner,
    [type="reset"]::-moz-focus-inner,
    [type="submit"]::-moz-focus-inner {
      border-style: none;
      padding: 0;
    }

    button:-moz-focus,
    [type="button"]:-moz-focus,
    [type="reset"]:-moz-focus,
    [type="submit"]:-moz-focus {
      outline: 1px dotted ButtonText;
    }

    a {
      color: inherit;
      text-decoration: inherit;
    }

    input {
      padding: 2px 4px;
    }

    img {
      display: block;
    }

    html {
      scroll-behavior: smooth
    }
  </style>
  <style data-tag="default-style-sheet">
    html {
      font-family: Inter;
      font-size: 16px;
    }

    body {
      font-weight: 400;
      font-style: normal;
      text-decoration: none;
      text-transform: none;
      letter-spacing: normal;
      line-height: 1.15;
      color: var(--dl-color-gray-black);
      background-color: var(--dl-color-gray-white);

    }
  </style>
  <link rel="stylesheet"
    href="https://fonts.googleapis.com/css2?family=Nunito:ital,wght@0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&amp;display=swap"
    data-tag="font" />
  <link rel="stylesheet"
    href="https://fonts.googleapis.com/css2?family=Raleway:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&amp;display=swap"
    data-tag="font" />
  <link rel="stylesheet"
    href="https://fonts.googleapis.com/css2?family=Lato:ital,wght@0,100;0,300;0,400;0,700;0,900;1,100;1,300;1,400;1,700;1,900&amp;display=swap"
    data-tag="font" />
  <link rel="stylesheet"
    href="https://fonts.googleapis.com/css2?family=Inter:wght@100;200;300;400;500;600;700;800;900&amp;display=swap"
    data-tag="font" />
</head>

<body>
  <div>
    <link href="./css/unapproved-owners.css" rel="stylesheet" />
    <link rel="stylesheet" type="text/css" href="bootstrap/css/bootstrap.min.css">

    <div class="unapproved-owners-container">
      <span class="unapproved-owners-text">UNAPPROVED PROPERTY OWNERS</span>
      <a href="home.html" class="unapproved-owners-navlink">GREECE BOOKING</a>
      <div class="unapproved-owners-list-container">
        <div class="container-fluid">

          <?php display(); ?>

        </div>
      </div>
    </div>
  </div>
</body>

</html>