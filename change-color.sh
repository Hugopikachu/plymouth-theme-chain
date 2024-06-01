#! /bin/bash
# If the bash locale has another decimal seperator as '.' there would be an error (i.e. de_DE.utf8)
LC_ALL=C

########## HELPERS ##########

# Displays the usage and exits
usage() {
    echo "Usage: $0 <mode> <color>"
    echo
    echo "The color must be a 6 digits hexadecimal code with a leading # (e.g \"#ABC123\")"
    echo
    echo "Mode can be one of the following"
    echo " background       Set <color> as background color"
    echo " main             Set <color> as main theme color"
    echo " secondary        Set <color> as secondary color"
    exit 1
}

# Tests if a string is a valid hexadecimal color code
#
# ARGUMENT
#   A string to be tested
# RETURN
#   true or false (success or failure)
is_hexadecimal_color() {
    [[ $1 =~ ^\#[A-F0-9]{6}$ ]]
}

# Converts an hexadecimal code to RGB components
#
# ARGUMENT
# 	An hexadecimal code in uppercase (e.g #123ABC)
# OUTPUT
#   The R, G, B components
hex_to_rgb() {
    red=$(echo "ibase=16; ${1:1:2}" | bc)
    green=$(echo "ibase=16; ${1:3:2}" | bc)
    blue=$(echo "ibase=16; ${1:5:2}" | bc)

    echo $red $green $blue
}

# normalize an RGB component over 255 (FF)
#
# ARGUMENT
#   An integer representing an RGB component
# OUTPUT
#   A float representing the normalized component with 5 significative digits
normalize_rgb() {
    printf "%1.5f" $(echo "scale=5; $1 / 255" | bc)
}


########## FUNCTIONS ##########

change_background() {
    # Uppercase-ing the first argument
    color=${1^^}

    # Sanity check
    is_hexadecimal_color $color || usage

    # Store RGB components in vars $red $green and $blue
    read -r red green blue < <(hex_to_rgb $color)

    red=$(normalize_rgb $red)
    green=$(normalize_rgb $green)
    blue=$(normalize_rgb $blue)

    # Update main script with RGB values
    sed -i "s/^BG_COLOR.red = .*;$/BG_COLOR.red = $red;/" chain.script
    sed -i "s/^BG_COLOR.green = .*;$/BG_COLOR.green = $green;/" chain.script
    sed -i "s/^BG_COLOR.blue = .*;$/BG_COLOR.blue = $blue;/" chain.script
}

change_main() {
    # Uppercase-ing the first argument
    color=${1^^}

    # Sanity check
    is_hexadecimal_color $color || usage

    # Change colors in PNGs
    magick images/bar-progress.png -channel RGB -fuzz 100% -fill $color -opaque $color images/bar-progress.png
    magick images/lock.png -channel RGB -fuzz 100% -fill $color -opaque $color images/lock.png
    find ./images/animation -type f -name "*.png" -exec magick {} -channel RGB -fuzz 100% -fill $color -opaque $color {} \;

    # Store RGB components in vars $red $green and $blue
    read -r red green blue < <(hex_to_rgb $color)

    red=$(normalize_rgb $red)
    green=$(normalize_rgb $green)
    blue=$(normalize_rgb $blue)

    # Update main script with RGB values
    sed -i "s/^MAIN_COLOR.red = .*;$/MAIN_COLOR.red = $red;/" chain.script
    sed -i "s/^MAIN_COLOR.green = .*;$/MAIN_COLOR.green = $green;/" chain.script
    sed -i "s/^MAIN_COLOR.blue = .*;$/MAIN_COLOR.blue = $blue;/" chain.script
}

change_secondary() {
    # Uppercase-ing the first argument
    color=${1^^}

    # Sanity check
    is_hexadecimal_color $color || usage

    # Change colors in PNGs
    magick images/bar-background.png -channel RGB -fuzz 100% -fill $color -opaque $color images/bar-background.png
    magick images/input.png -channel RGB -fuzz 100% -fill $color -opaque $color images/input.png

    # Store RGB components in vars $red $green and $blue
    read -r red green blue < <(hex_to_rgb $color)

    red=$(normalize_rgb $red)
    green=$(normalize_rgb $green)
    blue=$(normalize_rgb $blue)

    # Update main script with RGB values
    sed -i "s/^SECONDARY_COLOR.red = .*;$/SECONDARY_COLOR.red = $red;/" chain.script
    sed -i "s/^SECONDARY_COLOR.green = .*;$/SECONDARY_COLOR.green = $green;/" chain.script
    sed -i "s/^SECONDARY_COLOR.blue = .*;$/SECONDARY_COLOR.blue = $blue;/" chain.script
}

########## MAIN SCRIPT ##########

# Make sure exactly two args are passed to the script
[[ $# -ne 2 ]] && usage

# Parse mode
case $1 in
    background)
        change_background $2
        ;;
    main)
        change_main $2
        ;;
    secondary)
        change_secondary $2
        ;;
    *)
        usage
        ;;
esac
