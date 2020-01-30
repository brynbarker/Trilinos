###############################################################################
#
#              Standard ATDM Configuration of Trilnos
#
###############################################################################

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/utils/ATDMDevEnvUtils.cmake")

#
# A) Assert the right env vars are set, read in env vars, and set local
# defaults
#

IF (NOT "$ENV{ATDM_CONFIG_COMPLETED_ENV_SETUP}" STREQUAL "TRUE")
  MESSAGE(FATAL_ERROR
    "Error, env var ATDM_CONFIG_COMPLETED_ENV_SETUP not set to true!"
    "  Check load-env.sh output for error loading the env!"
    ) 
ENDIF()

ATDM_SET_ATDM_VAR_FROM_ENV_AND_DEFAULT(ENABLE_SPARC_SETTINGS OFF)
ATDM_SET_ATDM_VAR_FROM_ENV_AND_DEFAULT(USE_SPARC_TPL_FIND_SETTINGS
  ${ATDM_ENABLE_SPARC_SETTINGS})

ASSERT_DEFINED(ENV{ATDM_CONFIG_BUILD_NAME})

ASSERT_DEFINED(ENV{ATDM_CONFIG_BUILD_COUNT})

ASSERT_DEFINED(ENV{ATDM_CONFIG_SYSTEM_NAME})
ASSERT_DEFINED(ENV{ATDM_CONFIG_COMPILER})
ASSERT_DEFINED(ENV{ATDM_CONFIG_BUILD_TYPE})
ASSERT_DEFINED(ENV{ATDM_CONFIG_CUDA_RDC})
ASSERT_DEFINED(ENV{ATDM_CONFIG_COMPLEX})
ASSERT_DEFINED(ENV{ATDM_CONFIG_BLAS_LIBS})
ASSERT_DEFINED(ENV{ATDM_CONFIG_LAPACK_LIBS})
ASSERT_DEFINED(ENV{BOOST_ROOT})
ASSERT_DEFINED(ENV{HDF5_ROOT})
ASSERT_DEFINED(ENV{NETCDF_ROOT})

IF (ATDM_ENABLE_SPARC_SETTINGS)
  ASSERT_DEFINED(ENV{ATDM_CONFIG_BINUTILS_LIBS})
  ASSERT_DEFINED(ENV{METIS_ROOT})
  ASSERT_DEFINED(ENV{PARMETIS_ROOT})
  ASSERT_DEFINED(ENV{PNETCDF_ROOT})
  ASSERT_DEFINED(ENV{CGNS_ROOT})
  ASSERT_DEFINED(ENV{ATDM_CONFIG_SUPERLUDIST_INCLUDE_DIRS})
  ASSERT_DEFINED(ENV{ATDM_CONFIG_SUPERLUDIST_LIBS})
ENDIF()

ATDM_SET_ATDM_VAR_FROM_ENV_AND_DEFAULT(PARALLEL_COMPILE_JOBS_LIMIT "")
ATDM_SET_ATDM_VAR_FROM_ENV_AND_DEFAULT(PARALLEL_LINK_JOBS_LIMIT "")

ATDM_SET_ATDM_VAR_FROM_ENV_AND_DEFAULT(USE_OPENMP OFF)
ATDM_SET_ATDM_VAR_FROM_ENV_AND_DEFAULT(USE_PTHREADS OFF)
ATDM_SET_ATDM_VAR_FROM_ENV_AND_DEFAULT(USE_CUDA OFF)
ATDM_SET_ATDM_VAR_FROM_ENV_AND_DEFAULT(CUDA_RDC OFF)
ATDM_SET_ATDM_VAR_FROM_ENV_AND_DEFAULT(FPIC OFF)
ATDM_SET_ATDM_VAR_FROM_ENV_AND_DEFAULT(COMPLEX OFF)

IF (ATDM_USE_PTHREADS)
  MESSAGE(FATAL_ERROR "Error, the Kokkos Pthreads backend is no longer supported!"
    "  Please unset env var ATDM_CONFIG_USE_PTHREADS!")
ENDIF()

SET(ATDM_INST_SERIAL OFF)
SET(ATDM_KOKKOS_SERIAL OFF)
IF (ATDM_USE_OPENMP)
  SET(ATDM_NODE_TYPE OPENMP)
ELSEIF (ATDM_USE_CUDA)
  SET(ATDM_NODE_TYPE CUDA)
  SET(ATDM_INST_SERIAL ON)
ELSE()
  SET(ATDM_NODE_TYPE SERIAL)
  SET(ATDM_INST_SERIAL ON)
  SET(ATDM_KOKKOS_SERIAL ON)
ENDIF()

# ATDM_CMAKE_BUILD_TYPE and ATDM_BOUNDS_CHECK (Trilinos_ENABLE_DEBUG)

