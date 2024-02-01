#!/usr/bin/env python3

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

import argparse
import os
import struct

def read_binary_file(file_path):
    with open(file_path, "rb") as file:
        file_size = struct.unpack("<I", file.read(4))[0]
        domain_key_value = parse_file_content(file, file_size)
    return domain_key_value

def parse_file_content(file, file_size):
    domain_key_value = {}
    
    while file.tell() != file_size:
        domain_key_len = struct.unpack("<I", file.read(4))[0]
        domain_key = file.read(domain_key_len).decode().rstrip('\x00')
        domain, key = domain_key.split("!")

        domain_key_value.setdefault(domain, {})

        val_types = {1: "str", 2: "u8", 3: "u32"}
        val_type = val_types.get(struct.unpack("<B", file.read(1))[0], "unknown")
        val_len = struct.unpack("<I", file.read(4))[0]
        val = file.read(val_len)

        if val_type == "str":
            value = '"' + val.decode(errors="replace").rstrip('\x00') + '"'
        else:
            val_dec = struct.unpack("<I", val)[0]
            value = f"0x{val_dec:X}"
            if val_type == "u32" and val_dec >= 10:
                val_dec_signed = struct.unpack("<i", val)[0]
                value += f" ; {val_dec_signed}"

        domain_key_value[domain][key] = f"{val_type}!{value}"

    return domain_key_value

def print_parsed_data(domain_key_value):
    for domain in sorted(domain_key_value.keys()):
        print(f"[{domain}]")
        for key in sorted(domain_key_value[domain].keys()):
            print(f"{key} = {domain_key_value[domain][key]}")
        print()

def main():
    parser = argparse.ArgumentParser(description="Parse binary file containing domain, key, and value information.")
    parser.add_argument("file_path", help="Path to the binary file.")
    args = parser.parse_args()

    domain_key_value = read_binary_file(args.file_path)
    print_parsed_data(domain_key_value)

if __name__ == "__main__":
    main()
