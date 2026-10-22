cmake_minimum_required(VERSION 3.24)
project(goose_raylib VERSION 0.1.0 LANGUAGES C)

# Prefer the same release provided by the Nix shell. Outside Nix, fetch the
# exact 6.2 commit, with an archive hash rather than a moving branch/tag.
find_package(raylib 6.2 EXACT CONFIG QUIET)
if(NOT raylib_FOUND)
    include(FetchContent)
    set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
    set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)
    FetchContent_Declare(raylib
        URL https://codeload.github.com/raysan5/raylib/tar.gz/02566453880e06bec97f5b8160fa6fe1e98397ca
        URL_HASH SHA256=46d2b8ab1960480d197d84e6d01620c1d920603c2970169c8964d5e6f7a1085a
        DOWNLOAD_EXTRACT_TIMESTAMP TRUE)
    FetchContent_MakeAvailable(raylib)
endif()

add_library(goose_raylib STATIC src/raylib_adapter.c src/raylib_3d.c)
set_target_properties(goose_raylib PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_compile_features(goose_raylib PRIVATE c_std_11)
target_include_directories(goose_raylib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_link_libraries(goose_raylib PUBLIC raylib)
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(goose_raylib PRIVATE -Wall -Wextra -Werror)
endif()

include(CTest)
if(BUILD_TESTING AND PROJECT_IS_TOP_LEVEL)
    add_executable(test_3d_adapter tests/test_3d_adapter.c)
    target_link_libraries(test_3d_adapter PRIVATE goose_raylib)
    # Keep C assertions enabled in Release builds, too.
    if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
        target_compile_options(test_3d_adapter PRIVATE -UNDEBUG)
    endif()
    add_test(NAME 3d_adapter COMMAND test_3d_adapter)
endif()