IF ("$ENV{ATDM_CONFIG_BUILD_TYPE}" STREQUAL "RELEASE-DEBUG")
  SET(ATDM_CMAKE_BUILD_TYPE RELEASE)
  SET(ATDM_BOUNDS_CHECK ON)
ELSEIF ("$ENV{ATDM_CONFIG_BUILD_TYPE}" STREQUAL "RELEASE")
  SET(ATDM_CMAKE_BUILD_TYPE RELEASE)
  SET(ATDM_BOUNDS_CHECK OFF)
ELSEIF ("$ENV{ATDM_CONFIG_BUILD_TYPE}" STREQUAL "DEBUG")
  SET(ATDM_CMAKE_BUILD_TYPE DEBUG)
  SET(ATDM_BOUNDS_CHECK ON)
ELSE()
  MESSAGE(FATAL_ERROR
    "Error, env var ATDM_CONFIG_BUILD_TYPE=$ENV{ATDM_CONFIG_BUILD_TYPE} is"
    " set to an illegal value!  Only the values 'RELEASE-DEBUG', 'RELEASE',"
    " and 'DEBUG' are allowed!"
    )
ENDIF()

ATDM_SET_CACHE(Trilinos_ENABLE_DEBUG "${ATDM_BOUNDS_CHECK}" CACHE BOOL)

ATDM_SET_ATDM_VAR_FROM_ENV_AND_DEFAULT(EXTRA_LINK_FLAGS "")
ATDM_SET_ATDM_VAR_FROM_ENV_AND_DEFAULT(CMAKE_CXX_USE_RESPONSE_FILE_FOR_OBJECTS "")
ATDM_SET_ATDM_VAR_FROM_ENV_AND_DEFAULT(SHARED_LIBS OFF)
ATDM_SET_ATDM_VAR_FROM_ENV_AND_DEFAULT(PT_PACKAGES OFF)
ATDM_SET_ATDM_VAR_FROM_ENV_AND_DEFAULT(CMAKE_BUILD_WITH_INSTALL_RPATH OFF)
ATDM_SET_ATDM_VAR_FROM_ENV_AND_DEFAULT(CMAKE_SKIP_INSTALL_RPATH OFF)

ATDM_SET_ATDM_VAR_FROM_ENV_AND_DEFAULT(USE_HWLOC OFF)
iF (ATDM_USE_HWLOC AND "$ENV{ATDM_CONFIG_HWLOC_LIBS}" STREQUAL "")
  MESSAGE(FATAL_ERROR
    "Error, env var USE_HWLOC=$ATDM_USE_HWLOC but env var"
    " HWLOC_LIBS is not set!")
ENDIF()

# If ATDM_CONFIG_KOKKOS_ARCH is set to empty, don't append the KOKKOS_ARCH
# name.  This makes sense for platforms like 'rhel'" that may involve
# different CPU architectures where it would not make sense to try to set a
# specific KOKKOS_ARCH value.
SET(ATDM_CONFIG_KOKKOS_ARCH_JOB_NAME_KEYS $ENV{ATDM_CONFIG_KOKKOS_ARCH})
IF(ATDM_CONFIG_KOKKOS_ARCH_JOB_NAME_KEYS)
  STRING(TOUPPER ${ATDM_CONFIG_KOKKOS_ARCH_JOB_NAME_KEYS}
    ATDM_CONFIG_KOKKOS_ARCH_JOB_NAME_KEYS)
  STRING(REPLACE , _ ATDM_CONFIG_KOKKOS_ARCH_JOB_NAME_KEYS
    ${ATDM_CONFIG_KOKKOS_ARCH_JOB_NAME_KEYS})
  SET(ATDM_CONFIG_KOKKOS_ARCH_JOB_NAME_KEYS
    _${ATDM_CONFIG_KOKKOS_ARCH_JOB_NAME_KEYS})
ENDIF()

# To be used in Tweaks.cmake files logic
SET(ATDM_COMPILER "$(ENV{ATDM_CONFIG_COMPILER}")
SET(ATDM_KOKKOS_ARCH_JOB_NAME_KEYS ${ATDM_CONFIG_KOKKOS_ARCH_JOB_NAME_KEYS})

SET(ATDM_BUILD_NAME_KEYS_STR
  "$ENV{ATDM_CONFIG_COMPILER}_$ENV{ATDM_CONFIG_BUILD_TYPE}_${ATDM_NODE_TYPE}${ATDM_CONFIG_KOKKOS_ARCH_JOB_NAME_KEYS}")
PRINT_VAR(ATDM_BUILD_NAME_KEYS_STR)

ATDM_SET_ATDM_VAR_FROM_ENV_AND_DEFAULT(MPI_EXEC mpiexec)
ATDM_SET_ATDM_VAR_FROM_ENV_AND_DEFAULT(MPI_EXEC_NUMPROCS_FLAG -np)

#
# B) Look for tweaks file(s) for this build and load the file(s) if it exists
# 

