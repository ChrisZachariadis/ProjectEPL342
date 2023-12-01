<?php
$tableData = [];

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    // Generate your table data here
    $postedVar = array_key_first($_POST);
    switch ($postedVar) {
        case '1':
            $tableData = [
                ['Name' => 'John Doe', 'Email' => 'john@example.com'],
                ['Name' => 'Jane Doe', 'Email' => 'jane@example.com'],
                ['Name' => 'Joe Doe', 'Email' => 'test', 'Value' => '2'],
                
                // Add more data as needed
            ];
            $tableHeaders = ['Name', 'Email', 'Value'];
            break;
        case '2':
            $tableData = [
                ['Product' => 'Product 1', 'Price' => '$100'],
                ['Product' => 'Product 2', 'Price' => '$200'],
                // Add more data as needed
            ];
            $tableHeaders = ['Product', 'Price'];
            break;
        // Add more cases as needed
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>My Website</title>
    <style>
        /* Add CSS to position the table at the bottom of the page */
        .bottom-table {
            position: absolute;
            bottom: 0;
            width: 100%;
        }
    </style>
</head>
<body>
    <h1>Welcome to My Website</h1>
    <p>This is a basic HTML website.</p>

    <!-- Add a form with a submit button -->
    <form method="post" value="1">
        <button type="submit" name="1">Submit</button>
    </form>

    <form method="post">
        <button type="submit" name="2">Submit</button>
    </form>

    <!-- Display the table at the bottom of the page -->
    <?php if (!empty($tableData)): ?>
    <table class="bottom-table">
        <tr>
            <?php foreach ($tableHeaders as $header): ?>
                <th><?php echo $header; ?></th>
            <?php endforeach; ?>
        </tr>
        <?php foreach ($tableData as $row): ?>
            <tr>
                <?php foreach ($row as $cell): ?>
                    <td><?php echo $cell; ?></td>
                <?php endforeach; ?>
            </tr>
        <?php endforeach; ?>
    </table>
<?php endif; ?>
</body>
</html>