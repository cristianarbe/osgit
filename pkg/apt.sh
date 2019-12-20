#!/bin/env sh

get_installed() {
    dpkg-query -Wf '${Package}\n'
}

update_packages_and_git() {
    get_installed > "$OSGIT_PROFILE"/packages
    add_commit "$1"
}

fn_dryrun() {
    added="$(fn_plus "$1")"
    removed="$(fn_minus "$1")"

    if test -n "$added"; then
        echo "The following packages will be installed:"
        for package in $added; do
            printf "\\t%s\\n" "$package"
        done
    else
        echo "No packages will be installed."
    fi

    echo ""

    if test -n "$removed"; then
        echo "The following packages will be to be REMOVED:"
        for package in $removed; do
            printf "\\t%s\\n" "$package"
        done
    else
        echo "No packages will be removed."
    fi

}
