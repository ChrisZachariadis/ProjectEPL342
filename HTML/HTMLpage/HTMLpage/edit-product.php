<?php
session_start();

function display()
{
  $serverName = $_SESSION["serverName"];
  $connectionOptions = $_SESSION["connectionOptions"];
  $conn = sqlsrv_connect($serverName, $connectionOptions);
  $productID = $_POST['ID'];
  if ($conn === false) {
    die(print_r(sqlsrv_errors(), true));
  }

  $tsql = "{call spGet_Product_Details (?)}";
  $params = array($productID); // replace 'Electronics' with the category you want
  $getResults = sqlsrv_query($conn, $tsql, $params);
  $row = sqlsrv_fetch_array($getResults, SQLSRV_FETCH_ASSOC);
  $price = $row['Product_Price'];
  $max = $row['Max_Guests'];
  $Desc = $row['Product_Description'];
  $room = $row['Room_Type'];

  echo '<form
  id="stockadd"
  name="stockmanage"
  method="POST"
  enctype="multipart/form-data"
  autocomplete="on"
  class="edit-product-form"
  >
  <select
    id="Room_Type"
    name="Room_Type"
    class="edit-product-room-type"
  >';

  $options = array("Apartment", "Quadruple", "Suite", "Triple", "Twin", "Double", "Single", "Studio", "Family", "Twin/Double", "Dormitory Room", "Bed in Dormitory", "Bungalow", "Chalet", "Holiday Home", "Villa", "Mobile Home", "Tent");
  foreach ($options as $option) {
    $selected = ($option == $room) ? 'selected' : '';
    echo '<option value="' . $option . '" ' . $selected . '>' . $option . '</option>';
  }

  echo '</select>
  <span class="edit-product-login-header">
    <span>-EDIT PRODUCT-</span>
    <br />
  </span>
  <input type="hidden" name="add"  value=1>
  <input type="hidden" name="ID" value="' . $productID . '">
  <input
    type="number"
    name="Price"
    value="' . $price . '"
    enctype="Surname"
    required=""
    placeholder="Price"
    autocomplete="family-name"
    class="edit-product-price input"
  />
  <textarea
    name="Description"
    value="' . $Desc . '"
    enctype="Surname"
    required=""
    placeholder="Description"
    autocomplete="family-name"
    class="edit-product-description input"
    style="resize: none;"
  ></textarea>
  <input
    type="number"
    name="MaxGuests"
    enctype="Surname"
    value="' . $max . '"
    required=""
    placeholder="Max Guests"
    autocomplete="family-name"
    class="edit-product-property-id input"
  />
  <button type="submit" class="edit-product-submit-button button">
    <span class="edit-product-text2">SUBMIT</span>
  </button>
  </form>';
  sqlsrv_free_stmt($getResults);
  sqlsrv_close($conn);
}

if (isset($_POST['add'])) {
  $serverName = $_SESSION["serverName"];
  $connectionOptions = $_SESSION["connectionOptions"];
  $conn = sqlsrv_connect($serverName, $connectionOptions);
  $productID = $_POST['ID'];
  if ($conn === false) {
    die(print_r(sqlsrv_errors(), true));
  }

  $maxGuests = $_POST['MaxGuests'];
  $price = $_POST['Price'];
  $description = $_POST['Description'];
  $roomType = $_POST['Room_Type'];

  $tsql = "{call spEdit_Product (?, ?, ? ,? , ?)}";
  $params = array($productID, $price, $maxGuests, $description, $roomType);
  $getResults = sqlsrv_query($conn, $tsql, $params);
  if ($getResults === false) {
    die(print_r(sqlsrv_errors(), true));
  }
  sqlsrv_free_stmt($getResults);
  sqlsrv_close($conn);
}

if(isset($_POST['editQuantity'])){
  $serverName = $_SESSION["serverName"];
  $connectionOptions = $_SESSION["connectionOptions"];
  $conn = sqlsrv_connect($serverName, $connectionOptions);
  $productID = $_POST['ID'];
  if ($conn === false) {
    die(print_r(sqlsrv_errors(), true));
  }

  $startDate = $_POST['StartDate'];
  $endDate = $_POST['EndDate'];
  $Quantity = $_POST['Quantity'];

  $tsql = "{call addStock (?, ?, ?, ?)}";
  $params = array($productID, $startDate, $endDate, $Quantity);
 
  $getResults = sqlsrv_query($conn, $tsql, $params);
  if ($getResults === false) {
    die(print_r(sqlsrv_errors(), true));
  }
  sqlsrv_free_stmt($getResults);
  sqlsrv_close($conn);
}

?>

<!DOCTYPE html>
<html lang="en">

<head>
  <title>EditProduct - Comfortable Favorite Mongoose</title>
  <meta property="og:title" content="EditProduct - Comfortable Favorite Mongoose" />
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
  <link rel="stylesheet" href="./css/style.css" />
  <div>
    <link href="./css/edit-product.css" rel="stylesheet" />

    <div class="edit-product-container">
      <div class="edit-product-form-container">
        <?php display(); ?>
      </div>
      <div class="edit-product-form-container2">
        <form method="POST">
          <input type="hidden" name="ID" value="<?php echo $_POST['ID']; ?>">
          <input type="date" name="StartDate" required="" placeholder="StartDate"
            class="edit-product-startDate input" />
          <input type="date" name="EndDate" required="" placeholder="EndDate" class="edit-product-endDate input" />
          <input type="number" name="Quantity" required="" placeholder="Quantity" class="edit-product-amount input">
          <button type="submit" class="edit-product-add-button button" name="editQuantity">
            <span class="edit-product-text2">ADD</span>
          </button>
        </form>
      </div>
      <a href="AdminCatalogueProperties.php" rel="noreferrer noopener" class="edit-product-login-header1">
        <span>GREECE BOOKING</span>
        <br />
      </a>
    </div>
  </div>
</body>

</html>