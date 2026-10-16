qml_module(dawnbreak-models
    URI Dawnbreak.Models
    SOURCES
        filesystemmodel.cpp
        appdb.cpp
    LIBRARIES
        Qt::Gui
        Qt::Concurrent
        Qt::Sql
)
