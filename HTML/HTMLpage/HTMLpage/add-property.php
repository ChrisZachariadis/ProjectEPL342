<?php
session_start();
if ($_SERVER["REQUEST_METHOD"] == "POST") {
  // Check if Room_Type is set in the form submission
  if (isset($_POST['PropertyType'])) {
    // Retrieve form data

    $propertyType = $_POST['PropertyType']; // Using null coalescing operator to avoid undefined index notice
    $location = $_POST['Location'];
    $ownerFirstName = $_POST['OwnerFirstName']; // Change 'OwnerName' to 'OwnerFirstName' in your HTML form for the first name
    $ownerLastName = $_POST['OwnerLastName']; // Change 'OwnerName' to 'OwnerLastName' in your HTML form for the last name
    $description = $_POST['Description'];
    $address = $_POST['Address'];
    $coordinates = $_POST['Coordinates'];
    $facilities = $_POST['Facilities'];
    $propertyName = $_POST['Property_Name'];
    $UserID = $_SESSION['UserID']; 


    $serverName = $_SESSION["serverName"];
    $connectionOptions = $_SESSION["connectionOptions"];
    $conn = sqlsrv_connect($serverName, $connectionOptions);

    if ($conn === false) {
      die(print_r(sqlsrv_errors(), true));
    }

    $tsql = "{call spInsert_Property(?, ?, ?, ? ,? ,?, ?, ?, ?, ?)}";
    $params = array($propertyName, $address, $description, $coordinates, $location, $UserID, $ownerFirstName, $ownerLastName, $propertyType, $UserID);
    var_dump($params);
    $getResults = sqlsrv_query($conn, $tsql, $params);
    if ($getResults === false) {
      die(print_r(sqlsrv_errors(), true));
    }

  }
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
  <title>AddProperty - Comfortable Favorite Mongoose</title>
  <meta property="og:title" content="AddProperty - Comfortable Favorite Mongoose" />
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
    <link href="./css/add-property.css" rel="stylesheet" />

    <div class="add-property-container">
      <div class="add-property-form-container">
        <form id="stockadd" name="stockmanage" method="POST" enctype="multipart/form-data" autocomplete="on"
          class="add-property-form">
          <select id="Property Type" name="PropertyType" class="add-property-property-type">
            <option value="empty">Select a property type</option>
            <option value="Resort">Resort</option>
            <option value="Hostel">Hostel</option>
            <option value="Hotel">Hotel</option>
            <option value="Lodge">Lodge</option>
            <option value="Motel">Motel</option>
            <option value="Love Hotel">Love Hotel</option>
            <option value="Capsule Hotel">Capsule Hotel</option>
            <option value="Japanese Style Hotel">Japanese Style Hotel</option>
            <option value="Apartment">Apartment</option>
            <option value="Tent">Tent</option>
            <option value="Villa">Villa</option>
            <option value="Homestay">Homestay</option>
            <option value="Country House">Country House</option>
            <option value="Chalet">Chalet</option>
            <option value="Xartokouto">Kashia</option>
          </select>
          <select id="Location" name="Location" class="add-property-location">
            <option value="empty" selected>Location</option>
            <option value="Rhodes">Rhodes</option>
            <option value="Santorini">Santorini</option>
            <option value="Thessaloniki">Thessaloniki</option>
            <option value="Athens">Athens</option>
            <option value="Thessaloniki">Thessaloniki</option>
            <option value="Athens">Athens</option>
            <option value="Naxos">Naxos</option>
            <option value="Mykonos">Mykonos</option>
            <option value="Aridea">Aridea</option>
            <option value="Salamina">Salamina</option>
          </select>
          <span class="add-property-login-header">
            <span>-ADD PROPERTY-</span>
            <br />
          </span>
          <input type="text" name="OwnerFirstName" enctype="Surname" required="" placeholder="Owner FirstName"
            autocomplete="family-name" class="add-property-owner-first-name input" />
          <input type="text" name="OwnerLastName" enctype="Surname" required="" placeholder="Owner LastName"
            autocomplete="family-name" class="add-property-owner-last-name input" />
          <input type="text" name="Description" enctype="Surname" required="" placeholder="Description"
            autocomplete="family-name" class="add-property-description input" />
          <input type="text" name="Address" enctype="Surname" required="" placeholder="Address"
            autocomplete="family-name" class="add-property-address input" />
          <input type="text" name="Coordinates" enctype="Surname" required="" placeholder="Coordinates"
            autocomplete="family-name" class="add-property-coordinates input" />
          <input type="text" name="Facilities" enctype="Surname" required="" placeholder="Facilities"
            autocomplete="family-name" class="add-property-coordinates1 input" />
          <input type="text" id="propertyname" name="Property_Name" required="" placeholder="Property Name"
            autocomplete="name" class="add-property-property-name input" />
          <button type="submit" class="add-property-submit-button button">
            <span class="add-property-text2">ADD</span>
          </button>
        </form>
      </div>
      <a href="https://HOME.php" target="_blank" rel="noreferrer noopener" class="add-property-login-header1">
        <span>GREECE BOOKING</span>
        <br />
      </a>
    </div>
  </div>
</body>

</html>