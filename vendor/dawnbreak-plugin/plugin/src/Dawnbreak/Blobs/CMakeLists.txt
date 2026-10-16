qml_module(dawnbreak-blobs
    URI Dawnbreak.Blobs
    SOURCES
        blobgroup.cpp
        blobshape.cpp
        blobrect.cpp
        blobinvertedrect.cpp
        blobmaterial.cpp
    LIBRARIES
        Qt::Quick
)

qt_add_shaders(dawnbreak-blobs "blob_shaders"
    BATCHABLE OPTIMIZED NOHLSL NOMSL
    GLSL "300es,330"
    PREFIX "/"
    FILES
        shaders/blob.frag
        shaders/blob.vert
)
