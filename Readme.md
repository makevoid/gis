# GIS
### Geo Information System

creates google maps with markers from CSVs

### features:

- read and geocodes csv, save position datas into locations.json
- read locations.json and display a google map with markers

### launch it:

- clone/download the code
- open a shell and run

    bundle
    foreman start

- visit http://localhost:3000


### convert locations.csv to locations.json geocoding locations

   ruby -e "Localizer.new.localize" -r ./models/localizer.rb

### todo:

- export image (canvas like screenshot of the page?)