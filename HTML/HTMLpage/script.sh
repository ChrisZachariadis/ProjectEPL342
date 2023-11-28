
# Duplicate the image directory
echo "Duplicating the image directory..."
cp -r ./images ./Original

# Iterate over each file in the images directory
for file in ./images/*; do
    # Add your code here to process each file
    
    filename=$(basename $file)

    echo "Processing file: $filename"

    cp ./pic.png ./images/$filename
done


