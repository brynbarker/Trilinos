INCLUDE(PackageArchDefineStandardCompileVars)
INCLUDE(DualScopePrependCmndlineArgs)

#
# Helper macros
#

MACRO(PACKAGE_ARCH_SET_LANGUAGE_BUILDTYPE_FLAGS LANG BUILDTYPE)

  #PRINT_VAR(CMAKE_${LANG}_FLAGS_${BUILDTYPE})
  #PRINT_VAR(GENERAL_${BUILDTYPE}_FLAGS)

  # Set the default CMAKE_${LANG}_FLAGS_${BUILDTYPE} to empty to override the
  # default that CMake gives!  We want to define these for ourselves.
  SET(CMAKE_${LANG}_FLAGS_${BUILDTYPE} "")

  IF (GENERAL_${BUILDTYPE}_FLAGS)
    DUAL_SCOPE_PREPEND_CMNDLINE_ARGS(CMAKE_${LANG}_FLAGS_${BUILDTYPE}
      "${GENERAL_${BUILDTYPE}_FLAGS}")
  ENDIF()
  IF(${PROJECT_NAME}_VERBOSE_CONFIGURE)
    MESSAGE(STATUS "Adding ${LANG} ${BUILDTYPE} flags"
      " \"${GENERAL_${BUILDTYPE}_FLAGS}\"")
    PRINT_VAR(CMAKE_${LANG}_FLAGS_${BUILDTYPE})
  ENDIF()

ENDMACRO()


MACRO(PACKAGE_ARCH_SET_LANGUAGE_GENERAL_FLAGS LANG)

  DUAL_SCOPE_PREPEND_CMNDLINE_ARGS(CMAKE_${LANG}_FLAGS
   "${GENERAL_BUILD_FLAGS}")
  IF(${PROJECT_NAME}_VERBOSE_CONFIGURE)
    MESSAGE(STATUS "Adding general ${LANG} flags \"${${GENERAL_BUILD_FLAGS}}\"")
    PRINT_VAR(CMAKE_${LANG}_FLAGS)
  ENDIF()

ENDMACRO()


MACRO(PACKAGE_ARCH_SET_LANGUAGE_COVERAGE_FLAGS LANG)

  DUAL_SCOPE_PREPEND_CMNDLINE_ARGS(CMAKE_${LANG}_FLAGS
   "${COVERAGE_OPTIONS}")
  IF(${PROJECT_NAME}_VERBOSE_CONFIGURE)
    MESSAGE(STATUS "Adding coverage ${LANG} flags \"${COVERAGE_OPTIONS}\"")
    PRINT_VAR(CMAKE_${LANG}_FLAGS)
  ENDIF()

ENDMACRO()


#
# Function that sets up strong compile options for the primary
# development platform (i.e. gcc)
#
# NOTE: The compiler flags in the cache, which may have been set by
# the user, are not disturbed in this function.  Instead variables in
# the parent base scope are set.
#

FUNCTION(PACKAGE_ARCH_SETUP_BASIC_COMPILE_LINK_FLAGS)

  #
  # Setup and general flags
  #

  PACKAGE_ARCH_DEFINE_STANDARD_COMPILE_FLAGS_VARS(FALSE)

  #
  # Set up coverge testing options
  #

  IF (${PROJECT_NAME}_ENABLE_COVERAGE_TESTING)
    SET(COVERAGE_OPTIONS "-fprofile-arcs -ftest-coverage")
  ELSE()
    SET(COVERAGE_OPTIONS "")
  ENDIF()

  #
  # C compiler options
  #

  ASSERT_DEFINED(${PROJECT_NAME}_ENABLE_C CMAKE_C_COMPILER_ID)
  IF (${PROJECT_NAME}_ENABLE_C AND CMAKE_C_COMPILER_ID STREQUAL "GNU")
    PACKAGE_ARCH_SET_LANGUAGE_BUILDTYPE_FLAGS(C DEBUG)
    PACKAGE_ARCH_SET_LANGUAGE_BUILDTYPE_FLAGS(C RELEASE)
    PACKAGE_ARCH_SET_LANGUAGE_GENERAL_FLAGS(C)
    PACKAGE_ARCH_SET_LANGUAGE_COVERAGE_FLAGS(C)
  ENDIF()

  #
  # C++ compiler options
  #

  ASSERT_DEFINED(${PROJECT_NAME}_ENABLE_CXX CMAKE_CXX_COMPILER_ID)
  IF (${PROJECT_NAME}_ENABLE_CXX AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    PACKAGE_ARCH_SET_LANGUAGE_BUILDTYPE_FLAGS(CXX DEBUG)
    PACKAGE_ARCH_SET_LANGUAGE_BUILDTYPE_FLAGS(CXX RELEASE)
    PACKAGE_ARCH_SET_LANGUAGE_GENERAL_FLAGS(CXX)
    PACKAGE_ARCH_SET_LANGUAGE_COVERAGE_FLAGS(CXX)
  ENDIF()

  #
  # Fortran compiler options
  #

  ASSERT_DEFINED(${PROJECT_NAME}_ENABLE_Fortran)
  IF (${PROJECT_NAME}_ENABLE_Fortran AND CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
    PACKAGE_ARCH_SET_LANGUAGE_COVERAGE_FLAGS(Fortran)
  ENDIF()

  #
  # Linker options
  #

  ASSERT_DEFINED(${PROJECT_NAME}_ENABLE_COVERAGE_TESTING COVERAGE_OPTIONS)
  IF (${PROJECT_NAME}_ENABLE_COVERAGE_TESTING AND COVERAGE_OPTIONS)
    DUAL_SCOPE_PREPEND_CMNDLINE_ARGS(CMAKE_EXE_LINKER_FLAGS
     "${COVERAGE_OPTIONS} ${CMAKE_EXE_LINKER_FLAGS}")
    IF(${PROJECT_NAME}_VERBOSE_CONFIGURE)
      MESSAGE(STATUS "Adding coverage linker flags flags \"${COVERAGE_OPTIONS}\"")
      PRINT_VAR(CMAKE_EXE_LINKER_FLAGS)
    ENDIF()
  ENDIF()
  
ENDFUNCTION()
