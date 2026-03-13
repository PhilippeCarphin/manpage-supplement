cmake_minimum_required(VERSION 3.16)

project(listings-monitor)

if("${CMAKE_INSTALL_PREFIX}" STREQUAL "/usr/local")
    set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/localinstall CACHE FILEPATH "CMake Installation prefix for ${PROJECT_NAME}" FORCE)
    message(STATUS "Setting CMAKE_INSTALL_PREFIX to ${CMAKE_INSTALL_PREFIX}")
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/modules)

include(org_md_manpages)
org_md_manpages_add_man_target()

configure_file(bin/man-add.in.sh bin/man-add USE_SOURCE_PERMISSIONS @ONLY)
configure_file(bin/man-edit.in.sh bin/man-edit USE_SOURCE_PERMISSIONS @ONLY)
install(
    PROGRAMS
        ${CMAKE_BINARY_DIR}/bin/man-add
        ${CMAKE_BINARY_DIR}/bin/man-edit
    DESTINATION bin
)
install(PROGRAMS bin/man-super-edit.sh DESTINATION bin RENAME man-super-edit)
configure_file(share/bash-completion/completions/man-edit.in share/bash-completion/completions/man-edit USE_SOURCE_PERMISSIONS @ONLY)
install(FILES ${CMAKE_BINARY_DIR}/share/bash-completion/completions/man-edit DESTINATION share/bash-completion/completions)
