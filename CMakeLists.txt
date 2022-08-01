cmake_minimum_required(VERSION 3.0.0)

project(sandbox VERSION 0.1.0)

enable_testing()

add_executable(${PROJECT_NAME} hello.cpp)

add_test(NAME hello COMMAND ${PROJECT_NAME})