SET(ATDM_DEFAULT_TWEAK_FILES
  "${CMAKE_CURRENT_LIST_DIR}/$ENV{ATDM_CONFIG_SYSTEM_NAME}/tweaks/${ATDM_BUILD_NAME_KEYS_STR}.cmake"
  "${CMAKE_CURRENT_LIST_DIR}/$ENV{ATDM_CONFIG_SYSTEM_NAME}/tweaks/Tweaks.cmake"
  )

SET(ATDM_TWEAKS_FILES_DEFAULT "")
FOREACH(ATDM_DEFAULT_TWEAK_FILE ${ATDM_DEFAULT_TWEAK_FILES})
  IF (EXISTS "${ATDM_DEFAULT_TWEAK_FILE}")
    LIST(APPEND ATDM_TWEAKS_FILES_DEFAULT "${ATDM_DEFAULT_TWEAK_FILE}")
  ENDIF()
ENDFOREACH()

ADVANCED_SET(ATDM_TWEAKS_FILES "${ATDM_TWEAKS_FILES_DEFAULT}"
  CACHE FILEPATH
  "Extra *.cmake file(s) to include to define tweaks for this ATDM build ${ATDM_BUILD_NAME_KEYS_STR}"
  )
PRINT_VAR(ATDM_TWEAKS_FILES)

FOREACH(ATDM_TWEAKS_FILE ${ATDM_TWEAKS_FILES})
  MESSAGE("-- " "Including ATDM build tweaks file ${ATDM_TWEAKS_FILE} ...")
  TRIBITS_TRACE_FILE_PROCESSING(PROJECT  INCLUDE "${ATDM_TWEAKS_FILE}")
  INCLUDE("${ATDM_TWEAKS_FILE}")
ENDFOREACH()

#
# C) Set the compilers
#

# All ATDM builds of Trilinos are MPI builds!
ATDM_SET_ENABLE(TPL_ENABLE_MPI ON)

# Assert compiler env vars are set
ASSERT_DEFINED(ENV{MPICC})
ASSERT_DEFINED(ENV{MPICXX})
ASSERT_DEFINED(ENV{MPIF90})

# Set compilers
ATDM_SET_CACHE(CMAKE_C_COMPILER "$ENV{MPICC}" CACHE FILEPATH)
ATDM_SET_CACHE(CMAKE_CXX_COMPILER "$ENV{MPICXX}" CACHE FILEPATH)
ATDM_SET_CACHE(CMAKE_Fortran_COMPILER "$ENV{MPIF90}" CACHE FILEPATH)
IF (ATDM_ENABLE_SPARC_SETTINGS  OR  ATDM_PT_PACKAGES)
  ATDM_SET_ENABLE(Trilinos_ENABLE_Fortran ON)
ELSE()
  ATDM_SET_ENABLE(Trilinos_ENABLE_Fortran OFF)
ENDIF()

#
# D) Set up basic compiler flags, link flags etc.
#

ATDM_SET_CACHE(BUILD_SHARED_LIBS "${ATDM_SHARED_LIBS}" CACHE BOOL)
ATDM_SET_CACHE(CMAKE_BUILD_TYPE "${ATDM_CMAKE_BUILD_TYPE}" CACHE STRING)

SET(EXTRA_EXTRA_CXX_FLAGS)
# RDC
IF (ATDM_USE_CUDA AND ATDM_CUDA_RDC)
  SET(EXTRA_EXTRA_CXX_FLAGS "${EXTRA_EXTRA_CXX_FLAGS} --remove-duplicate-link-files")
  # To get around defect in TriBITS where it will add duplicate libs if a
  # downstream package add dependencies on both a subpackage and its parent
  # package.
ENDIF()
# FPIC
IF (ATDM_FPIC)
  SET(EXTRA_EXTRA_CXX_FLAGS "${EXTRA_EXTRA_CXX_FLAGS} -fPIC")
  # To get around defect in TriBITS where it will add duplicate libs if a
  # downstream package add dependencies on both a subpackage and its parent
  # package.
ENDIF()

ATDM_SET_CACHE(CMAKE_C_FLAGS
  "$ENV{ATDM_CONFIG_C_FLAGS} $ENV{EXTRA_C_FLAGS}" CACHE STRING)
ATDM_SET_CACHE(CMAKE_CXX_FLAGS
  "$ENV{ATDM_CONFIG_CXX_FLAGS}${EXTRA_EXTRA_CXX_FLAGS} $ENV{EXTRA_CXX_FLAGS}" CACHE STRING)
ATDM_SET_CACHE(CMAKE_Fortran_FLAGS
  "$ENV{ATDM_CONFIG_Fortran_FLAGS} $ENV{EXTRA_Fortran_FLAGS}" CACHE STRING)
