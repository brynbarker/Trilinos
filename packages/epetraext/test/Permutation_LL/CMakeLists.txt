


TRIBITS_ADD_EXECUTABLE_AND_TEST(
  Permutation_test_LL
  SOURCES cxx_main.cpp
  ARGS -v
  COMM serial mpi
  )
