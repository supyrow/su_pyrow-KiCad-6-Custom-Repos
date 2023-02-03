# add_lib-kicad67

Automate downloading and updating of `KiCad-6-dev` `KiCad-7` AKA `KiCad-nightly` Schematic symbols, PCB footprints, update the symbol and footprint tables WITH your custom libraries.

Download bleeding edge symbols and footprint tables and add your own custom library!

There are three reasons why you might want to run this script:

* You want local copies of bleeding edge symbols, and foorptints
* you have your own working library(symbols/footprints)
* sick of needing to add them to every single project you start.

updates Footprint and Symbol Table files so your custom libraries are reflected in KiCad globally.
# Note:
`I have been personally using this and previous derivatives of this script for over five years, I like to do things 'off the beaten path'  so if you are similar... go ahead with this.`


# installing
```
chmod +x kicad_addcustom_library.sh
```
```
./kicad_addcustom_library.sh
```

```
 ^ ^ ^  E D I T  T H I S  F I L E  ^ ^ ^
 usage:
      --clone-pull         

 (pulls from https://www.gitlab.com)
 into /crypt-storage1/electronics/KiCad/LIBRARIES 
```
# adjust variables to match your system
```
fplib_name="MYfootprintLib"
pretty_file="MYfootprintLib.pretty"
fpdescr="MYfootprintLib Description"

symlib_name="MYsymbolLib"
kicad_sym_file="MYsymbol.kicad_sym"
symdescr="MYsymbolLib Description"
```
# check all variables at the top of the script carefully, one more time!

# run kicad_addcustom_library.sh
```
./kicad_addcustom_library.sh --clone-pull
```
```
pulling from kicad-footprints
remote: Enumerating objects: 5, done.
remote: Counting objects: 100% (5/5), done.
remote: Compressing objects: 100% (2/2), done.
remote: Total 5 (delta 3), reused 4 (delta 3), pack-reused 0
Unpacking objects: 100% (5/5), 3.82 KiB | 130.00 KiB/s, done.
From https://gitlab.com/kicad/libraries/kicad-footprints
   fa95d28c6..d63c22e54  master     -> origin/master
Updating fa95d28c6..d63c22e54
Fast-forward
 Package_CSP.pretty/Analog_LFCSP-16-1EP_4x4mm_P0.65mm_EP2.35x2.35mm.kicad_mod  | 76 +++++++++++++++++++++++++++++++++
 .../Analog_LFCSP-16-1EP_4x4mm_P0.65mm_EP2.35x2.35mm_ThermalVias.kicad_mod     | 86 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 162 insertions(+)
 create mode 100644 Package_CSP.pretty/Analog_LFCSP-16-1EP_4x4mm_P0.65mm_EP2.35x2.35mm.kicad_mod
 create mode 100644 Package_CSP.pretty/Analog_LFCSP-16-1EP_4x4mm_P0.65mm_EP2.35x2.35mm_ThermalVias.kicad_mod
 
pulling from kicad-symbols
Already up to date.
 
Appending custom library to /home/su_pyrow/.config/kicad/fp-lib-table
Appending custom library to /home/su_pyrow/.config/kicad/sym-lib-table
```
# verify the new tables went to correct location

![kicad-config-dir](https://user-images.githubusercontent.com/25697854/216488413-1580b7a9-837f-421e-bc97-a4f219601954.png)
```
ls -l ~/.config/kicad
```
```
drwxrwxr-x 4 su_pyrow su_pyrow  4096 Jun 25  2021 5.99
drwxrwxr-x 4 su_pyrow su_pyrow  4096 Nov 20  2021 6.0
drwxrwxr-x 4 su_pyrow su_pyrow  4096 Nov 26 11:02 6.99
-rw-rw-r-- 1 su_pyrow su_pyrow 21007 Feb  2 14:42 fp-lib-table
-rw-rw-r-- 1 su_pyrow su_pyrow 31809 Feb  2 14:42 sym-lib-table
```
# if your directory structure looks like this, then you must symbolically link fp-lib-table and sym-lib-table to the version you use.

# add symbolic links to the KiCad version you use
```
mv ~/.config/kicad/7.0/fp-lib-table ~/.config/kicad/7.0/fp-lib-table-original
mv ~/.config/kicad/7.0/sym-lib-table ~/.config/kicad/7.0/sym-lib-table-original
ln -s ~/.config/kicad/fp-lib-table ~/.config/kicad/7.0/fp-lib-table
ln -s ~/.config/kicad/sym-lib-table ~/.config/kicad/7.0/sym-lib-table
```
```
cd ~/.config/kicad/7.0
```
```
ls -l
```
```
drwxrwxr-x 2 su_pyrow su_pyrow  4096 Feb  3 02:13 colors
lrwxrwxrwx 1 su_pyrow su_pyrow    41 Feb  3 02:20 fp-lib-table -> /home/su_pyrow/.config/kicad/fp-lib-table
-rw-r--r-- 1 su_pyrow su_pyrow 20719 Feb  3 02:14 fp-lib-table-original
lrwxrwxrwx 1 su_pyrow su_pyrow    42 Feb  3 02:20 sym-lib-table -> /home/su_pyrow/.config/kicad/sym-lib-table
-rw-r--r-- 1 su_pyrow su_pyrow 31699 Feb  3 02:14 sym-lib-table-original
```
# restart kicad and verify

![kicad-verify-footprint](https://user-images.githubusercontent.com/25697854/216496463-9a708e23-a4e1-49cb-b4a8-bdc7640373fd.png)
![kicad-verify-symbol](https://user-images.githubusercontent.com/25697854/216498910-c7b870db-b853-44a8-99be-9d5db758b676.png)



# enjoy
