<?php
session_start();

function display()
{
  $serverName = $_SESSION["serverName"];
  $connectionOptions = $_SESSION["connectionOptions"];
  $conn = sqlsrv_connect($serverName, $connectionOptions);
  $propertyID = $_POST['id'];
  if ($conn === false) {
    die(print_r(sqlsrv_errors(), true));
  }

  $tsql = "{call spGet_Property (?)}";
  $params = array($propertyID); // replace 'Electronics' with the category you want
  $getResults = sqlsrv_query($conn, $tsql, $params);
  if ($getResults === false) {
    die(print_r(sqlsrv_errors(), true));
  }

  $row = sqlsrv_fetch_array($getResults, SQLSRV_FETCH_ASSOC);

  $Name = $row['Property_Name'];
  $Locations = $row['Property_Location'];
  $Desc = $row['Property_Description'];
  $Type = $row['Property_Type'];
  $OwnerFirstName = $row['Owner_First_Name'];
  $OwnerLastName = $row['Owner_Last_Name'];
  $Address = $row['Property_Address'];
  $Coordinates = $row['Property_Coordinates'];

  $propertyArray = array("Resort", "Hostel", "Hotel", "Lodge", "Motel", "Love Hotel", "Capsule Hotel", "Japanese Style Hotel", "Apartment", "Tent", "Villa", "Homestay", "Country House", "Chalet", "Kashia");
  $locationsArray = array("Athens", "Rhodes", "Santorini", "Thessaloniki", "Mykonos");

  echo '<form
    id="stockadd"
    name="stockmanage"
    method="POST"
    enctype="multipart/form-data"
    autocomplete="on"
    class="edit-property-form"
  >
  <input type="hidden" name="add" value="1"> 
  <input type="hidden" name="id" value="'.$propertyID.'">
    <select
      id="Property Type"
      name="PropertyType"
      class="edit-property-property-type"
    >';

  foreach ($propertyArray as $propertyType) {
    $selected = ($propertyType == $Type) ? 'selected' : '';
    echo "<option value='$propertyType' $selected>$propertyType</option>";
  }

  echo '</select>
    <select
      id="Location"
      name="Location"
      class="edit-property-location"
    >';

  foreach ($locationsArray as $location) {
    $selected = ($location == $Locations) ? 'selected' : '';
    echo "<option value='$location' $selected>$location</option>";
  }

  echo '</select>
    <span class="edit-property-login-header">
      <span>-EDIT PROPERTY-</span>
      <br />
    </span>
    <input
      type="text"
      name="OwnerFirstName"
      required=""
      placeholder="Owner FirstName"
      autocomplete="family-name"
      class="edit-property-owner-first-name input"
      value="' . $OwnerFirstName . '"
    />
    <input
      type="text"
      name="OwnerLastName"
      required=""
      placeholder="Owner LastName"
      autocomplete="family-name"
      class="edit-property-owner-last-name input"
      value="' . $OwnerLastName . '"
    />
    <textarea
      name="Description"
      required=""
      placeholder="Description"
      value="' . $Desc . '"
      autocomplete="family-name"
      class="edit-property-description input"
      style="resize: none;"
    ></textarea>
    <input
      type="text"
      name="Address"
      required=""
      placeholder="Address"
      autocomplete="family-name"
      class="edit-property-address input"
      value="' . $Address . '"
    />
    <input
      type="text"
      name="Coordinates"
      required=""
      placeholder="Coordinates"
      autocomplete="family-name"
      class="edit-property-coordinates input"
      value="' . $Coordinates . '"
    />
    <input
      type="text"
      id="propertyname"
      name="Property_Name"
      required=""
      placeholder="Property Name"
      autocomplete="name"
      class="edit-property-property-name input"
      value="' . $Name . '"
    />
    <button type="submit" class="edit-property-submit-button button">
      <span class="edit-property-text2">SUBMIT</span>
    </button>
  </form>';

  sqlsrv_free_stmt($getResults);
  sqlsrv_close($conn);
}

if(isset($_POST['add'])){
  $serverName = $_SESSION["serverName"];
  $connectionOptions = $_SESSION["connectionOptions"];
  $conn = sqlsrv_connect($serverName, $connectionOptions);
  if ($conn === false) {
    die(print_r(sqlsrv_errors(), true));
  }

  $propertyType = $_POST['PropertyType'];
  $location = $_POST['Location'];
  $ownerFirstName = $_POST['OwnerFirstName'];
  $ownerLastName = $_POST['OwnerLastName'];
  $description = $_POST['Description'];
  $address = $_POST['Address'];
  $coordinates = $_POST['Coordinates'];
  $propertyName = $_POST['Property_Name'];
  $propertyID = $_POST['id'];

  $tsql = "{call spEdit_Property (?, ?, ?, ?, ?, ?, ? ,? ,?)}";
  $params = array($propertyID, $propertyName, $address, $description, $coordinates, $location, $ownerFirstName, $ownerLastName, $propertyType); // replace 'Electronics' with the category you want
  $getResults = sqlsrv_query($conn, $tsql, $params);
  if ($getResults === false) {
    die(print_r(sqlsrv_errors(), true));
  }
}

?>

<!DOCTYPE html>
<html lang="en">

<head>
  <title>EditProperty - Comfortable Favorite Mongoose</title>
  <meta property="og:title" content="EditProperty - Comfortable Favorite Mongoose" />
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
    <link href="./css/edit-property.css" rel="stylesheet" />

    <div class="edit-property-container">
      <div class="edit-property-form-container">
        <?php display(); ?>
      </div>
      <a href="AdminCatalogueProperties.php" rel="noreferrer noopener" class="edit-property-login-header1">
        <span>GREECE BOOKING</span>
        <br />
      </a>
    </div>
  </div>
</body>

</html>