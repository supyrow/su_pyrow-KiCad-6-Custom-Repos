# su_pyrow-KiCad-6-Custom-Repos.sh
 Automate downloading and updating of KiCad-6-dev AKA KiCad-nightly Libraries including 3D, Schematic symbols, PCB footprints, Templates, update the symbol and footprint tables WITH your custom libraries.

 Conveniently add your own custom library that you may have already created at the very end of those tables!

There are three reasons why you might want to run this script:

1) You want local copies of bleeding edge symbols, 3D and parts
2) you have your own working library(symbols/parts) and 3D STEP/IGES files 
3) sick of needing to add them to every single project you start.

# first we need to establish some variables.
   * add this to your ~/.bashrc
   * NOTE: this is where KiCad will look for your libararies.
   * KISYSMINE points to DIRECTORY where your custom library file is located.
   * MYPACKAGES3D points to DIRECTORY where your custom 3D packages are located.
```bash
# ~/.bashrc

export KISYSMINE="/crypt-storage1/electronics/KiCad/LIBRARIES"
export MYPACKAGES3D="/crypt-storage1/electronics/KiCad/LIBRARIES/MyPackages3D"
 ```
# if you want all repos local and able to be updated easily.
 ```bash
# ~/.bashrc
export KICAD6_FOOTPRINT_DIR="/crypt-storage1/electronics/KiCad/LIBRARIES/kicad-footprints"
export KICAD6_SYMBOL_DIR="/crypt-storage1/electronics/KiCad/LIBRARIES/kicad-symbols"
export KICAD6_3DMODEL_DIR="/crypt-storage1/electronics/KiCad/LIBRARIES/kicad-packages3D"
export KICAD6_TEMPLATE_DIR="/crypt-storage1/electronics/KiCad/LIBRARIES/kicad-templates/Projects"
export KICAD6_PLUGN_DIR="/crypt-storage1/electronics/KiCad/PLUGINS"

export KICAD_USER_PLUGINS_DIR="/crypt-storage1/electronics/KiCad/PLUGINS"
export KICAD_SYMBOL_DIR="/crypt-storage1/electronics/KiCad/LIBRARIES/kicad-symbols"
export KISYS3DMOD="/crypt-storage1/electronics/KiCad/LIBRARIES/kicad-packages3D"
export KISYSMOD="/crypt-storage1/electronics/KiCad/LIBRARIES/kicad-footprints"
export KICAD_USER_TEMPLATE_DIR="/crypt-storage1/electronics/KiCad/LIBRARIES/Mykicad-templates"
export KICAD_TEMPLATE_DIR="/crypt-storage1/electronics/KiCad/LIBRARIES/kicad-templates/Projects"

export KISYSMINE="/crypt-storage1/electronics/KiCad/LIBRARIES"
export MYPACKAGES3D="/crypt-storage1/electronics/KiCad/LIBRARIES/MyPackages3D"
```
# this file needs to be removed or change(chmod) executable status
```bash
sudo chmod -x /etc/profile.d/kicad-env.sh
```
# OR
```bash
sudo rm /etc/profile.d/kicad-env.sh
```
# edit and add these lines to environment file
```bash
/usr/share/kicad-nightly/kicad-nightly.env
```
# You must change PATH:
* /crypt-storage1/electronics/KiCad
* Set where the library repos will go, use a full path it will create two new directories.
* * 'PLUGINS' and 'LIBRARIES' inside of:
* /crypt-storage1/electronics/KiCad/

```bash
export KICAD6_FOOTPRINT_DIR="/crypt-storage1/electronics/KiCad/LIBRARIES/kicad-footprints"
export KICAD6_SYMBOL_DIR="/crypt-storage1/electronics/KiCad/LIBRARIES/kicad-symbols"
export KICAD6_3DMODEL_DIR="/crypt-storage1/electronics/KiCad/LIBRARIES/kicad-packages3D"
export KICAD6_TEMPLATE_DIR="/crypt-storage1/electronics/KiCad/LIBRARIES/kicad-templates/Projects"
export KICAD6_PLUGN_DIR="/crypt-storage1/electronics/KiCad/PLUGINS"
```
# now... the actual script
* copy and save as
```bash
su_pyrow-KiCad-6-Custom-Repos.sh
```

