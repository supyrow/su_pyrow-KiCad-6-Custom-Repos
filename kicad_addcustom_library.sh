#!/bin/bash
#Auto download kicad-footprints and kicad-symbols.
#updates the proper Footprint and Symbol Table files so it is reflected in KiCad globally.

# need to determine which directory is used, kicad or kicadnightly comment/uncomment as needed
kicad_config_dir="$HOME/.config/kicadnightly"
#kicad_config_dir="$HOME/.config/kicad"
#repositories
git_footprints="https://gitlab.com/kicad/libraries/kicad-footprints.git"
git_symbols="https://gitlab.com/kicad/libraries/kicad-symbols.git"
#location of pulled or cloned data
#localSymbolStorage="/kicad-symbols"
localSymbolStorage="/crypt-storage1/electronics/KiCad/LIBRARIES/kicad-symbols"
localFootprintStorage="/crypt-storage1/electronics/KiCad/LIBRARIES/kicad-footprints"
# KISYSMINE is a locally EXPORTED variable to directory of custom footprint and symbol libraries.
# add a line to ~/.bashrc i.e   EXPORT KISYSMINE="where ever you hide your custom library"
# then run      source ~/.bashrc  library    to activate the export, kicad will not find it, if this is not done.
KISYSMINE="/crypt-storage1/electronics/KiCad/LIBRARIES"

fplib_name="MYfootprintLib"
pretty_file="MYfootprintLib.pretty"
fpdescr="MYfootprintLib Description"

symlib_name="MYsymbolLib"
kicad_sym_file="MYsymbol.kicad_sym"
symdescr="MYsymbolLib Description"

usage()
{
    echo ""
    echo " ^ ^ ^  E D I T  T H I S  F I L E  ^ ^ ^"
    echo " usage:"
		echo "      --clone-pull         "
    echo ""
		echo " (pulls from https://www.gitlab.com)"
		echo " into $KISYSMINE "
		echo ""
    }
update_footprints()
{
    repo_footprints="kicad-footprints"
    cd "$KISYSMINE"
    if [ ! -e "$repo_footprints" ]; then
        echo "installing $repo_footprints"
        git clone "$git_footprints" "$localFootprintStorage"
            echo " "
    else
        echo "pulling from $repo_footprints"
        cd "$localFootprintStorage"
        git pull
            echo " "
    fi
}
update_symbols()
{
    repo_symbols="kicad-symbols"
cd "$KISYSMINE"
         if [ ! -e "$repo_symbols" ]; then
            echo "installing $repo_symbols"
            git clone "$git_symbols" "$localSymbolStorage"
                echo " "
        else
            echo "pulling from $repo_symbols"
            cd "$localSymbolStorage"
            git pull
                echo " "
        fi
}
# this is run from command line to pull or clone the repositories from gitlab
if [ $# -eq 1 -a "$1" == "--clone-pull" ]; then
    update_footprints
    update_symbols
## Append custom library to the end of fp-lib-table and give EOL (reason for the extra ")"   )
 fp_table_file="$kicad_config_dir/fp-lib-table"
 sed -i '$ s/)$//' "$fp_table_file"
 echo "Appending custom library to $fp_table_file"
    head -n -1 $localFootprintStorage/fp-lib-table > $kicad_config_dir/fp-lib-table;
echo "  (lib (name $fplib_name)(type KiCad)(uri \${KISYSMINE}/$pretty_file)(options \"\")(descr \"$fpdescr\")))" >> "$fp_table_file"
 sym_table_file="$kicad_config_dir/sym-lib-table"
 sed -i '$ s/)$//' "$sym_table_file"
 echo "Appending custom library to $sym_table_file"
    head -n -1 $localSymbolStorage/sym-lib-table > $kicad_config_dir/sym-lib-table;
echo "  (lib (name \"$symlib_name\")(type \"KiCad\")(uri \"\${KISYSMINE}/$kicad_sym_file\")(options \"\")(descr \"$symdescr\")))" >> "$sym_table_file"
exit
fi
usage