# NOTE: That above "EXTRA_<LANG>_FLAGS" env vars are left in for backward
# compatibility with the EMPIRE configuration and are not directly set in any
# offical ATDM Trilinos configuration setup.  Only the
# "ATDM_CONFIG_<LANG>_FLAGS" env vars are set.

IF (NOT "$ENV{ATDM_CONFIG_OPENMP_FORTRAN_FLAGS}" STREQUAL "")
  ATDM_SET_CACHE(OpenMP_Fortran_FLAGS "$ENV{ATDM_CONFIG_OPENMP_FORTRAN_FLAGS}"
    CACHE STRING)
  ATDM_SET_CACHE(OpenMP_Fortran_LIB_NAMES "$ENV{ATDM_CONFIG_OPENMP_FORTRAN_LIB_NAMES}"
   CACHE STRING)
  ATDM_SET_CACHE(OpenMP_gomp_LIBRARY "$ENV{ATDM_CONFIG_OPENMP_GOMP_LIBRARY}"
   CACHE STRING)
ENDIF()

#
# E) Set up other misc options
#

IF (ATDM_PT_PACKAGES)
  ATDM_SET_ENABLE(Trilinos_ENABLE_SECONDARY_TESTED_CODE OFF)
ELSE()
  # Currently, EMPIRE configures of Trilinos have this enabled by default.  But
  # really we should elevate every subpackage that ATDM uses to Primary Tested.
  # That is the right solution.
  ATDM_SET_ENABLE(Trilinos_ENABLE_SECONDARY_TESTED_CODE ON)
ENDIF()

# Other various options
ATDM_SET_CACHE(CTEST_BUILD_FLAGS "-j$ENV{ATDM_CONFIG_BUILD_COUNT}" CACHE STRING)
ATDM_SET_CACHE(Trilinos_EXTRA_LINK_FLAGS "${ATDM_EXTRA_LINK_FLAGS}" CACHE STRING)
ATDM_SET_CACHE(CMAKE_JOB_POOL_LINK "${ATDM_CMAKE_JOB_POOL_LINK}" CACHE STRING)
ATDM_SET_CACHE(Trilinos_PARALLEL_COMPILE_JOBS_LIMIT "${ATDM_PARALLEL_COMPILE_JOBS_LIMIT}"
  CACHE STRING)
ATDM_SET_CACHE(Trilinos_PARALLEL_LINK_JOBS_LIMIT "${ATDM_PARALLEL_LINK_JOBS_LIMIT}"
  CACHE STRING)
ATDM_SET_CACHE(CTEST_PARALLEL_LEVEL "$ENV{ATDM_CONFIG_CTEST_PARALLEL_LEVEL}"
  CACHE STRING)
IF (NOT ATDM_CMAKE_CXX_USE_RESPONSE_FILE_FOR_OBJECTS STREQUAL "")
  ATDM_SET_CACHE(CXX_USE_RESPONSE_FILE_FOR_OBJECTS
    ${ATDM_CMAKE_CXX_USE_RESPONSE_FILE_FOR_OBJECTS} CACHE BOOL)
ENDIF()
ATDM_SET_CACHE(CMAKE_SKIP_RULE_DEPENDENCY ON CACHE BOOL)
ATDM_SET_CACHE(CMAKE_BUILD_WITH_INSTALL_RPATH ${ATDM_CMAKE_BUILD_WITH_INSTALL_RPATH}
  CACHE BOOL)
ATDM_SET_CACHE_FORCE(CMAKE_SKIP_INSTALL_RPATH ${ATDM_CMAKE_SKIP_INSTALL_RPATH} CACHE BOOL)
# NOTE: Above we need to FORCE since CMake sets CMAKE_SKIP_INSTALL_RPATH in
# cache as 'NO' by default!  (CMake almost never does this for a cache var.)
ATDM_SET_CACHE(Trilinos_MAKE_INSTALL_WORLD_READABLE ON CACHE BOOL)
ATDM_SET_CACHE(CMAKE_VERBOSE_MAKEFILE OFF CACHE BOOL)
ATDM_SET_CACHE(TPL_FIND_SHARED_LIBS ${ATDM_SHARED_LIBS} CACHE BOOL)
ATDM_SET_CACHE(MPI_EXEC ${ATDM_MPI_EXEC} CACHE FILEPATH)
ATDM_SET_CACHE(MPI_EXEC_PRE_NUMPROCS_FLAGS "$ENV{ATDM_CONFIG_MPI_PRE_FLAGS}" CACHE STRING)
ATDM_SET_CACHE(MPI_EXEC_NUMPROCS_FLAG "${ATDM_MPI_EXEC_NUMPROCS_FLAG}" CACHE STRING)
ATDM_SET_CACHE(MPI_EXEC_POST_NUMPROCS_FLAGS "$ENV{ATDM_CONFIG_MPI_POST_FLAGS}"
  CACHE STRING)
