# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(cvdnn_macos_library VERSION 0.0.1 LANGUAGES C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})
link_directories(${OpenCV_LIBRARY_DIRS})

# add_library(cvdnn_macos SHARED "cvdnn.cpp")
add_executable(test_cvdnn "test.c")
target_link_libraries(test_cvdnn ${OpenCV_LIBRARIES})
target_link_libraries(test_cvdnn "${CMAKE_CURRENT_SOURCE_DIR}/build/libcvdnn_macos.dylib")