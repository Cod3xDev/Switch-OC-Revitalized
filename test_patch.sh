#!/bin/bash

# Copyright 2024 Cod3xDev

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

fw_dir="/Volumes/RAMDISK/NX-15.0.0/"
tmp_dir="/Volumes/RAMDISK/"
repack_out_dir="/Volumes/RAMDISK/out/"
oc_test_dir="$HOME/Source/Switch-OC-Suite/Source/Atmosphere/stratosphere/loader/source/oc"
prodkeys="$HOME/.switch/prod.keys"
hactool_exe="$HOME/Source/hactool/hactool"
nx2elf_exe="$HOME/Source/nx2elf/nx2elf"
elf2nso_exe="$HOME/Source/switch-tools/elf2nso"
hacpack_exe="$HOME/Source/hacPack/hacpack"

should_remove_tmp="Y"
should_save_repack="Y"
option_Mariko_Erista="M"

echo -e "\nExtracting nca..."
out_pcv="${tmp_dir}pcv/"
out_ptm="${tmp_dir}ptm/"
mkdir -p "${out_pcv}"
mkdir -p "${out_ptm}"

for file_00 in "$fw_dir"/*.nca/00; do
    if [ -e "${file_00}" ]; then
        echo "Processing \"*.nca/00\" files..."
        find "$fw_dir" -type f -name "00" -exec sh -c 'DIR=$(dirname "{}"); FW_DIR=$(dirname "${DIR}"); mv "{}" "${FW_DIR}/00"; rm -r "${DIR}"; mv "${FW_DIR}/00" "${DIR}"' \;
    fi
    break
done

for nca_file in "$fw_dir"/*.nca; do
    file_size=$(wc -c "$nca_file" | awk '{print $1}')
    if [[ "$nca_file" == *".cnmt."* || $file_size -lt 16384 ]]; then
        continue
    fi

    titleid=$($hactool_exe -k "$prodkeys" --disablekeywarns -t nca "$nca_file" | grep 'Title ID')

    if [[ $titleid == *"010000000000001a"* ]]; then
        pcv_nca_name="$(basename "$nca_file")"
        echo "$pcv_nca_name (pcv) -> $out_pcv"
        $hactool_exe -k "$prodkeys" --disablekeywarns -t nca "$nca_file" --exefsdir "$out_pcv" 1> /dev/null
    fi

    if [[ $titleid == *"0100000000000010"* ]]; then
        ptm_nca_name="$(basename "$nca_file")"
        echo "$ptm_nca_name (ptm) -> $out_ptm"
        $hactool_exe -k "$prodkeys" --disablekeywarns -t nca "$nca_file" --exefsdir "$out_ptm" 1> /dev/null
    fi
done

echo -e "\nConverting nca to elf..."
$nx2elf_exe "${out_pcv}main" 1> /dev/null
$nx2elf_exe "${out_ptm}main" 1> /dev/null

echo -e "\nBuilding..."
make -C "$oc_test_dir" test 1> /dev/null

echo -e "\nPatching..."

if [ -z "$should_save_repack" ]; then
    read -p "Save and repack to nca (y/N)? " should_save_repack
fi
SAVE_OPT=" "

case $should_save_repack in
    Y|y ) SAVE_OPT="-s ";;
esac

"$oc_test_dir/test" pcv $SAVE_OPT "${out_pcv}main.elf"
"$oc_test_dir/test" ptm $SAVE_OPT "${out_ptm}main.elf"
make -C "$oc_test_dir" clean 1> /dev/null

if [ ! -z $SAVE_OPT ]; then
    case $should_save_repack in
        Y|y )
            patched_ext=".mariko"
            if [ -z "$option_Mariko_Erista" ]; then
                read -p "[M]ariko (Default) | [E]rista ? " option_Mariko_Erista
            fi

            case $option_Mariko_Erista in
                E|e ) patched_ext=".erista";;
            esac

            mkdir -p "${repack_out_dir}"
            cd "${tmp_dir}"

            echo -e "\nRepacking pcv to ${repack_out_dir}${pcv_nca_name}..."
            TMP="${out_pcv}temp/"
            mkdir -p "${TMP}"
            $elf2nso_exe "${out_pcv}main.elf${patched_ext}" "${TMP}main" 1> /dev/null
            cp "${out_pcv}main.npdm" "${TMP}main.npdm"
            $hacpack_exe -k "$prodkeys" -o "${TMP}nca" --type nca --ncatype program --titleid 010000000000001A --exefsdir "${TMP}" 1> /dev/null
            find "${TMP}nca" -name "*.nca" -exec mv {} "${repack_out_dir}${pcv_nca_name}" \;

            if [[ $patched_ext == ".mariko" ]]; then
                echo -e "\nRepacking ptm (Mariko Only) to ${repack_out_dir}${ptm_nca_name}..."
                TMP="${out_ptm}temp/"
                mkdir -p "${TMP}"
                $elf2nso_exe "${out_ptm}main.elf${patched_ext}" "${TMP}main" 1> /dev/null
                cp "${out_ptm}main.npdm" "${TMP}main.npdm"
                $hacpack_exe -k "$prodkeys" -o "${TMP}nca" --type nca --ncatype program --titleid 0100000000000010 --exefsdir "${TMP}" 1> /dev/null
                find "${TMP}nca" -name "*.nca" -exec mv {} "${repack_out_dir}${ptm_nca_name}" \;
            fi
        ;;
    esac
fi

if [ -z "$should_remove_tmp" ]; then
    read -p "Remove temp files (Y/n)? " should_remove_tmp
fi
case $should_remove_tmp in
    N|n )
        exit;;
esac

rm -fr "$out_pcv"
rm -fr "$out_ptm"
rm -fr "${tmp_dir}hacpack_backup"

echo -e "\nDone!"