ATDM_SET_CACHE(Trilinos_VERBOSE_CONFIGURE OFF CACHE BOOL)
ATDM_SET_CACHE(Trilinos_ENABLE_EXPLICIT_INSTANTIATION ON CACHE BOOL)
ATDM_SET_CACHE(Trilinos_ENABLE_INSTALL_CMAKE_CONFIG_FILES ON CACHE BOOL)
ATDM_SET_CACHE(Trilinos_ENABLE_DEVELOPMENT_MODE OFF CACHE BOOL)
ATDM_SET_CACHE(Trilinos_ASSERT_MISSING_PACKAGES ON CACHE BOOL)
ATDM_SET_CACHE(Trilinos_ENABLE_OpenMP "${ATDM_USE_OPENMP}" CACHE BOOL)
ATDM_SET_CACHE(Trilinos_ENABLE_COMPLEX "${ATDM_COMPLEX}" CACHE BOOL)
ATDM_SET_CACHE(Kokkos_ENABLE_OpenMP "${ATDM_USE_OPENMP}" CACHE BOOL)
ATDM_SET_CACHE(Kokkos_ENABLE_Pthread "${ATDM_USE_PTHREADS}" CACHE BOOL)
#ATDM_SET_CACHE(Kokkos_ENABLE_Cuda_UVM "$ENV{ATDM_CONFIG_Kokkos_ENABLE_Cuda_UVM}" CACHE BOOL)
ATDM_SET_CACHE(Kokkos_ENABLE_Cuda_UVM "${ATDM_USE_CUDA}" CACHE BOOL)
ATDM_SET_CACHE(Kokkos_ENABLE_Cuda_Relocatable_Device_Code "$ENV{ATDM_CONFIG_CUDA_RDC}"
  CACHE BOOL)
ATDM_SET_CACHE(Kokkos_ENABLE_Serial "$ENV{ATDM_CONFIG_Kokkos_ENABLE_Serial}" CACHE BOOL)
ATDM_SET_CACHE(Kokkos_ENABLE_Cuda "${ATDM_USE_CUDA}" CACHE BOOL)
ATDM_SET_CACHE(Kokkos_ENABLE_Deprecated_Code "$ENV{ATDM_CONFIG_Kokkos_ENABLE_Deprecated_Code}" CACHE BOOL)
ATDM_SET_CACHE(Kokkos_ENABLE_CXX11_DISPATCH_LAMBDA ON CACHE BOOL)
ATDM_SET_CACHE(Kokkos_ENABLE_Cuda_Lambda "${ATDM_USE_CUDA}" CACHE BOOL)
ATDM_SET_CACHE(Kokkos_ENABLE_Debug_Bounds_Check "${Trilinos_ENABLE_DEBUG}" CACHE BOOL)
ATDM_SET_CACHE(KOKKOS_ENABLE_DEBUG "${Trilinos_ENABLE_DEBUG}" CACHE BOOL)
ATDM_SET_CACHE(KOKKOS_ARCH "$ENV{ATDM_CONFIG_KOKKOS_ARCH}" CACHE STRING)
ATDM_SET_CACHE(EpetraExt_ENABLE_HDF5 OFF CACHE BOOL)
ATDM_SET_CACHE(Panzer_ENABLE_FADTYPE "Sacado::Fad::DFad<RealType>" CACHE STRING)
ATDM_SET_CACHE(Phalanx_KOKKOS_DEVICE_TYPE "${ATDM_NODE_TYPE}" CACHE STRING)
ATDM_SET_CACHE(Phalanx_SHOW_DEPRECATED_WARNINGS OFF CACHE BOOL)
ATDM_SET_CACHE(Tpetra_INST_CUDA "${ATDM_USE_CUDA}" CACHE BOOL)
ATDM_SET_CACHE(Tpetra_INST_SERIAL "${ATDM_INST_SERIAL}" CACHE BOOL)
ATDM_SET_CACHE(Tpetra_INST_INT_INT OFF CACHE BOOL)
ATDM_SET_CACHE(Xpetra_ENABLE_Epetra OFF CACHE BOOL)
ATDM_SET_CACHE(Amesos2_ENABLE_Epetra OFF CACHE BOOL)
ATDM_SET_CACHE(MueLu_ENABLE_Kokkos_Refactor_Use_By_Default ON CACHE BOOL)
ATDM_SET_CACHE(MueLu_ENABLE_Epetra OFF CACHE BOOL)
ATDM_SET_CACHE(Piro_ENABLE_MueLu OFF CACHE BOOL)
IF (ATDM_USE_CUDA)
  ATDM_SET_CACHE(Sacado_ENABLE_HIERARCHICAL_DFAD ON CACHE BOOL)
ENDIF()
ATDM_SET_CACHE(DART_TESTING_TIMEOUT 600 CACHE STRING)
IF (ATDM_ENABLE_SPARC_SETTINGS)
  ATDM_SET_CACHE(Zoltan_ENABLE_ULLONG_IDS ON CACHE BOOL)
  ATDM_SET_CACHE(Anasazi_ENABLE_RBGen ON CACHE BOOL)
