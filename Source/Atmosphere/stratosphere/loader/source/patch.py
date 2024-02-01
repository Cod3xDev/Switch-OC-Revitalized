#!/usr/bin/env python3

"""
Copyright 2024 Cod3xDev

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
"""

import os

def file_replace_str(file_path, search_replace_list):
    assert file_path
    assert search_replace_list
    
    with open(file_path, "r") as file:
        content = file.read()

    for search, replace in search_replace_list:
        if search in content:
            content = content.replace(search, replace)
        else:
            assert replace in content, f"Pattern \"{search}\" not found"

    with open(file_path, "w") as file:
        file.write(content)

def main():
    dir_path = os.path.dirname(__file__)
    os.chdir(dir_path)
    os.system("git reset --hard")

    ldr_process_creation_path = os.path.join(dir_path, "ldr_process_creation.cpp")
    file_replace_str(ldr_process_creation_path, [
        (
            """#include "ldr_ro_manager.hpp"

namespace ams::ldr {""",
            """#include "ldr_ro_manager.hpp"
#include "oc/oc_loader.hpp"

namespace ams::ldr {"""
        ),
        (
            """NsoHeader g_nso_headers[Nso_Count];

Result ValidateProgramVersion(ncm::ProgramId program_id, u32 version) {""",
            """NsoHeader g_nso_headers[Nso_Count];

/* Pcv/Ptm check cache. */
bool g_is_pcv;
bool g_is_ptm;

Result ValidateProgramVersion(ncm::ProgramId program_id, u32 version) {"""
        ),
        (
            """R_UNLESS(meta->aci->program_id <= meta->acid->program_id_max, ldr::ResultInvalidProgramId());

/* Validate the kernel capabilities. */""",
            """R_UNLESS(meta->aci->program_id <= meta->acid->program_id_max, ldr::ResultInvalidProgramId());

/* Check if nca is pcv or ptm */
g_is_pcv = meta->aci->program_id == ncm::SystemProgramId::Pcv;
g_is_ptm = meta->aci->program_id == ncm::SystemProgramId::Ptm;

/* Validate the kernel capabilities. */"""
        ),
        (
            """LocateAndApplyIpsPatchesToModule(nso_header->module_id, map_address, nso_size);
}""",
            """LocateAndApplyIpsPatchesToModule(nso_header->module_id, map_address, nso_size);

/* Apply pcv and ptm patches. */
if (g_is_pcv)
    oc::pcv::Patch(map_address, nso_size);
if (g_is_ptm)
    oc::ptm::Patch(map_address, nso_size);
}"""
        )
    ])

    ldr_meta_path = os.path.join(dir_path, "ldr_meta.cpp")
    file_replace_str(ldr_meta_path, [
        (
            """Result ValidateAcidSignature(Meta *meta) {
/* Loader did not check signatures prior to 10.0.0. */""",
            """Result ValidateAcidSignature(Meta *meta) {
R_SUCCEED();
/* Loader did not check signatures prior to 10.0.0. */"""
        )
    ])

if __name__ == "__main__":
    main()
