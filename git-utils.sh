#!/usr/bin/env bash

# Clone the repository from specified URL and try to checkout to its the specified branch.
# If that fails, try `dev` branch and `master` branch.
# Return the directory to the cloned repository.
#
# Example:
# fallback_clone_branch https://github.com/Cognexa/cxflow.git restore
function fallback_clone_branch {
    echo "Fallback clone: " "$1" "$2" > /dev/stderr
    url="$1"
    target_branch="$2"
    old_pwd=$(pwd)
    project_name=$(echo "$url" | sed 's|.*/\(.*\)\.git|\1|g')
    echo "Project name: " "$project_name" > /dev/stderr

    git clone "$url"
    cd "$project_name"
    project_path=$(pwd)

    for branch in "$target_branch" "dev" "master"; do
        echo "Trying checkout to $branch" > /dev/stderr
        if git checkout "$branch" > /dev/stderr; then
            break
        fi
    done

    cd "$old_pwd"
    echo "$project_path"
}

# Clone the repository from specified URL and try to `pip install` from specified branch.
# If that fails, try `dev` branch and `master` branch.
#
# Example:
# fallback_pip_install_branch https://github.com/Cognexa/cxflow.git restore
function fallback_pip_install_branch {
    old_pwd=$(pwd)
    echo "Fallback pip install: " "$1" "$2" > /dev/stderr
    cd /tmp
    project_path=$(fallback_clone_branch "$1" "$2")
    echo "Project path: " "$project_path" > /dev/stderr
    cd "$project_path"
    pip3 install .
    cd "$old_pwd"
}
