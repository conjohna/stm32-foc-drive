cmake_minimum_required(VERSION 3.22)

#
# This file is generated only once,
# and is not re-generated if converter is called multiple times.
#
# User is free to modify the file as much as necessary
#

# Setup compiler settings
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)


# Define the build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug")
endif()

# Set the project name
set(CMAKE_PROJECT_NAME firmware)

# Enable compile command to ease indexing with e.g. clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

# Core project settings
project(${CMAKE_PROJECT_NAME})
message("Build type: " ${CMAKE_BUILD_TYPE})

# Enable CMake support for ASM and C languages
enable_language(C ASM)

# Create an executable object type
add_executable(${CMAKE_PROJECT_NAME})

# Add STM32CubeMX generated sources
add_subdirectory(cmake/stm32cubemx)

# Link directories setup
target_link_directories(${CMAKE_PROJECT_NAME} PRIVATE
    # Add user defined library search paths
)

# Add sources to executable
target_sources(${CMAKE_PROJECT_NAME} PRIVATE
    # Add user sources here
)

# Add include paths
target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE
    # Add user defined include paths
)

# Add project symbols (macros)
target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE
    # Add user defined symbols
)

# Strict warnings for project code only (Core/ sources in this target).
# The ST HAL is compiled in the separate STM32_Drivers target and keeps -Wall,
# so its warnings don't bury ours. C only: the startup .s file is excluded.
target_compile_options(${CMAKE_PROJECT_NAME} PRIVATE
    $<$<COMPILE_LANGUAGE:C>:-Wextra -Wpedantic -Wconversion>
)

# Vendor headers (CMSIS, HAL) as system includes: GCC drops the matching -I
# from stm32cubemx and suppresses warnings inside these headers only.
# Core/Inc (our headers) is deliberately NOT listed, so it stays strict.
# The paths must be spelled exactly as cmake/stm32cubemx/CMakeLists.txt
# spells them (GCC matches -I and -isystem by string, not by resolved path).
# If CubeMX changes that spelling, the CMSIS warnings reappear in the build.
set(MX_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/cmake/stm32cubemx/../..)
target_include_directories(${CMAKE_PROJECT_NAME} SYSTEM PRIVATE
    ${MX_ROOT}/Drivers/STM32G4xx_HAL_Driver/Inc
    ${MX_ROOT}/Drivers/STM32G4xx_HAL_Driver/Inc/Legacy
    ${MX_ROOT}/Drivers/CMSIS/Device/ST/STM32G4xx/Include
    ${MX_ROOT}/Drivers/CMSIS/Include
)

# syscalls.c is CubeMX-generated newlib glue, overwritten on regeneration, so
# it isn't edited. Exempt it from conversion warnings only.
set_source_files_properties(Core/Src/syscalls.c PROPERTIES
    COMPILE_OPTIONS "-Wno-conversion;-Wno-sign-conversion"
)

# Remove wrong libob.a library dependency when using cpp files
list(REMOVE_ITEM CMAKE_C_IMPLICIT_LINK_LIBRARIES ob)

# Add linked libraries
target_link_libraries(${CMAKE_PROJECT_NAME}
    stm32cubemx

    # Add user defined libraries
)