ENDIF()

#
# F) TPL locations and enables
#
# Since this is a special ATDM configuration of Trilinos, it makes sense to go
# ahead and enable all of the TPLs by default that are used by the ATDM
# applications.
#

IF (ATDM_SHARED_LIBS)
  SET(ATDM_TPL_LIB_EXT "so")
ELSE()
  SET(ATDM_TPL_LIB_EXT "a")
ENDIF()

# CUDA
ATDM_SET_ENABLE(TPL_ENABLE_CUDA "${ATDM_USE_CUDA}")

# CUSPARSE
ATDM_SET_ENABLE(TPL_ENABLE_CUSPARSE "${ATDM_USE_CUDA}")

# Pthread
ATDM_SET_ENABLE(TPL_ENABLE_Pthread OFF)

# BinUtils
ATDM_SET_ENABLE(TPL_ENABLE_BinUtils ${ATDM_ENABLE_SPARC_SETTINGS})
ATDM_SET_ENABLE(TPL_BinUtils_LIBRARIES "$ENV{ATDM_CONFIG_BINUTILS_LIBS}")

# BLAS
ATDM_SET_ENABLE(TPL_ENABLE_BLAS ON)
ATDM_SET_CACHE(TPL_BLAS_LIBRARIES "$ENV{ATDM_CONFIG_BLAS_LIBS}" CACHE FILEPATH)

# Boost
ATDM_SET_ENABLE(TPL_ENABLE_Boost ON)
ATDM_SET_CACHE(Boost_INCLUDE_DIRS "$ENV{BOOST_ROOT}/include" CACHE FILEPATH)
ATDM_SET_CACHE(TPL_Boost_LIBRARIES
   "$ENV{BOOST_ROOT}/lib/libboost_program_options.${ATDM_TPL_LIB_EXT};$ENV{BOOST_ROOT}/lib/libboost_system.${ATDM_TPL_LIB_EXT}"
  CACHE FILEPATH)

# BoostLib
ATDM_SET_ENABLE(TPL_ENABLE_BoostLib ON)
ATDM_SET_CACHE(BoostLib_INCLUDE_DIRS "$ENV{BOOST_ROOT}/include" CACHE FILEPATH)
IF (NOT "$ENV{ATDM_CONFIG_BOOST_LIBS}" STREQUAL "")
  ATDM_SET_CACHE(TPL_BoostLib_LIBRARIES "$ENV{ATDM_CONFIG_BOOST_LIBS}" CACHE FILEPATH)
ELSE()
  ATDM_SET_CACHE(TPL_BoostLib_LIBRARIES
    "$ENV{BOOST_ROOT}/lib/libboost_program_options.${ATDM_TPL_LIB_EXT};$ENV{BOOST_ROOT}/lib/libboost_system.${ATDM_TPL_LIB_EXT}"
    CACHE FILEPATH)
ENDIF()

# METIS
ATDM_SET_ENABLE(TPL_ENABLE_METIS ${ATDM_ENABLE_SPARC_SETTINGS})
ATDM_SET_CACHE(METIS_INCLUDE_DIRS "$ENV{METIS_ROOT}/include" CACHE FILEPATH)
ATDM_SET_CACHE(METIS_LIBRARY_DIRS "$ENV{METIS_ROOT}/lib" CACHE FILEPATH)
ATDM_SET_CACHE(TPL_METIS_LIBRARIES "$ENV{ATDM_CONFIG_METIS_LIBS}" CACHE FILEPATH)

# ParMETIS
ATDM_SET_ENABLE(TPL_ENABLE_ParMETIS ${ATDM_ENABLE_SPARC_SETTINGS})
ATDM_SET_CACHE(ParMETIS_INCLUDE_DIRS "$ENV{PARMETIS_ROOT}/include" CACHE FILEPATH)
ATDM_SET_CACHE(ParMETIS_LIBRARY_DIRS "$ENV{PARMETIS_ROOT}/lib" CACHE FILEPATH)
ATDM_SET_CACHE(TPL_ParMETIS_LIBRARIES "$ENV{ATDM_CONFIG_PARMETIS_LIBS}" CACHE FILEPATH)

# HWLOC
ATDM_SET_ENABLE(TPL_ENABLE_HWLOC ${ATDM_USE_HWLOC})
ATDM_SET_CACHE(TPL_HWLOC_LIBRARIES "$ENV{ATDM_CONFIG_HWLOC_LIBS}" CACHE FILEPATH)

# LAPACK
ATDM_SET_ENABLE(TPL_ENABLE_LAPACK ON)
ATDM_SET_CACHE(TPL_LAPACK_LIBRARIES "$ENV{ATDM_CONFIG_LAPACK_LIBS}" CACHE FILEPATH)

