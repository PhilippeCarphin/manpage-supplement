# This file is copied from https://gitlab.com/philippecarphin/orgmanpages

# Compiles every ${CMAKE_SOURCE_DIR}/${base_dir}/man/man<n>/*.org
# to ${CMAKE_BINARY_DIR}/${base_dir}/man/man<n>/%.<n>
# where <n> is a number from 1 to 8 corresponding to the standard
# manpage sections (see `man man`).
macro(org_md_manpages_add_man_target)
    # NOTE: The REQUIRED keyword only works with cmake 3.18+ which is why the
    # subsequent IF is needed.
    find_program(PANDOC_EXECUTABLE pandoc REQUIRED)
    if(NOT PANDOC_EXECUTABLE)
        message(FATAL_ERROR "pandoc was not found, required for generating manpages")
    endif()

    add_custom_target(man ALL)

    file(GLOB_RECURSE org_files
        RELATIVE ${CMAKE_SOURCE_DIR}
        share/man/*.org
        share/man/*.md
    )

    foreach(rel_file ${org_files})
        # rel_file = share/man/man1/my-command.org
        #    ├──>        file = ${CMAKE_SOURCE_DIR}/share/man/man1/my-command.org
        #    └──> target_file = ${CMAKE_BINARY_DIR}/share/man/man1/my-command.1
        get_filename_component(base ${rel_file} NAME)
        get_filename_component(rel_dir ${rel_file} DIRECTORY)

        set(source_dir  ${CMAKE_SOURCE_DIR}/${rel_dir})
        set(target_dir  ${CMAKE_BINARY_DIR}/${rel_dir})
        set(file ${CMAKE_SOURCE_DIR}/${rel_file})

        string(REGEX REPLACE ".*.(org\|md)$" "\\1" extension ${rel_file})
        if(${extension} STREQUAL md)
            set(heading_shift --shift-heading-level-by=-1)
        else()
            unset(heading_shift)
        endif()

        # Replace "my-command.(org|md)" with "my-command.<i>" based on the directory
        # containing the source file (share/man/man<i>).
        string(REGEX REPLACE ".*man([1-9]).*" "\\1" man_section_number "${rel_file}")
        string(REGEX REPLACE ".${extension}$" ".${man_section_number}" target_base ${base})

        set(target_file ${target_dir}/${target_base})

        add_custom_command(
            OUTPUT ${target_file} # ${CMAKE_BINARY_DIR}/share/man/man1/my-command.1
            DEPENDS ${rel_file} # share/man/man1/my-command.org
            # The '-s' is important
            COMMAND mkdir -p ${target_dir}
            COMMAND ${PANDOC_EXECUTABLE} -s ${heading_shift} -t man ${file} -o ${target_file}
        )
        add_custom_target(${target_base} DEPENDS ${target_file})

        add_dependencies(man ${target_base})
    endforeach()
    install(DIRECTORY ${CMAKE_BINARY_DIR}/share DESTINATION ${CMAKE_INSTALL_PREFIX})
endmacro()
