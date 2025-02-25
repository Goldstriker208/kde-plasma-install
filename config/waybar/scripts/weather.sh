#!/bin/sh

# Location Francisco (latitude,longitude)
LOC="37.7749,-122.4194"

# Set unit preference: "C" for Celsius, "F" for Fahrenheit
UNIT="F"  # Change this to "C" if you want Celsius

# Determine the correct wttr.in unit flag
if [ "$UNIT" = "F" ]; then
    UNIT_FLAG="&u"  # Fahrenheit
else
    UNIT_FLAG=""    # Default is Celsius (no flag needed)
fi

# Fetch weather data
text="$(curl -s "https://wttr.in/$LOC?format=1$UNIT_FLAG" | sed 's/ //g' | sed 's/+//')"
tooltip="$(curl -s "https://wttr.in/$LOC?0QT$UNIT_FLAG" |
    sed 's/\\/\\\\/g' |
    sed ':a;N;$!ba;s/\n/\\n/g' |
    sed 's/"/\\"/g')"

# Display weather if the location is valid
if ! grep -q "Unknown location" <<< "$text"; then
    echo "{\"text\": \"$text\", \"tooltip\": \"<tt>$tooltip</tt>\", \"class\": \"weather\"}"
fi