```bash
#!/bin/bash
#
# su_pyrow-KiCad-6-Custom-Repos.sh
#
# Get all KiCad library and plugin repos:
#
# The "install_prerequisites" step is the only "distro dependent" one.  Could modify
# that step for other linux distros.
# This script requires "git".  The package bzr-git is not up to the task.
# The first time you run with option --install-or-update that is the slowest, because
# git clone from github.com/gitlab is slow.
# After that updates should run faster.

# There are three reasons why you might want to run this script:

# 1) You want local copies of bleeding edge symbols, 3D and parts
# 2) you have your own working library(symbols/parts) and 3D STEP/IGES files 
# 3) sick of needing to add them to every single project you start.

#Auto download kicad-libraries, kicad-footprints, kicad-templates, kicad-packages3D and kicad-symbols.
#this also updates the proper Table files so it is reflected in eeschema and pcbnew.

#This was adapted from the script entitled kicad-libraries-repos.sh

# Y O U   M U S T  C H A N G E  PATH: /crypt-storage1/electronics/KiCad
# Set where the library repos will go, use a full path it will create two new directories.  'PLUGINS' and 'LIBRARIES'
WORKING_TREES=${WORKING_TREES:-/crypt-storage1/electronics/KiCad}

# this is located in your home directory
#TABLE_DEST_DIR=.config/kicad
TABLE_DEST_DIR=.config/kicadnightly

usage()
{
    echo ""
    echo " usage:"
    echo ""
    echo "./su_pyrow-KiCad-6-Custom-Repos.sh <cmd>"
    echo "    where <cmd> is one of:"
    echo "	examples (with --install-prerequisites once first):"
    echo "	$ ./su_pyrow-KiCad-6-Custom-Repos.sh --install-prerequisites"
    echo "	$ ./su_pyrow-KiCad-6-Custom-Repos.sh --install-or-update"
}

install_prerequisites()
{
    # Find a package manager, PM
    PM=$( command -v yum || command -v apt-get )

    # assume all these Debian, Mint, Ubuntu systems have same prerequisites
    if [ "$(expr match "$PM" '.*\(apt-get\)')" == "apt-get" ]; then
        #echo "debian compatible system"
        sudo apt-get install git curl #sed

    # assume all yum systems have same prerequisites
    elif [ "$(expr match "$PM" '.*\(yum\)')" == "yum" ]; then
        #echo "red hat compatible system"
        # Note: if you find this list not to be accurate, please submit a patch:
        sudo yum install git curl #sed

    else
        echo
        echo "Incompatible System. Neither 'yum' nor 'apt-get' found. Not possible to"
        echo "continue. Please make sure to install git, curl, and cut before using this"
        echo "script."
        echo
        exit 1
    fi
}

update_dirs()
{

    if [ ! -d "$WORKING_TREES" ]; then
        sudo mkdir -p "$WORKING_TREES/LIBRARIES"
        echo " mark $WORKING_TREES/LIBRARIES as owned by me"
        sudo chown -R `whoami` "$WORKING_TREES/LIBRARIES"
    fi

    cd $WORKING_TREES

    if [ ! -e "$WORKING_TREES/LIBRARIES" ]; then
        mkdir -p "$WORKING_TREES/LIBRARIES"
    fi

    if [ ! -d "$WORKING_TREES" ]; then
        sudo mkdir -p "$WORKING_TREES/PLUGINS"
        echo " mark $WORKING_TREES/PLUGINS as owned by me"
        sudo chown -R `whoami` "$WORKING_TREES/PLUGINS"
    fi

    cd $WORKING_TREES

    if [ ! -e "$WORKING_TREES/PLUGINS" ]; then
        mkdir -p "$WORKING_TREES/PLUGINS"
    fi
}

update_kicad_packages3D_generator()
{
    for repo_packages3D_generator in kicad-packages3D-generator; do
    if [ ! -e "$WORKING_TREES/LIBRARIES/$repo_packages3D_generator" ]; then
            echo "installing $WORKING_TREES/LIBRARIES/$repo_packages3D_generator"
            git clone "https://gitlab.com/kicad/libraries/kicad-packages3D-generator.git" "$WORKING_TREES/LIBRARIES/$repo_packages3D_generator"
        else
            echo "updating $WORKING_TREES/LIBRARIES/$repo_packages3D_generator"
            cd "$WORKING_TREES/LIBRARIES/$repo_packages3D_generator"
            git pull
        fi
    done
}

update_3d()
{
      for repo_3d in kicad-packages3D; do
        if [ ! -e "$WORKING_TREES/LIBRARIES/$repo_3d" ]; then
           echo "installing $WORKING_TREES/LIBRARIES/$repo_3d"
          git clone "https://gitlab.com/kicad/libraries/kicad-packages3D.git" "$WORKING_TREES/LIBRARIES/$repo_3d"
       else
           echo "updating $WORKING_TREES/LIBRARIES/$repo_3d"
           cd "$WORKING_TREES/LIBRARIES/$repo_3d"
           git pull
       fi
  done
}

update_symbols()
{
      for repo_kicad_symbols in kicad-symbols; do
        if [ ! -e "$WORKING_TREES/LIBRARIES/$repo_kicad_symbols" ]; then
           echo "installing $WORKING_TREES/LIBRARIES/$repo_kicad_symbols"
          git clone "https://gitlab.com/kicad/libraries/kicad-symbols.git" "$WORKING_TREES/LIBRARIES/$repo_kicad_symbols"
       else
           echo "updating $WORKING_TREES/LIBRARIES/$repo_kicad_symbols"
           cd "$WORKING_TREES/LIBRARIES/$repo_kicad_symbols"
           git pull
       fi
  done
}

update_utils()
{
    for repo_utils in kicad-library-utils; do

        if [ ! -e "$WORKING_TREES/LIBRARIES/$repo_utils" ]; then

            echo "installing $WORKING_TREES/LIBRARIES/$repo_utils"

            git clone "https://gitlab.com/kicad/libraries/kicad-library-utils.git" "$WORKING_TREES/LIBRARIES/$repo_utils"
        else
            echo "updating $WORKING_TREES/LIBRARIES/$repo_utils"
            cd "$WORKING_TREES/LIBRARIES/$repo_utils"

            git pull
        fi
    done
}

update_footprints()
{
    for repo_footprints in kicad-footprints; do
         #echo "repo_footprints:$repo_footprints"

        if [ ! -e "$WORKING_TREES/LIBRARIES/$repo_footprints" ]; then
            echo "installing $WORKING_TREES/LIBRARIES/$repo_footprints"
            git clone "https://gitlab.com/kicad/libraries/kicad-footprints.git" "$WORKING_TREES/LIBRARIES/$repo_footprints"
        else
            echo "updating $WORKING_TREES/LIBRARIES/$repo_footprints"
            cd "$WORKING_TREES/LIBRARIES/$repo_footprints"
            git pull
        fi
    done
}

update_templates()
{
    for repo_templates in kicad-templates; do
        if [ ! -e "$WORKING_TREES/$repo_templates" ]; then
            echo "installing $WORKING_TREES/$repo_templates"
            git clone "https://gitlab.com/kicad/libraries/kicad-templates.git" "$WORKING_TREES/$repo_templates"
        else
            echo "updating $WORKING_TREES/$repo_templates"
            cd "$WORKING_TREES/$repo_templates"
            git pull
        fi
    done
}

update_doc()
{
    for repo_doc in kicad-dev-docs; do
        if [ ! -e "$WORKING_TREES/$repo_doc" ]; then
            echo "installing $WORKING_TREES/$repo_doc"
git clone "https://gitlab.com/kicad/services/kicad-dev-docs.git" "$WORKING_TREES/$repo_doc"
        else
            echo "updating $WORKING_TREES/$repo_doc"
            cd "$WORKING_TREES/$repo_doc"
            git pull
        fi
    done
}

update_kicad-action-scripts()
{
    for repo_kicad_action_scripts in kicad-action-scripts; do

        if [ ! -e "$WORKING_TREES/PLUGINS/$repo_kicad_action_scripts" ]; then

            echo "installing $WORKING_TREES/PLUGINS/$repo_kicad_action_scripts"

            git clone "https://github.com/jsreynaud/kicad-action-scripts.git" "$WORKING_TREES/PLUGINS/$repo_kicad_action_scripts"
        else
            echo "updating $WORKING_TREES/PLUGINS/$repo_kicad_action_scripts"
            cd "$WORKING_TREES/PLUGINS/$repo_kicad_action_scripts"

            git pull
        fi
    done
}

update_plugins()
{
    for repo_plugins in InteractiveHtmlBom; do

        if [ ! -e "$WORKING_TREES/PLUGINS/$repo_plugins" ]; then

            echo "installing $WORKING_TREES/PLUGINS/$repo_plugins"

            git clone "https://github.com/openscopeproject/InteractiveHtmlBom.git" "$WORKING_TREES/PLUGINS/$repo_plugins"
        else
            echo "updating $WORKING_TREES/PLUGINS/$repo_plugins"
            cd "$WORKING_TREES/PLUGINS/$repo_plugins"

            git pull
        fi
    done
}

if [ $# -eq 1 -a "$1" == "--install-or-update" ]; then
    update_dirs
    update_symbols
    update_footprints
    update_3d
    update_templates
    update_doc
    update_plugins
    update_kicad_packages3D_generator
    update_utils
    update_kicad-action-scripts

    ##  T H I S  I S  W H E R E  M A G I C  H A P P E N S !

    echo "Placing KiCad Symbol & Footprint Library Tables = fp-lib-table and sym-lib-table to /home/$USER/$TABLE_DEST_DIR"

    head -n -1 $WORKING_TREES/LIBRARIES/kicad-footprints/fp-lib-table > /home/$USER/$TABLE_DEST_DIR/fp-lib-table;

    echo '  (lib (name MyCustomParts)(type KiCad)(uri "$(KISYSMINE)/MyCustomParts.pretty")(options "")(descr "My Custom Component Footprints")))' >> /home/$USER/$TABLE_DEST_DIR/fp-lib-table;

    head -n -1 $WORKING_TREES/LIBRARIES/kicad-symbols/sym-lib-table > /home/$USER/$TABLE_DEST_DIR/sym-lib-table

    echo '  (lib (name "MyCustomComponents")(type "KiCad")(uri "${KISYSMINE}/MyCustomLibrary/MyCustomComponents.kicad_sym")(options "")(descr "My Custom Schematic Symbols")))' >> /home/$USER/$TABLE_DEST_DIR/sym-lib-table;

    ##  T H I S  I S  W H E R E  M A G I C  H A P P E N S !

    echo "Done installing/updating KiCad Symbol and Footprint Library Tables"
    exit
fi

if [ $# -eq 1 -a "$1" == "--install-prerequisites" ]; then
    install_prerequisites
    exit
fi

usage
```
# make script executable
```bash
chmod +x su_pyrow-KiCad-6-Custom-Repos.sh
```
# run script
```bash
./su_pyrow-KiCad-6-Custom-Repos.sh
```
```bash
./su_pyrow-KiCad-6-Custom-Repos.sh --install-prerequisites
```
```bash
./su_pyrow-KiCad-6-Custom-Repos.sh --install-or-update
```
# the bleeding edge.
* This is how i keep my repos updated everyday and my custom 3D, parts and symbols are always there for every new project created!

ENJOY!
