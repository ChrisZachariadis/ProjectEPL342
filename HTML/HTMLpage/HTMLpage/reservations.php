<?php
session_start();
function display()
{
  $serverName = $_SESSION["serverName"];
  $connectionOptions = $_SESSION["connectionOptions"];
  $conn = sqlsrv_connect($serverName, $connectionOptions);

  if ($conn === false) {
    die(print_r(sqlsrv_errors(), true));
  }
  $ID = $_SESSION['UserID'];

  $tsql = "{call spViewReservations (?)}";
  $params = array($ID); // replace 'Electronics' with the category you want
  $getResults = sqlsrv_query($conn, $tsql, $params);

  if ($getResults === false) {
    die(print_r(sqlsrv_errors(), true));
  }
$counter = 0;
  while ($row = sqlsrv_fetch_array($getResults, SQLSRV_FETCH_ASSOC)) {
    $Status = $row['Reservation_Statuses'];
    $Status = strtok($Status, ",");
    $Date = $row['Reservation_Dates'];
    $PropertyN = $row['Property_Name'];
    $Fine = $row['Reservation_Fines'];
    $Fine = strtok($Fine, ",");
    //$Name = $row['Product_Name'];
    $RID = $row['Reservation_IDs'];

    echo "<div class=\"row\">
    <div class=\"col-md-12\">
      <div class=\"reservations-product\">
        <span class=\"reservations-user-id\">
          <span>Status</span>
          <br />
        </span>
        <span class=\"reservations-fname\">
          <span>Reservation&nbsp;</span>
          <span>date</span>
          <br />
        </span>
        <span class=\"reservations-id-value\">
          <span>$Status</span>
          <br />
        </span>
        <span class=\"reservations-date-value\">$Date</span>
        <span class=\"reservations-l-name-value\">$PropertyN</span>
        <span class=\"reservations-last-name\">
          <span>Property Name</span>
          <br />
        </span>";
    if ($Status == "Finished") {
      $counter = $counter+1;
      echo "
        <form method='POST'>
        <input type=\"hidden\" name=\"RID\" value=\"$RID\">
        <input type=\"hidden\" name=\"REVIEW\" value=1>
        <button type=\"submit\" class=\"reservations-approve button\">
          <span class=\"reservations-text10\">Review</span>
        </button>
        
        <div class=\"stars\">
    <input class=\"star star-5\" id=\"star-5-{$counter}\" type=\"radio\" name=\"star\" value=\"5\"/>

    <label class=\"star star-5\" for=\"star-5-{$counter}\"></label>

    <input class=\"star star-4\" id=\"star-4-{$counter}\" type=\"radio\" name=\"star\" value=\"4\"/>

    <label class=\"star star-4\" for=\"star-4-{$counter}\"></label>

    <input class=\"star star-3\" id=\"star-3-{$counter}\" type=\"radio\" name=\"star\" value=\"3\"/>

    <label class=\"star star-3\" for=\"star-3-{$counter}\"></label>

    <input class=\"star star-2\" id=\"star-2-{$counter}\" type=\"radio\" name=\"star\" value=\"2\"/>

    <label class=\"star star-2\" for=\"star-2-{$counter}\"></label>

    <input class=\"star star-1\" id=\"star-1-{$counter}\" type=\"radio\" name=\"star\" value=\"1\"/>

    <label class=\"star star-1\" for=\"star-1-{$counter}\"></label>
</div>

        <textarea name=\"Description\" enctype=\"Surname\" required=\"\" placeholder=\"Description\"
          autocomplete=\"family-name\" class=\"reservations-description input\"> </textarea>
</form>";
    }
    if ($Status == 'Cancelled') {
      echo "      <span class=\"Fine\">
          <span>FINE</span>
          <br />
        </span>

        <span class=\"FineValue\">
          <span>$Fine</span>
          <br />
        </span>";
    }
    if ($Status == "Upcoming") {
      echo "
        <form method='POST'>
        <input type=\"hidden\" name=\"RID\" value=\"$RID\">
        <input type=\"hidden\" name=\"CANCEL\" value=1>
        <button type=\"submit\" class=\"reservations-cancel button\">
        <span class=\"reservations-text10\">Cancel</span>
      </button>
      </form>";
    }
    echo "
      
      </div>
    </div>
  </div>";
  }

  sqlsrv_free_stmt($getResults);
  sqlsrv_close($conn);
}

if (isset($_POST['REVIEW'])) {
  $RID = $_POST['RID'];
  $RID = strtok($RID, ",");

  if(isset($_POST['star']))
    $star = $_POST['star'];
  else
    $star = 0;

  $Desc = $_POST['Description'];

  $serverName = $_SESSION["serverName"];
  $connectionOptions = $_SESSION["connectionOptions"];
  $conn = sqlsrv_connect($serverName, $connectionOptions);

  if ($conn === false) {
    die(print_r(sqlsrv_errors(), true));
  }

  $tsql = "{call makeReview (?, ?, ?)}";
  $params = array($RID, $Desc, $star); // replace 'Electronics' with the category you want
  $getResults = sqlsrv_query($conn, $tsql, $params);

  if ($getResults === false) {
    error_log(print_r(sqlsrv_errors(), true));
    // Redirect to error page
    header('Location: reservations.php');
    // Stop script execution
    exit;
  }

  sqlsrv_free_stmt($getResults);
  sqlsrv_close($conn);

}

if (isset($_POST['CANCEL'])) {
  $RID = $_POST['RID'];

  $serverName = $_SESSION["serverName"];
  $connectionOptions = $_SESSION["connectionOptions"];
  $conn = sqlsrv_connect($serverName, $connectionOptions);

  if ($conn === false) {
    die(print_r(sqlsrv_errors(), true));
  }

  $tsql = "{call spCancelReservation (?)}";
  $params = array($RID); // replace 'Electronics' with the category you want
  $getResults = sqlsrv_query($conn, $tsql, $params);

  if ($getResults === false) {
    // Redirect to error page
    header('Location: reservations.php');
    // Stop script execution
    exit;
  }

  sqlsrv_free_stmt($getResults);
  sqlsrv_close($conn);
}
?>

<!DOCTYPE html>
<html lang="en">

<head>

  <title>Reservations - Comfortable Favorite Mongoose</title>
  <meta property="og:title" content="Reservations - Comfortable Favorite Mongoose" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta charset="utf-8" />
  <meta property="twitter:card" content="summary_large_image" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

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
      background-image: url('https://thewonderlusters.com/wp-content/uploads/2018/10/View-from-Oia-Castle.jpg');
      background-repeat: repeat;
      background-size: cover;

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

  <link rel="stylesheet" type="text/css" href="bootstrap/css/bootstrap.min.css">
  <div>
    <link href="./css/reservations.css" rel="stylesheet" />



    <div class="reservations-container">
      <span class="reservations-text">RESERVATIONS</span>
      <a href="BookSearch.php" class="reservations-navlink">GREECE BOOKING</a>

      <div class="reservations-list-container" style="color: white">
        <div class="container-fluid">

        

          <?php display(); ?>


        </div>
      </div>
    </div>
  </div>
</body>

</html>