# CGNS
ATDM_SET_ENABLE(TPL_ENABLE_CGNS ${ATDM_ENABLE_SPARC_SETTINGS})
ATDM_SET_CACHE(CGNS_INCLUDE_DIRS "$ENV{CGNS_ROOT}/include" CACHE FILEPATH)
ATDM_SET_CACHE(CGNS_LIBRARY_DIRS "$ENV{CGNS_ROOT}/lib" CACHE FILEPATH)
ATDM_SET_CACHE(TPL_CGNS_LIBRARIES "$ENV{ATDM_CONFIG_CGNS_LIBS}" CACHE FILEPATH)

# HDF5
ATDM_SET_ENABLE(TPL_ENABLE_HDF5 ON)
ATDM_SET_CACHE(HDF5_INCLUDE_DIRS "$ENV{HDF5_ROOT}/include" CACHE FILEPATH)
IF (NOT "$ENV{ATDM_CONFIG_HDF5_LIBS}" STREQUAL "")
  ATDM_SET_CACHE(TPL_HDF5_LIBRARIES "$ENV{ATDM_CONFIG_HDF5_LIBS}" CACHE FILEPATH)
ELSE()
  ASSERT_DEFINED(ENV{ZLIB_ROOT})
  ATDM_SET_CACHE(TPL_HDF5_LIBRARIES "$ENV{HDF5_ROOT}/lib/libhdf5_hl.${ATDM_TPL_LIB_EXT};$ENV{HDF5_ROOT}/lib/libhdf5.${ATDM_TPL_LIB_EXT};$ENV{ZLIB_ROOT}/lib/libz.${ATDM_TPL_LIB_EXT};-ldl" CACHE FILEPATH)
ENDIF()

# Netcdf
ATDM_SET_ENABLE(TPL_ENABLE_Netcdf ON)
IF (ATDM_USE_SPARC_TPL_FIND_SETTINGS)
  # SPARC ATDM Trilinos configuration has SEACAS-customized FindNetCDF.cmake
  # module recurrsively find PNetCDF and HDF5 internally!
  ATDM_SET_CACHE(HDF5_ROOT "$ENV{HDF5_ROOT}" CACHE FILEPATH)
  ATDM_SET_CACHE(PNetCDF_ROOT "$ENV{PNETCDF_ROOT}" CACHE FILEPATH)
  ATDM_SET_CACHE(NetCDF_ROOT "$ENV{NETCDF_ROOT}" CACHE FILEPATH)
ELSE()
  ATDM_SET_CACHE(Netcdf_INCLUDE_DIRS "$ENV{NETCDF_ROOT}/include" CACHE FILEPATH)
  IF (NOT "$ENV{ATDM_CONFIG_NETCDF_LIBS}" STREQUAL "")
    ATDM_SET_CACHE(TPL_Netcdf_LIBRARIES "$ENV{ATDM_CONFIG_NETCDF_LIBS}" CACHE FILEPATH)
  ELSE()
    ASSERT_DEFINED(ENV{ZLIB_ROOT})
    ATDM_SET_CACHE(TPL_Netcdf_LIBRARIES "${TPL_BoostLib_LIBRARIES};$ENV{NETCDF_ROOT}/lib/libnetcdf.${ATDM_TPL_LIB_EXT};$ENV{NETCDF_ROOT}/lib/libpnetcdf.a;$ENV{HDF5_ROOT}/lib/libhdf5_hl.${ATDM_TPL_LIB_EXT};$ENV{HDF5_ROOT}/lib/libhdf5.${ATDM_TPL_LIB_EXT};$ENV{ZLIB_ROOT}/lib/libz.${ATDM_TPL_LIB_EXT};-ldl;-lcurl" CACHE FILEPATH)
  ENDIF()
ENDIF()

# SuperLUDist
ATDM_SET_ENABLE(TPL_ENABLE_SuperLUDist ${ATDM_ENABLE_SPARC_SETTINGS})
ATDM_SET_CACHE(SuperLUDist_INCLUDE_DIRS "$ENV{ATDM_CONFIG_SUPERLUDIST_INCLUDE_DIRS}" CACHE FILEPATH)
ATDM_SET_CACHE(TPL_SuperLUDist_LIBRARIES "$ENV{ATDM_CONFIG_SUPERLUDIST_LIBS}" CACHE FILEPATH)

# DLlib
ATDM_SET_CACHE(TPL_DLlib_LIBRARIES "-ldl" CACHE FILEPATH)
# NOTE: Not clear why you need this since the TPL DLlib is not explicilty
# enabled anywhere in the EM-Plasma/BuildScripts files.xsxs

# Don't have stuff for Matio and some SEACAS subpackage has required
# dependency on this
ATDM_SET_ENABLE(TPL_ENABLE_Matio OFF)

#
# G) ATDM env config install hooks
#
# Install just enough to allow loading the exact matching env and nothing
# else!
#

