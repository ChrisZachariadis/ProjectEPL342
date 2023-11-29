<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Sign Up Form by Colorlib</title>

    <!-- Google Font -->
    <link href="https://fonts.googleapis.com/css2?family=Google+Sans&display=swap" rel="stylesheet">

    <!-- Main css -->
    <link rel="stylesheet" href="css/style.css">

    <!-- Vendor CSS (If needed) -->
    <link rel="stylesheet" href="vendor/jquery-ui/jquery-ui.min.css">

    <link rel="stylesheet" href="css/logregY.css" media="screen">
</head>

<hreader>
<?php 
session_start();
print_r($_SESSION['LogedIn']);
if($_SESSION['LogedIn'] == false)
echo     "<button onclick='location.href='login.php'' type='button' class='log' style=''>Log in</button>
<button onclick='location.href='register.php'' type='button' class='reg'>Register</button>";
?>
</hreader>
<body>

    <div class="main">

        <div class="header">
            <img src="images/header-text.png" alt="">
            <img src="images/dots.png" alt="">
        </div>
        <div class="container">
            <form id="booking-form" class="booking-form" method="POST" action="Catalogue-Property.php">
                <div class="form-group">
                    <div class="form-destination">
                        <label for="destination">Destination</label>
                        <select type="text" id="destination" name="destination">
                            <option value="empty">Select a Destination</option>
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
                    </div>
                    <div class="form-date-from form-icon">
                        <label for="date_from">From</label>
                        <input type="text" id="date_from" class="date_from" name="date_from" placeholder="Pick a date"
                            required readonly/>
                    </div>
                    <div class="form-date-to form-icon">
                        <label for="date_to">To</label>
                        <input type="text" id="date_to" class="date_to" name="date_to" placeholder="Pick a date"
                            required readonly/>
                    </div>

                    <!-- <div class="form-submit">
                        <input type="submit" id="submit" class="submit" value="Book now" /> -->

                    <div class="form-submit">
                        <button type="submit" id="submit" class="submit-button">Book now</button>
                    </div>


                    <!-- </div> -->
                </div>

                <div class="form-group">
                    <div class="form-date-from" style="width: 230px;">
                        <label for="Rooms">Room Type</label>
                        <select id="Rooms" name="Rooms">
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
                            <option value="Dormitory">Dormitory</option>
                            <option value="Bed in Dormitory">Bed in Dormitory</option>
                            <option value="Bungalow">Bungalow</option>
                            <option value="Chalet">Chalet</option>
                            <option value="Holiday House">Holiday House</option>
                            <option value="Villa">Villa</option>
                            <option value="Mobile Home">Mobile Home</option>
                            <option value="Tent">Tent</option>

                            <!-- Add more options as needed -->
                        </select>
                    </div>
                    <div class="form-date-from form-icon2">
                        <label for="date_from">Property Type</label>
                        <select id="Property" name="Property">
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
                    </div>

                    <!-- <div class="form-submit">
                        <input type="submit" id="submit" class="submit" value="Book now" /> -->




                    <!-- </div> -->
                </div>
        
        </form>
    </div>

    </div>

    <!-- JS -->
    <script src="vendor/jquery/jquery.min.js"></script>
    <script src="vendor/jquery-ui/jquery-ui.min.js"></script>
    <script src="js/main.js"></script>
</body><!-- This templates was made by Colorlib (https://colorlib.com) -->

</html>