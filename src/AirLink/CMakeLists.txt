set(SOURCES
        AirLinkManager.cc
        )

find_package(Qt5 COMPONENTS Core REQUIRED)
find_package(Qt5 COMPONENTS Network REQUIRED)

add_library(AirLink ${SOURCES})
target_link_libraries(AirLink PUBLIC FactSystem)
target_link_libraries(AirLink PUBLIC Settings)
target_link_libraries(AirLink PUBLIC Qt5::Core)
target_link_libraries(AirLink PUBLIC Qt5::Network)
target_include_directories(AirLink PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
