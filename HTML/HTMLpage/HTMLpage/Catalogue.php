<?php
session_start();

//LUIGI: DESKTOP-HQM94Q5
//PETTE: DESKTOP-H9FM89T
  $sqlDBname = "DB";
  $_SESSION["serverName"] = "DESKTOP-H9FM89T\MSSQLSERVER01";
  $_SESSION["connectionOptions"] = array(
          "Database" => $sqlDBname
      );
    
  // $Location = $_POST['destination'];
  // $date_from = $_POST['date_from'];
  // $date_to = $_POST['date_to'];


  function products($Location){
    $serverName = $_SESSION["serverName"];
    $connectionOptions = $_SESSION["connectionOptions"];
    $conn = sqlsrv_connect($serverName, $connectionOptions);

      if($conn === false) {
       die(print_r(sqlsrv_errors(), true));
    }

    $tsql = "{call spGetProduct (?)}";
    $params = array($Location); // replace 'Electronics' with the category you want
    $getResults = sqlsrv_query($conn, $tsql, $params);
    if($getResults === false) {
       die(print_r(sqlsrv_errors(), true));
    }

    while ($row = sqlsrv_fetch_array($getResults, SQLSRV_FETCH_ASSOC)) {
      //grab variables
    echo "<div class='row'>
    <div class='col-md-12'>
      <div id='Products' class='home-container1 items'>
          <div class='home-container2 items'>
            <h1 class='HotelTitle'>Heading</h1>
            <img
              src='./images/flatthina.webp'
              alt='image'
              class='home-image'
            />
            <span class='Text1'>Text</span>
            <span class='Text2'>Text</span>
            <button type='submit' class='home-button button'>Button</button>
          </div>
          </div>
    </div>
  </div>";
    }
  }

?>

<!DOCTYPE html>
<html lang="en">
  <head>
    <title>Cheap Overjoyed Ape</title>
    <meta property="og:title" content="Cheap Overjoyed Ape" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta charset="utf-8" />
    <meta property="twitter:card" content="summary_large_image" />

    <link rel="stylesheet" type="text/css" href="admin-dash.css">
    <link rel="stylesheet" type="text/css" href="bootstrap/css/bootstrap.min.css">
    <style data-tag="reset-style-sheet">
      html {  line-height: 1.15;}body {  margin: 0;}* {  box-sizing: border-box;  border-width: 0;  border-style: solid;}p,li,ul,pre,div,h1,h2,h3,h4,h5,h6,figure,blockquote,figcaption {  margin: 0;  padding: 0;}button {  background-color: transparent;}button,input,optgroup,select,textarea {  font-family: inherit;  font-size: 100%;  line-height: 1.15;  margin: 0;}button,select {  text-transform: none;}button,[type="button"],[type="reset"],[type="submit"] {  -webkit-appearance: button;}button::-moz-focus-inner,[type="button"]::-moz-focus-inner,[type="reset"]::-moz-focus-inner,[type="submit"]::-moz-focus-inner {  border-style: none;  padding: 0;}button:-moz-focus,[type="button"]:-moz-focus,[type="reset"]:-moz-focus,[type="submit"]:-moz-focus {  outline: 1px dotted ButtonText;}a {  color: inherit;  text-decoration: inherit;}input {  padding: 2px 4px;}img {  display: block;}html { scroll-behavior: smooth  }
    </style>
    <style data-tag="default-style-sheet">
      html {
        font-family: Inter;
        font-size: 16px;
      }

      body {
        font-weight: 400;
        font-style:normal;
        text-decoration: none;
        text-transform: none;
        letter-spacing: normal;
        line-height: 1.15;
        color: var(--dl-color-gray-black);
        background-color: var(--dl-color-gray-white);

      }
    </style>
    <link
      rel="stylesheet"
      href="https://fonts.googleapis.com/css2?family=Inter:wght@100;200;300;400;500;600;700;800;900&amp;display=swap"
      data-tag="font"
    />
  </head>
  <body>
    <link rel="stylesheet" href="./css/Style2.css" />
    <div>
      <link href="./css/Catalogue.css" rel="stylesheet" />

      <div class="home-container">
        <h1 id="TITLE" class="home-text">Heading</h1>
        <div class="container">
          <?php products($Location); ?>
        </div>
        </div>
      </div>
    </div>
  </body>
</html>
