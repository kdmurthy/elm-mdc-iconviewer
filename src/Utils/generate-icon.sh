#!/bin/bash

function category() {
    cat=$1
    folder=$2
    cat <<EOF > Icons/$cat.elm
module Utils.Icons.$cat exposing(..)

EOF
    for i in $folder/*
    do
        iconName=$(basename $i | sed -e 's/^[0-9]/icon_&/')
        icon=$(basename $i)
        cat <<EOF >> Icons/$cat.elm
$iconName : String
$iconName = "$icon"

EOF
    done
}

# Generate Categorized Icon names
mkdir -p Icons
for i in ~/Projects/reference/material-design-icons/png/*
do
    category $(basename $i | sed -e 's/./\U&/') $i
done

function import() {
    cat=$1
    cat <<EOF >> Icons.elm
import Utils.Icons.$cat
EOF
}

function redirection() {
    cat=$1
    folder=$2
    for i in $folder/*
    do
        iconName=$(basename $i | sed -e 's/^[0-9]/icon_&/')
        cat <<EOF >> Icons.elm
$iconName : String
$iconName = Utils.Icons.$cat.$iconName

EOF
    done
}

# Generate Icons module
echo 'module Utils.Icons exposing(..)' > Icons.elm
echo >> Icons.elm
for i in ~/Projects/reference/material-design-icons/png/*
do
    import $(basename $i | sed -e 's/./\U&/')
done
for i in ~/Projects/reference/material-design-icons/png/*
do
    redirection $(basename $i | sed -e 's/./\U&/') $i
done

# Generate IconList module

function iconentry() {
    category=$1
    folder=$2

    for i in $folder/*
    do
        iconName=$(basename $i | sed -e 's/^[0-9]/icon_&/')
        cat <<EOF >> IconList.elm
        { name = Icons.$iconName, function="$iconName", category = "$category" },
EOF
    done
}

cat <<EOF > IconList.elm
module Utils.IconList exposing(IconInfo, iconList, iconCategories)

import Utils.Icons as Icons

type alias IconInfo =
    { name : String
    , function: String
    , category : String
    }

iconList: List IconInfo
iconList =
    [
EOF

for i in ~/Projects/reference/material-design-icons/png/*
do
    category=$(basename $i | sed -e 's/./\U&/')
    iconentry $category $i
done

cat <<EOF  >> IconList.elm
        { name = Icons.info, function="info", category = "LastOne" }
    ]
EOF

# List of categories
cat <<EOF >> IconList.elm

iconCategories: List ( String, String )
iconCategories =
EOF

echo "    [ ( \"All\", \"category\")" >> IconList.elm
for i in ~/Projects/reference/material-design-icons/png/*
do
    category=$(basename $i | sed -e 's/./\U&/')
	file=$(echo $i/* | awk '{ print $1 }')
	iconstr=$(basename $file)
	echo "    , (\"$category\", \"$iconstr\")" >> IconList.elm
done

echo "    ]" >> IconList.elm

