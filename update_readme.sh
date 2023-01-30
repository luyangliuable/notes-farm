#!/bin/bash

function ensure_readme_exists() {
    cat README.md >> /dev/null
    exists=$(echo $?)

    echo $exists

    if [ $exists -eq 0 ]; then
        echo "README.md exists"
    else
        touch README.md
        echo "# $(basename "$PWD")" >> README.md
        echo "" >> README.md
        echo "## Examples" >> README.md
    fi
}

function add_code() {
    echo "* $file" >> /tmp/markdowntemp
    echo "" >> /tmp/markdowntemp
    echo '```js' >> /tmp/markdowntemp
    cat $file >> /tmp/markdowntemp
    echo '```' >> /tmp/markdowntemp
}

function add_note() {
    replace_flag=$1
    content=$2

    line_number=$(grep -n "## Examples" README.md | cut -d ":" -f 1)

    echo $replace_flag
    echo "" > /tmp/markdowntemp

    if [ $replace_flag -eq 1 ]; then
        echo "Replace"
        head -n "$line_number" README.md >> /tmp/markdowntemp
        add_code 
        cat /tmp/markdowntemp > README.md # Overwrite
    else
        echo "Append"
        add_code
        cat /tmp/markdowntemp >> README.md # Append
    fi

}


function search_files() {
    echo "Updating code blocks in README.md"

    # Find all code files
    code_files=( $(find . -maxdepth 1  \( -name "*.sh" -o -name "*.js" -o -name "*.c" \) -type f) )

    # Loop through code files
    counter=0

    for file in "${code_files[@]}"; do
        # Get the file name without the path or extension

        content=$(cat $file)

        # echo $content

        if [ $counter -eq 0 ]; then
            add_note  1 $content
        else
            add_note 0 $content
        fi

        counter=$((counter + 1))

        # gsed -i '/# Examples/{n;s/.*/$content/};' README.md

    done

    echo "Done updating code blocks in README.md"
}

ensure_readme_exists
search_files
