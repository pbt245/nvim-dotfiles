cmake_minimum_required(VERSION 3.14)

# Set the project name and version
project(MyProject VERSION 1.0 LANGUAGES CXX)

# Specify the C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Set default build type if not specified
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Choose the type of build." FORCE)
endif()

# Set compiler flags based on compiler ID
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    # Add compiler warnings
    add_compile_options(-Wall -Wextra -Werror -Wpedantic)
    
    # Add debug info for Debug builds
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g3 -O0")
    
    # Enable optimizations for Release builds
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")
elseif(MSVC)
    # MSVC flags
    add_compile_options(/W4 /WX)
    
    # Disable specific warnings that are too strict
    add_compile_options(/wd4100) # unreferenced formal parameter
endif()

# Generate compile_commands.json
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Find required packages
find_package(Threads REQUIRED)

# Add include directories
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/src
