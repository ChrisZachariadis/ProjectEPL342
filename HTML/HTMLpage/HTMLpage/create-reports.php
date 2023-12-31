<?php
session_start();
$tableData = [];

$serverName = $_SESSION["serverName"];
$connectionOptions = $_SESSION["connectionOptions"];
$conn = sqlsrv_connect($serverName, $connectionOptions);

if ($conn === false) {
  die(print_r(sqlsrv_errors(), true));
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {

  // Generate your table data here
  $postedVar = array_key_first($_POST);
  switch ($postedVar) {
    case 'ButtonRevenueReport':

      $tsql = "{call RevenueReport(?, ?, ?, ?, ?)}";
      $params = [];

      $order = array('StartDate', 'EndDate', 'PropertyType', 'RoomType', 'Location');
      foreach ($order as $key) {
        if (isset($_POST[$key])) {
          array_push($params, $_POST[$key]);
        }
      }


      break;
    case 'ButtonAnalyzeNoOfReservations':

      $tsql = "{call AnalyzeNumberOfReservations(?, ?, ?, ?, ?)}";
      $params = [];

      $order = array('StartDate', 'EndDate', 'PropertyType', 'RoomType', 'Location');
      foreach ($order as $key) {
        if (isset($_POST[$key])) {
          array_push($params, $_POST[$key]);
        }
      }


      break;
    case 'ButtonCompareRTrends':

      $tsql = "{call CompareReservationTrends(?, ?)}";
      $params = [];

      $order = array('StartDate', 'EndDate');
      foreach ($order as $key) {
        if (isset($_POST[$key])) {
          array_push($params, $_POST[$key]);
        }
      }


      break;
    case 'ButtonCalculateCancRate':

      $tsql = "{call CalculateCancellationRate(?, ?, ?, ?, ?)}";
      $params = [];

      $order = array('StartDate', 'EndDate', 'PropertyType', 'RoomType', 'Location');
      foreach ($order as $key) {
        if (isset($_POST[$key])) {
          array_push($params, $_POST[$key]);
        }
      }



      break;
    case 'ButtonCalcOccRate':

      $tsql = "{call CalculateOccupancyRate(?, ?, ?, ?, ?)}";
      $params = [];

      $order = array('StartDate', 'EndDate', 'PropertyType', 'RoomType', 'Location');
      foreach ($order as $key) {
        if (isset($_POST[$key])) {
          array_push($params, $_POST[$key]);
        }
      }


      break;
    case 'ButtonIDHighOccPeriods':

      $tsql = "{call IdentifyHighOccupancyPeriods(?, ?, ?)}";
      $params = [];

      $order = array('PropertyType', 'RoomType', 'Location');
      foreach ($order as $key) {
        if (isset($_POST[$key])) {
          array_push($params, $_POST[$key]);
        }
      }


      break;
    case 'ButtonCompareORByRT':

      $tsql = "{call CompareOccupancyRatesByRoomType(?, ?, ?, ?)}";
      $params = [];

      $order = array('StartDate', 'EndDate', 'PropertyType', 'Location');
      foreach ($order as $key) {
        if (isset($_POST[$key])) {
          array_push($params, $_POST[$key]);
        }
      }


      break;
    case 'ButtonAverageRatingAndR':

      $tsql = "{call GetAverageRatingAndReviews}";
      $params = [];

      break;
    case 'ButtonIdentifyPByR':

      $tsql = "{call IdentifyPropertiesByRating}";
      $params = [];


      break;
    case 'ButtonOverviewOfRTInvAndOcc':

      $tsql = "{call OverviewOfRoomTypeInventoryAndOccupancy(?, ?, ?, ?, ?)}";
      $params = [];

      $order = array('StartDate', 'EndDate', 'PropertyType', 'RoomType', 'Location');
      foreach ($order as $key) {
        if (isset($_POST[$key])) {
          array_push($params, $_POST[$key]);
        }
      }


      break;
    case 'ButtonGetPropertyRoomBookingStatus':

      $tsql = "{call GetPropertyRoomBookingStatus(?, ?, ?)}";
      $params = [];

      $order = array('PropertyType', 'StartDate', 'EndDate');
      foreach ($order as $key) {
        if (isset($_POST[$key])) {
          array_push($params, $_POST[$key]);
        }
      }


      break;
    case 'ButtonGetRoomsWithMonthlyBookings':

      $tsql = "{call GetRoomsWithMonthlyBookings(?, ?)}";
      $params = [];

      $order = array('PropertyType', 'Year');
      foreach ($order as $key) {
        if (isset($_POST[$key])) {
          array_push($params, $_POST[$key]);
        }
      }


      break;
    case 'ButtonGetRoomsWithMinimumBookings':

      $tsql = "{call GetRoomsWithMinBookings(?, ?, ?)}";
      $params = [];

      $order = array('PropertyType', 'Year', 'MinBooks');
      foreach ($order as $key) {
        if (isset($_POST[$key])) {
          array_push($params, $_POST[$key]);
        }
      }



      break;
    // Add more cases as needed
  }
  $tableData = [];

  $getResults = sqlsrv_query($conn, $tsql, $params);

  if ($getResults === false) {
    die(print_r(sqlsrv_errors(), true));
  }


  $metadata = sqlsrv_field_metadata($getResults);

  foreach ($metadata as $field) {
    $tableHeaders[] = $field['Name'];
  }

  //var_dump(sqlsrv_fetch_array($getResults, SQLSRV_FETCH_ASSOC));

  while ($row = sqlsrv_fetch_array($getResults, SQLSRV_FETCH_ASSOC)) {

    $tableData[] = $row;
  }

  sqlsrv_free_stmt($getResults);
  sqlsrv_close($conn);
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
  <title>CreateReports - Comfortable Favorite Mongoose</title>
  <meta property="og:title" content="CreateReports - Comfortable Favorite Mongoose" />
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

<body
  style="background-image: url('https://railrocker.com/playground/wp-content/uploads/2017/04/great-evening-view-of-antorini-island.jpg'); background-size: cover;">
  <link rel="stylesheet" href="./css/style5.css" />
  <div>
    <link href="./css/create-reports.css" rel="stylesheet" />

    <div class="create-reports-container">
      <a href="AdminCatalogueProperties.php" rel="noreferrer noopener" class="create-reports-greece-booking-text">
        <span>GREECE BOOKING</span>
        <br />
      </a>
      <span class="create-reports-create-report-header">
        <span>-CREATE REPORTS-</span>
        <br />
      </span>
      <div class="create-reports-form-type-container">
        <span class="create-reports-revenue-text">
          <span>-Revenue-</span>
          <br />
        </span>
        <div class="create-reports-container01">
          <form class="create-reports-form" method="POST">
            <button type="submit" name="ButtonRevenueReport" class="create-reports-revenue-report-button button">
              <span>
                <span class="create-reports-text07">Revenue Report</span>
                <br />
              </span>
            </button>
            <select name="PropertyType" class="create-reports-property-type">
              <option value="empty" selected="">Property Type</option>
              <option value="Resort">Resort</option>
              <option value="Hostel">Hostel</option>
              <option value="Hotel">Hotel</option>
              <option value="Lodge">Lodge</option>
              <option value="Motel">Motel</option>
              <option value="Love Hotel">Love Hotel</option>
              <option value="Capsule Hotel">Capsule Hotel</option>
              <option value="Japanese Style Hotel">
                Japanese Style Hotel
              </option>
              <option value="Hotel">Hotel</option>
              <option value="Lodge">Lodge</option>
              <option value="Motel">Motel</option>
              <option value="Capsule Hotel">Capsule Hotel</option>
              <option value="Japanese Style Hotel">
                Japanese Style Hotel
              </option>
              <option value="Apartment">Apartment</option>
              <option value="Tent">Tent</option>
              <option value="Villa">Villa</option>
              <option value="Homestay">Homestay</option>
              <option value="Country House">Country House</option>
              <option value="Chalet">Chalet</option>
            </select>
            <select name="RoomType" class="create-reports-room-type">
              <option value="empty" selected="">Room Type</option>
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
              <option value="Dormitory Room">Dormitory Room</option>
              <option value="Bed in Dormitory">Bed in Dormitory</option>
              <option value="Bungalow">Bungalow</option>
              <option value="Chalet">Chalet</option>
              <option value="Holiday Home">Holiday Home</option>
              <option value="Villa">Villa</option>
              <option value="Mobile Home">Mobile Home</option>
              <option value="Tent">Tent</option>
            </select>
            <select name="Location" class="create-reports-location">
              <option value="empty" selected="">Location</option>
              <option value="Rhodes">Rhodes</option>
              <option value="Santorini">Santorini</option>
              <option value="Thessaloniki">Thessaloniki</option>
              <option value="Athens">Athens</option>
              <option value="Naxos">Naxos</option>
              <option value="Mykonos">Mykonos</option>
              <option value="Aridea">Aridea</option>
              <option value="Salamina">Salamina</option>
            </select>
            <input type="text" name="EndDate" enctype="Surname" required="" placeholder="End Date"
              autocomplete="family-name" class="create-reports-end-date input" />
            <input type="text" name="StartDate" required="" placeholder="Start Date" autocomplete="name"
              class="create-reports-start-date input" />
          </form>
        </div>
        <span class="create-reports-booking-text">
          <span>-Booking Statistics&nbsp;</span>
          <span>Reports-</span>
          <br />
        </span>
        <div class="create-reports-container02">
          <form class="create-reports-form01" method="POST">
            <button type="submit" name="ButtonAnalyzeNoOfReservations"
              class="create-reports-analyze-number-of-reservations-button button">
              <span>
                <span class="create-reports-text13">
                  Analyze Number Of Reservations
                </span>
                <br />
              </span>
            </button>
            <select name="PropertyType" class="create-reports-property-type1">
              <option value="empty" selected="">Property Type</option>
              <option value="Resort">Resort</option>
              <option value="Hostel">Hostel</option>
              <option value="Hotel">Hotel</option>
              <option value="Lodge">Lodge</option>
              <option value="Motel">Motel</option>
              <option value="Love Hotel">Love Hotel</option>
              <option value="Capsule Hotel">Capsule Hotel</option>
              <option value="Japanese Style Hotel">
                Japanese Style Hotel
              </option>
              <option value="Hotel">Hotel</option>
              <option value="Lodge">Lodge</option>
              <option value="Motel">Motel</option>
              <option value="Capsule Hotel">Capsule Hotel</option>
              <option value="Japanese Style Hotel">
                Japanese Style Hotel
              </option>
              <option value="Apartment">Apartment</option>
              <option value="Tent">Tent</option>
              <option value="Villa">Villa</option>
              <option value="Homestay">Homestay</option>
              <option value="Country House">Chalet</option>
              <option value="Chalet">Chalet</option>
            </select>
            <select name="RoomType" class="create-reports-room-type1">
              <option value="empty" selected="">Room Type</option>
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
              <option value="Dormitory Room">Dormitory Room</option>
              <option value="Bed in Dormitory">Bed in Dormitory</option>
              <option value="Bungalow">Bungalow</option>
              <option value="Chalet">Chalet</option>
              <option value="Holiday Home">Holiday Home</option>
              <option value="Villa">Villa</option>
              <option value="Mobile Home">Mobile Home</option>
              <option value="Tent">Tent</option>
            </select>
            <select name="Location" class="create-reports-location1">
              <option value="empty" selected="">Location</option>
              <option value="Rhodes">Rhodes</option>
              <option value="Santorini">Santorini</option>
              <option value="Thessaloniki">Thessaloniki</option>
              <option value="Athens">Athens</option>
              <option value="Naxos">Naxos</option>
              <option value="Mykonos">Mykonos</option>
              <option value="Aridea">Aridea</option>
              <option value="Salamina">Salamina</option>
            </select>
            <input type="text" name="EndDate" enctype="Surname" required="" placeholder="End Date"
              autocomplete="family-name" class="create-reports-end-date1 input" />
            <input type="text" name="StartDate" required="" placeholder="Start Date" autocomplete="name"
              class="create-reports-start-date1 input" />
          </form>
        </div>
        <div class="create-reports-container03">
          <form class="create-reports-form02" method="POST">
            <button type="submit" name="ButtonCompareRTrends"
              class="create-reports-compare-reservation-trends-button button">
              <span class="create-reports-text15">
                Compare Reservation Trends
              </span>
            </button>
            <input type="text" name="EndDate" enctype="Surname" required="" placeholder="End Date"
              autocomplete="family-name" class="create-reports-end-date2 input" />
            <input type="text" name="StartDate" required="" placeholder="Start Date" autocomplete="name"
              class="create-reports-start-date2 input" />
          </form>
        </div>
        <div class="create-reports-container04">
          <form class="create-reports-form03" method="POST">
            <button type="submit" name="ButtonCalculateCancRate"
              class="create-reports-calculate-cancellation-rate-button button">
              <span class="create-reports-text16">
                Calculate Cancellation Rate
              </span>
            </button>
            <select name="PropertyType" class="create-reports-property-type2">
              <option value="empty" selected="">Property Type</option>
              <option value="Resort">Resort</option>
              <option value="Hostel">Hostel</option>
              <option value="Hotel">Hotel</option>
              <option value="Lodge">Lodge</option>
              <option value="Motel">Motel</option>
              <option value="Love Hotel">Love Hotel</option>
              <option value="Capsule Hotel">Capsule Hotel</option>
              <option value="Japanese Style Hotel">
                Japanese Style Hotel
              </option>
              <option value="Hotel">Hotel</option>
              <option value="Lodge">Lodge</option>
              <option value="Motel">Motel</option>
              <option value="Capsule Hotel">Capsule Hotel</option>
              <option value="Japanese Style Hotel">
                Japanese Style Hotel
              </option>
              <option value="Apartment">Apartment</option>
              <option value="Tent">Tent</option>
              <option value="Villa">Villa</option>
              <option value="Homestay">Homestay</option>
              <option value="Country House">Country House</option>
              <option value="Chalet">Chalet</option>
            </select>
            <select name="RoomType" class="create-reports-room-type2">
              <option value="empty" selected="">Room Type</option>
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
              <option value="Dormitory Room">Dormitory Room</option>
              <option value="Bed in Dormitory">Bed in Dormitory</option>
              <option value="Bungalow">Bungalow</option>
              <option value="Chalet">Chalet</option>
              <option value="Holiday Home">Holiday Home</option>
              <option value="Villa">Villa</option>
              <option value="Mobile Home">Mobile Home</option>
              <option value="Tent">Tent</option>
            </select>
            <select name="Location" class="create-reports-location2">
              <option value="empty" selected="">Location</option>
              <option value="Rhodes">Rhodes</option>
              <option value="Santorini">Santorini</option>
              <option value="Thessaloniki">Thessaloniki</option>
              <option value="Athens">Athens</option>
              <option value="Naxos">Naxos</option>
              <option value="Mykonos">Mykonos</option>
              <option value="Aridea">Aridea</option>
              <option value="Salamina">Salamina</option>
            </select>
            <input type="text" name="EndDate" enctype="Surname" required="" placeholder="End Date"
              autocomplete="family-name" class="create-reports-end-date3 input" />
            <input type="text" name="StartDate" required="" placeholder="Start Date" autocomplete="name"
              class="create-reports-start-date3 input" />
          </form>
        </div>
        <span class="create-reports-occupancy-text">
          <span>-Occupation Reports-</span>
          <br />
        </span>
        <div class="create-reports-container05">
          <form class="create-reports-form04" method="POST">
            <button type="submit" name="ButtonCalcOccRate"
              class="create-reports-calculate-occupancy-rate-button button">
              <span>
                <span class="create-reports-text20">
                  Calculate Occupancy Rate
                </span>
                <br />
              </span>
            </button>
            <select name="PropertyType" class="create-reports-property-type3">
              <option value="empty" selected="">Property Type</option>
              <option value="Resort">Resort</option>
              <option value="Hostel">Hostel</option>
              <option value="Hotel">Hotel</option>
              <option value="Lodge">Lodge</option>
              <option value="Motel">Motel</option>
              <option value="Love Hotel">Love Hotel</option>
              <option value="Capsule Hotel">Capsule Hotel</option>
              <option value="Japanese Style Hotel">
                Japanese Style Hotel
              </option>
              <option value="Hotel">Hotel</option>
              <option value="Lodge">Lodge</option>
              <option value="Motel">Motel</option>
              <option value="Capsule Hotel">Capsule Hotel</option>
              <option value="Japanese Style Hotel">
                Japanese Style Hotel
              </option>
              <option value="Apartment">Apartment</option>
              <option value="Tent">Tent</option>
              <option value="Villa">Villa</option>
              <option value="Homestay">Homestay</option>
              <option value="Country House">Country House</option>
              <option value="Chalet">Chalet</option>
            </select>
            <select name="RoomType" class="create-reports-room-type3">
              <option value="empty" selected="">Room Type</option>
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
              <option value="Dormitory Room">Dormitory Room</option>
              <option value="Bed in Dormitory">Bed in Dormitory</option>
              <option value="Bungalow">Bungalow</option>
              <option value="Chalet">Chalet</option>
              <option value="Holiday Home">Holiday Home</option>
              <option value="Villa">Villa</option>
              <option value="Mobile Home">Mobile Home</option>
              <option value="Tent">Tent</option>
            </select>
            <select name="Location" class="create-reports-location3">
              <option value="empty" selected="">Location</option>
              <option value="Rhodes">Rhodes</option>
              <option value="Santorini">Santorini</option>
              <option value="Thessaloniki">Thessaloniki</option>
              <option value="Athens">Athens</option>
              <option value="Naxos">Naxos</option>
              <option value="Mykonos">Mykonos</option>
              <option value="Aridea">Aridea</option>
              <option value="Salamina">Salamina</option>
            </select>
            <input type="text" name="EndDate" enctype="Surname" required="" placeholder="End Date"
              autocomplete="family-name" class="create-reports-end-date4 input" />
            <input type="text" name="StartDate" required="" placeholder="Start Date" autocomplete="name"
              class="create-reports-start-date4 input" />
          </form>
        </div>
        <div class="create-reports-container06">
          <form class="create-reports-form05" method="POST">
            <button type="submit" name="ButtonIDHighOccPeriods"
              class="create-reports-calculate-occupancy-rate-button1 button">
              <span>
                <span class="create-reports-text23">
                  Identify High Occupancy Periods
                </span>
                <br />
              </span>
            </button>
              <select name="PropertyType" class="create-reports-end-date5 input">
              <option value="empty" selected="">Property Type</option>
              <option value="Resort">Resort</option>
              <option value="Hostel">Hostel</option>
              <option value="Hotel">Hotel</option>
              <option value="Lodge">Lodge</option>
              <option value="Motel">Motel</option>
              <option value="Love Hotel">Love Hotel</option>
              <option value="Capsule Hotel">Capsule Hotel</option>
              <option value="Japanese Style Hotel">
                Japanese Style Hotel
              </option>
              <option value="Hotel">Hotel</option>
              <option value="Lodge">Lodge</option>
              <option value="Motel">Motel</option>
              <option value="Capsule Hotel">Capsule Hotel</option>
              <option value="Japanese Style Hotel">
                Japanese Style Hotel
              </option>
              <option value="Apartment">Apartment</option>
              <option value="Tent">Tent</option>
              <option value="Villa">Villa</option>
              <option value="Homestay">Homestay</option>
              <option value="Country House">Country House</option>
              <option value="Chalet">Chalet</option>
            </select>
            <select name="RoomType" class="create-reports-start-date5 input">
              <option value="empty" selected="">Room Type</option>
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
              <option value="Dormitory Room">Dormitory Room</option>
              <option value="Bed in Dormitory">Bed in Dormitory</option>
              <option value="Bungalow">Bungalow</option>
              <option value="Chalet">Chalet</option>
              <option value="Holiday Home">Holiday Home</option>
              <option value="Villa">Villa</option>
              <option value="Mobile Home">Mobile Home</option>
              <option value="Tent">Tent</option>
            </select>
            
            <select name="Location" class="create-reports-location3" style="right:615px; top:10px;">
              <option value="empty" selected="">Location</option>
              <option value="Rhodes">Rhodes</option>
              <option value="Santorini">Santorini</option>
              <option value="Thessaloniki">Thessaloniki</option>
              <option value="Athens">Athens</option>
              <option value="Naxos">Naxos</option>
              <option value="Mykonos">Mykonos</option>
              <option value="Aridea">Aridea</option>
              <option value="Salamina">Salamina</option>
            </select>

          </form>
        </div>
        <div class="create-reports-container07">
          <form class="create-reports-form06" method="POST">

            <button type="submit" name="ButtonCompareORByRT"
              class="create-reports-compare-reservation-trends-button1 button">
              <span class="create-reports-text25">
                Compare Occupancy Rates By Room Type
              </span>
            </button>

            <input type="text" name="EndDate" enctype="Surname" required="" placeholder="End Date"
              autocomplete="family-name" class="create-reports-end-date6 input" />
            <input type="text" name="StartDate" required="" placeholder="Start Date" autocomplete="name"
              class="create-reports-start-date6 input" />

              <select name="PropertyType" class="create-reports-property-type3" style="top: 35px;">
              <option value="empty" selected="">Property Type</option>
              <option value="Resort">Resort</option>
              <option value="Hostel">Hostel</option>
              <option value="Hotel">Hotel</option>
              <option value="Lodge">Lodge</option>
              <option value="Motel">Motel</option>
              <option value="Love Hotel">Love Hotel</option>
              <option value="Capsule Hotel">Capsule Hotel</option>
              <option value="Japanese Style Hotel">
                Japanese Style Hotel
              </option>
              <option value="Hotel">Hotel</option>
              <option value="Lodge">Lodge</option>
              <option value="Motel">Motel</option>
              <option value="Capsule Hotel">Capsule Hotel</option>
              <option value="Japanese Style Hotel">
                Japanese Style Hotel
              </option>
              <option value="Apartment">Apartment</option>
              <option value="Tent">Tent</option>
              <option value="Villa">Villa</option>
              <option value="Homestay">Homestay</option>
              <option value="Country House">Country House</option>
              <option value="Chalet">Chalet</option>
            </select>

              <select name="Location" class="create-reports-location3" style="right:460apx; top:35px;">
              <option value="empty" selected="">Location</option>
              <option value="Rhodes">Rhodes</option>
              <option value="Santorini">Santorini</option>
              <option value="Thessaloniki">Thessaloniki</option>
              <option value="Athens">Athens</option>
              <option value="Naxos">Naxos</option>
              <option value="Mykonos">Mykonos</option>
              <option value="Aridea">Aridea</option>
              <option value="Salamina">Salamina</option>
            </select>
          </form>
        </div>
        <span class="create-reports-rating-text">
          <span>-Rating and Evaluation&nbsp;</span>
          <span>Reports-</span>
          <br />
        </span>
        <div class="create-reports-container08">
          <form class="create-reports-form07" method="POST">
            <span class="create-reports-no-filters-text">
              <span>No filters needed</span>
              <br />
            </span>
            <button type="submit" name="ButtonAverageRatingAndR"
              class="create-reports-calculate-occupancy-rate-button2 button">
              <span>
                <span class="create-reports-text32">
                  Get Average Rating And Reviews
                </span>
                <br />
              </span>
            </button>
          </form>
        </div>
        <div class="create-reports-container09">
          <form class="create-reports-form08" method="POST">
            <span class="create-reports-no-filters-text1">
              <span>No filters needed</span>
              <br />
            </span>
            <button type="submit" name="ButtonIdentifyPByR"
              class="create-reports-compare-reservation-trends-button2 button">
              <span class="create-reports-text36">
                Identify Properties By Rating
              </span>
            </button>
          </form>
        </div>
        <span class="create-reports-room-availability-text">
          <span>-Room Availability&nbsp;</span>
          <span>Report-</span>
          <br />
        </span>
        <div class="create-reports-container10">
          <form class="create-reports-form09" method="POST">
            <button type="submit" name="ButtonOverviewOfRTInvAndOcc"
              class="create-reports-compare-reservation-trends-button3 button">
              <span class="create-reports-text40">
                Overview Of Room Type Inventory And Occupancy
              </span>
            </button>
            <select name="PropertyType" class="create-reports-property-type4" >
              <option value="empty" selected="">Property Type</option>
              <option value="Resort">Resort</option>
              <option value="Hostel">Hostel</option>
              <option value="Hotel">Hotel</option>
              <option value="Lodge">Lodge</option>
              <option value="Motel">Motel</option>
              <option value="Love Hotel">Love Hotel</option>
              <option value="Capsule Hotel">Capsule Hotel</option>
              <option value="Japanese Style Hotel">
                Japanese Style Hotel
              </option>
              <option value="Hotel">Hotel</option>
              <option value="Lodge">Lodge</option>
              <option value="Motel">Motel</option>
              <option value="Capsule Hotel">Capsule Hotel</option>
              <option value="Japanese Style Hotel">
                Japanese Style Hotel
              </option>
              <option value="Apartment">Apartment</option>
              <option value="Tent">Tent</option>
              <option value="Villa">Villa</option>
              <option value="Homestay">Homestay</option>
              <option value="Country House">Country House</option>
              <option value="Chalet">Chalet</option>
            </select>
            <select name="RoomType" class="create-reports-room-type4">
              <option value="empty" selected="">Room Type</option>
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
              <option value="Dormitory Room">Dormitory Room</option>
              <option value="Bed in Dormitory">Bed in Dormitory</option>
              <option value="Bungalow">Bungalow</option>
              <option value="Chalet">Chalet</option>
              <option value="Holiday Home">Holiday Home</option>
              <option value="Villa">Villa</option>
              <option value="Mobile Home">Mobile Home</option>
              <option value="Tent">Tent</option>
            </select>
            <select name="Location" class="create-reports-location4">
              <option value="empty" selected="">Location</option>
              <option value="Rhodes">Rhodes</option>
              <option value="Santorini">Santorini</option>
              <option value="Thessaloniki">Thessaloniki</option>
              <option value="Athens">Athens</option>
              <option value="Naxos">Naxos</option>
              <option value="Mykonos">Mykonos</option>
              <option value="Aridea">Aridea</option>
              <option value="Salamina">Salamina</option>
            </select>
            <input type="text" name="EndDate" enctype="Surname" required="" placeholder="End Date"
              autocomplete="family-name" class="create-reports-end-date7 input" />
            <input type="text" name="StartDate" required="" placeholder="Start Date" autocomplete="name"
              class="create-reports-start-date7 input" />
          </form>
        </div>
      </div>
      <span class="create-reports-performance-report-text">
        <span>-Performance Reports-</span>
        <br />
      </span>
      <div class="create-reports-performance-reports-container">
        <span class="create-reports-filters-header">
          <span>-CHOOSE FILTERS-</span>
          <br />
        </span>
        <div class="create-reports-container11">
          <form class="create-reports-form10" method="POST">
            <button name="ButtonGetPropertyRoomBookingStatus" type="submit"
              class="create-reports-compare-reservation-trends-button4 button">
              <span class="create-reports-text45">
                Get Property Room Booking Status
              </span>
            </button>
            <input type="text" name="EndDate" enctype="Surname" required="" placeholder="End Date"
              autocomplete="family-name" class="create-reports-min-books input" />
            <input type="text" name="StartDate" required="" placeholder="Start Date" autocomplete="name"
              class="create-reports-year-for-min-books input" />

            <select name="PropertyType" class="create-reports-property-type-for-min-books input" required="">
              <option value="" selected="">Property Name</option>
              <?php


              $serverName = $_SESSION["serverName"];
              $connectionOptions = $_SESSION["connectionOptions"];
              $conn = sqlsrv_connect($serverName, $connectionOptions);

              $tsql = "{call spGetProperties}";
              $getResults = sqlsrv_query($conn, $tsql);

              if ($conn === false) {
                die(print_r(sqlsrv_errors(), true));
              }

              while ($row = sqlsrv_fetch_array($getResults, SQLSRV_FETCH_ASSOC)) {
                $ID = $row['Property_ID'];
                $Name = $row['Property_Name'];
                
                echo "<option value='$ID'>$Name</option>";
              }

              sqlsrv_free_stmt($getResults);
              sqlsrv_close($conn);

              // 
              ?>
            </select>
          </form>
        </div>
        <div class="create-reports-container12">
          <form class="create-reports-form11" method="POST">
            <button name="ButtonGetRoomsWithMonthlyBookings" type="submit"
              class="create-reports-compare-reservation-trends-button5 button">
              <span class="create-reports-text46">
                Get Rooms With Monthly Bookings
              </span>
            </button>
            <input type="text" name="Year" enctype="Surname" required="" placeholder="Year" autocomplete="family-name"
              class="create-reports-year-for-rooms-monthly-bookings input" />
            <select name="PropertyType" class="create-reports-property-typefor-room-monthly-bookings input" required="">
              <option value="" selected="">Property Name</option>
              <?php


              $serverName = $_SESSION["serverName"];
              $connectionOptions = $_SESSION["connectionOptions"];
              $conn = sqlsrv_connect($serverName, $connectionOptions);

              $tsql = "{call spGetProperties}";
              $getResults = sqlsrv_query($conn, $tsql);

              if ($conn === false) {
                die(print_r(sqlsrv_errors(), true));
              }

              while ($row = sqlsrv_fetch_array($getResults, SQLSRV_FETCH_ASSOC)) {
                $ID = $row['Property_ID'];
                $Name = $row['Property_Name'];
                
                echo "<option value='$ID'>$Name</option>";
              }

              sqlsrv_free_stmt($getResults);
              sqlsrv_close($conn);

              // 
              ?>
            </select>
          </form>
        </div>
        <div class="create-reports-container13">
          <form class="create-reports-form12" method="POST">
            <button name="ButtonGetRoomsWithMinimumBookings" type="submit"
              class="create-reports-compare-reservation-trends-button6 button">
              <span class="create-reports-text47">
                Get Rooms With Minimum Bookings
              </span>
            </button>
            <input type="number" name="Year" enctype="Surname" required="" placeholder="Year" autocomplete="family-name"
              class="create-reports-year-for-min-books1 input" />
            <input type="number" name="MinBooks" enctype="Surname" required="" placeholder="Minimum Books"
              autocomplete="family-name" class="create-reports-min-books1 input" />
            <select name="PropertyType" class="create-reports-property-type-for-min-books1 input" required>
              <option value="" selected="" >Property Name</option>
              <?php


              $serverName = $_SESSION["serverName"];
              $connectionOptions = $_SESSION["connectionOptions"];
              $conn = sqlsrv_connect($serverName, $connectionOptions);

              $tsql = "{call spGetProperties}";
              $getResults = sqlsrv_query($conn, $tsql);

              if ($conn === false) {
                die(print_r(sqlsrv_errors(), true));
              }

              while ($row = sqlsrv_fetch_array($getResults, SQLSRV_FETCH_ASSOC)) {
                $ID = $row['Property_ID'];
                $Name = $row['Property_Name'];
                
                echo "<option value='$ID'>$Name</option>";
              }

              sqlsrv_free_stmt($getResults);
              sqlsrv_close($conn);

              // 
              ?>
            </select>
          </form>
        </div>
      </div>


      <?php if (!empty($tableData)): ?>
        <table class="bottom-table">
          <tr>
            <?php foreach ($tableHeaders as $header): ?>
              <th>
                <?php echo $header; ?>
              </th>
            <?php endforeach; ?>
          </tr>
          <?php foreach ($tableData as $row): ?>
            <tr>
              <?php foreach ($row as $cell): ?>
                <td>
                  <?php
                  if ($cell instanceof DateTime) {
                    echo $cell->format('Y-m-d');
                  } else {
                    echo $cell;
                  }
                  ?>
                </td>
              <?php endforeach; ?>
            </tr>
          <?php endforeach; ?>
        </table>
      <?php endif; ?>

    </div>

  </div>

</body>

</html>