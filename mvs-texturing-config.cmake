cmake_minimum_required(VERSION 2.8)

project(Texturing)
include(ExternalProject)

set(RESEARCH "OFF" CACHE BOOL "Use the gco library for Multi-Label Optimization, which is licensed only for research purposes!")

if(RESEARCH)
    externalproject_add(gco
        PREFIX          gco
        URL             http://vision.csd.uwo.ca/code/gco-v3.0.zip
        URL_MD5         10e071892c38f076d30a91ca5351a847
        UPDATE_COMMAND  ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_LIST_DIR}/CMakeLists/gco.txt CMakeLists.txt
        SOURCE_DIR      ${CMAKE_CURRENT_LIST_DIR}/external/gco
        INSTALL_COMMAND ""
    )
    include_directories(${CMAKE_CURRENT_LIST_DIR}/external/gco)
    link_directories(${CMAKE_BINARY_DIR}/gco/src/gco-build)
endif()

externalproject_add(coldet
    PREFIX          coldet
    URL             http://downloads.sourceforge.net/project/coldet/coldet/2.0/coldet20.zip
    URL_MD5         37646a7dd046d9c81fca9d55346a108a
    UPDATE_COMMAND  ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_LIST_DIR}/CMakeLists/coldet.txt CMakeLists.txt
    SOURCE_DIR      ${CMAKE_CURRENT_LIST_DIR}/external/coldet
    INSTALL_COMMAND ""
)

#find_package eigen
externalproject_add(eigen
    PREFIX          eigen
    URL             http://bitbucket.org/eigen/eigen/get/3.2.1.tar.bz2
    URL_MD5         ece1dbf64a49753218ce951624f4c487
    SOURCE_DIR      ${CMAKE_CURRENT_LIST_DIR}/external/eigen
    CONFIGURE_COMMAND ""
    BUILD_COMMAND   ""
    INSTALL_COMMAND ""
)

externalproject_add(mve
    PREFIX          mve
    GIT_REPOSITORY  https://github.com/simonfuhrmann/mve.git
    SOURCE_DIR      ${CMAKE_CURRENT_LIST_DIR}/external/mve
    CONFIGURE_COMMAND ""
    BUILD_COMMAND   make #not platform independent
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND ""
)

include_directories(
    ${CMAKE_CURRENT_LIST_DIR}/external/coldet/src
    ${CMAKE_CURRENT_LIST_DIR}/external/mve/libs
    ${CMAKE_CURRENT_LIST_DIR}/external/eigen
)

link_directories(
    ${CMAKE_BINARY_DIR}/coldet/src/coldet-build
    ${CMAKE_CURRENT_LIST_DIR}/external/mve/libs/mve
    ${CMAKE_CURRENT_LIST_DIR}/external/mve/libs/util
)

include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11_FLAG)
CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X_FLAG)
if(COMPILER_SUPPORTS_CXX11_FLAG)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
    set(COMPILER_SUPPORTS_CXX11 TRUE)
elseif(COMPILER_SUPPORTS_CXX0X_FLAG)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
    set(COMPILER_SUPPORTS_CXX11 TRUE)
elseif(MSVC AND MSVC_VERSION GEQUAL 1800)
    set(COMPILER_SUPPORTS_CXX11 TRUE)
endif()

if(NOT COMPILER_SUPPORTS_CXX11)
    message(FATAL_ERROR "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
endif()

FIND_PACKAGE(OpenMP)
if(OPENMP_FOUND)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
endif()

if(RESEARCH)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DRESEARCH=1")
endif()

add_library(mvs_lib
  ${CMAKE_CURRENT_LIST_DIR}/Arguments.cpp
  ${CMAKE_CURRENT_LIST_DIR}/build_adjacency_graph.cpp
  ${CMAKE_CURRENT_LIST_DIR}/build_mrf.cpp
  ${CMAKE_CURRENT_LIST_DIR}/build_obj_model.cpp
  ${CMAKE_CURRENT_LIST_DIR}/generate_debug_colors.cpp
  ${CMAKE_CURRENT_LIST_DIR}/generate_debug_embeddings.cpp
  ${CMAKE_CURRENT_LIST_DIR}/generate_texture_patches.cpp
  ${CMAKE_CURRENT_LIST_DIR}/generate_texture_views.cpp
  ${CMAKE_CURRENT_LIST_DIR}/Histogram.cpp
  ${CMAKE_CURRENT_LIST_DIR}/load_and_prepare_mesh.cpp
  ${CMAKE_CURRENT_LIST_DIR}/Material.cpp
  ${CMAKE_CURRENT_LIST_DIR}/MaterialLib.cpp
  ${CMAKE_CURRENT_LIST_DIR}/MRF.cpp
  ${CMAKE_CURRENT_LIST_DIR}/ObjModel.cpp
  ${CMAKE_CURRENT_LIST_DIR}/partition_mesh.cpp
  ${CMAKE_CURRENT_LIST_DIR}/poisson_blending.cpp
  ${CMAKE_CURRENT_LIST_DIR}/RectangularBin.cpp
  ${CMAKE_CURRENT_LIST_DIR}/run_mrf_optimization.cpp
  ${CMAKE_CURRENT_LIST_DIR}/run_seam_leveling.cpp
  ${CMAKE_CURRENT_LIST_DIR}/TexturePatch.cpp
  ${CMAKE_CURRENT_LIST_DIR}/TextureView.cpp
  ${CMAKE_CURRENT_LIST_DIR}/Timer.cpp
  ${CMAKE_CURRENT_LIST_DIR}/Tri.cpp
  ${CMAKE_CURRENT_LIST_DIR}/UniGraph.cpp)


add_dependencies(${mvs_lib} coldet eigen mve)
if(RESEARCH)
  add_dependencies(${mvs_lib} coldet eigen mve gco)
else(RESEARCH)
  add_dependencies(${mvs_lib} coldet eigen mve )
endif()

find_package(PNG REQUIRED)
find_package(JPEG REQUIRED)
find_package(TIFF REQUIRED)

if(RESEARCH)
    message(
"
******************************************************************************
 Due to use of the -DRESEARCH=ON option, the resulting program is licensed
 for research purposes only. Please pay special attention to the gco license.
******************************************************************************
")
endif()