IF (COMMAND INSTALL AND NOT "${CMAKE_INSTALL_PREFIX}" STREQUAL "")

  IF (NOT "$ENV{ATDM_CONFIG_TRIL_CMAKE_INSTALL_PREFIX}" STREQUAL "")
    ATDM_SET_CACHE_FORCE(CMAKE_INSTALL_PREFIX
      $ENV{ATDM_CONFIG_TRIL_CMAKE_INSTALL_PREFIX} CACHE FILEPATH )
  ENDIF()

  ATDM_SET_CACHE(Trilinos_INSTALL_PBP_RUNNER "$ENV{ATDM_CONFIG_INSTALL_PBP_RUNNER}"
    CACHE FILEPATH)

  SET(ATDM_CONFIG_SCRIPTS_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/share/atdm-trilinos)

  INSTALL( FILES ${CMAKE_CURRENT_LIST_DIR}/load-env.sh
    DESTINATION ${ATDM_CONFIG_SCRIPTS_INSTALL_DIR} )
  
  INSTALL( DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/utils
    DESTINATION ${ATDM_CONFIG_SCRIPTS_INSTALL_DIR}
    PATTERN "*.cmake" EXCLUDE )
  
  INSTALL( DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/common
    DESTINATION ${ATDM_CONFIG_SCRIPTS_INSTALL_DIR}
    PATTERN "*.cmake" EXCLUDE )
  
  SET( ATDM_BUILD_NAME $ENV{ATDM_CONFIG_BUILD_NAME} )
  
  SET( ATDM_INSTALLED_ENV_LOAD_SCRIPT_NAME load_matching_env.sh
    CACHE STRING
    "Name of script installed in <CMAKE_INSTALL_PREFIX> to source to load matching env." )
  
  SET( ATDM_TRILINOS_INSTALL_PREFIX_ENV_VAR_NAME  ATDM_TRILINOS_INSTALL_PREFIX
    CACHE STRING
    "Name of env var set to <CMAKE_INSTALL_PREFIX> set in installed script <ATDM_INSTALLED_ENV_LOAD_SCRIPT_NAME>." )
  
  SET(ATDM_CONFIG_SYSTEM_NAME $ENV{ATDM_CONFIG_SYSTEM_NAME})
  SET(ATDM_CONFIG_CUSTOM_CONFIG_DIR $ENV{ATDM_CONFIG_CUSTOM_CONFIG_DIR})
  IF (ATDM_CONFIG_CUSTOM_CONFIG_DIR)
    SET(ATDM_SYSTEM_DIR_SRC "${ATDM_CONFIG_CUSTOM_CONFIG_DIR}")
    SET(ATDM_CUSTOM_CONFIG_DIR_ARG
      "${ATDM_CONFIG_SCRIPTS_INSTALL_DIR}/${ATDM_CONFIG_SYSTEM_NAME}")
  ELSE()
    SET(ATDM_SYSTEM_DIR_SRC "${CMAKE_CURRENT_LIST_DIR}/${ATDM_CONFIG_SYSTEM_NAME}")
    # NOTE: Can't install directly from $ENV{ATDM_CONFIG_SYSTEM_DIR} for an
    # offical system env because on the 'atdm-devops-admin' account can't read
    # under the orginal jenkins workspace directory which is in the var
    # ATDM_CONFIG_SYSTEM_DIR when the Jenkins job installs using the
    # 'run-as-atdm-devops-admin' account.  This is tricky to explain but this
    # is a fairly simple fix for the problem.  See #5834 for more details.
    # (NOTE: This assumes that a jenkins job will never work with a custom
    # config env which is a pretty safe assumption.)
    SET(ATDM_CUSTOM_CONFIG_DIR_ARG)
  ENDIF()

  INSTALL( DIRECTORY "${ATDM_SYSTEM_DIR_SRC}"
    DESTINATION ${ATDM_CONFIG_SCRIPTS_INSTALL_DIR}
    PATTERN "*.cmake" EXCLUDE )

  CONFIGURE_FILE( ${CMAKE_CURRENT_LIST_DIR}/utils/load_matching_env.sh.in
    ${CMAKE_CURRENT_BINARY_DIR}/cmake/std/atdm/utils/load_matching_env.sh @ONLY )
  
  INSTALL( FILES ${CMAKE_CURRENT_BINARY_DIR}/cmake/std/atdm/utils/load_matching_env.sh
    DESTINATION ${CMAKE_INSTALL_PREFIX}
    RENAME ${ATDM_INSTALLED_ENV_LOAD_SCRIPT_NAME} )

  INSTALL( PROGRAMS ${${PROJECT_NAME}_SOURCE_DIR}/packages/kokkos/bin/nvcc_wrapper
    DESTINATION ${ATDM_CONFIG_SCRIPTS_INSTALL_DIR} )

ENDIF()
