<?php
session_start();
if(isset($_POST['ID'])){
  $ID = $_POST['ID'];
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
  // Check if Room_Type is set in the form submission
  if (isset($_POST['Room_Type'])) {
    // Retrieve form data

    $roomType = $_POST['Room_Type']; // Assuming this is a dropdown/select input
    $price = $_POST['Price']; // Assuming this is a text input
    $description = $_POST['Description']; // Assuming this is a text input
    $maxGuests = $_POST['MaxGuests']; // Assuming this is a text input
    $propertyID = $_POST['ID']; // Assuming this is a text input
    $UserID = $_SESSION['UserID'];

    $serverName = $_SESSION["serverName"];
    $connectionOptions = $_SESSION["connectionOptions"];
    $conn = sqlsrv_connect($serverName, $connectionOptions);

    if ($conn === false) {
      die(print_r(sqlsrv_errors(), true));
    }

    $tsql = "{call spInsert_Product(?, ?, ?, ? ,? ,?)}";
    $params = array($UserID, $price, $maxGuests, $description, $roomType, $propertyID);
    var_dump($params);
    $getResults = sqlsrv_query($conn, $tsql, $params);
    if ($getResults === false) {
      die(print_r(sqlsrv_errors(), true));
    }

    if ($getResults === false) {
      die(print_r(sqlsrv_errors(), true));
    }

  }
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
  <title>AddProduct - Comfortable Favorite Mongoose</title>
  <meta property="og:title" content="AddProduct - Comfortable Favorite Mongoose" />
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
  <link rel="stylesheet" href="..css./style.css" />
  <div>
    <link href="./css/add-product.css" rel="stylesheet" />

    <div class="add-product-container">
      <div class="add-product-form-container">
        <form id="stockadd" name="stockmanage" method="POST" enctype="multipart/form-data" autocomplete="on"
          class="add-product-form">
        <input type="hidden" name="ID" value="<?php echo $ID; ?>">
          <select id="Room_Type" name="Room_Type" class="add-product-room-type">
            <option value="empty">Select a room type</option>
            <option value="Apartment">Apartment</option>
            <option value="Quadruple">Quadruple</option>
            <option value="Suite">Suite</option>
            <option value="Triple">Triple</option>
            <option value="Twin">Twin</option>
            <option value="Double">Double</option>
            <option value="Single">Single</option>
            <option value="Studio">Studio</option>
            <option value="Family">Family</option>
            <option value="Twin/Double">Twin/Double</option>
            <option value="Dormitory Room">Dormitory</option>
            <option value="Bed in Dormitory">Bed In Dormitory</option>
            <option value="Bungalow">Bungalow</option>
            <option value="Chalet">Chalet</option>
            <option value="Holiday Home">Holiday House</option>
            <option value="Villa">Villa</option>
            <option value="Mobile Home">Mobile Home</option>
            <option value="Tent">Tent</option>
          </select>
          <span class="add-product-login-header">
            <span>-ADD PRODUCT-</span>
            <br />
          </span>
          <input type="text" name="Price" enctype="Surname" required="" placeholder="Price" autocomplete="family-name"
            class="add-product-price input" />
          <input type="text" name="Description" enctype="Surname" required="" placeholder="Description"
            autocomplete="family-name" class="add-product-description input" />
          <input type="text" name="MaxGuests" enctype="Surname" required="" placeholder="Max Guests"
            autocomplete="family-name" class="add-product-property-id input" />
          <button type="submit" class="add-product-submit-button button">
            <span class="add-product-text2">ADD</span>
          </button>
        </form>
      </div>
      <a href="HOME.php" rel="noreferrer noopener" class="add-product-login-header1">
        <span>GREECE BOOKING</span>
        <br />
      </a>
    </div>
  </div>
</body>

</html>