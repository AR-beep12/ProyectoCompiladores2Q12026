find_program(TREECC_EXECUTABLE
    NAMES treecc
    HINTS ENV PATH
)

if (TREECC_EXECUTABLE)
    execute_process(
        COMMAND ${TREECC_EXECUTABLE} --version
        OUTPUT_VARIABLE TREECC_VERSION_OUTPUT
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if (TREECC_VERSION_OUTPUT MATCHES "TREECC ([0-9]+\\.[0-9]+\\.[0-9]+)")
        set(TREECC_VERSION "${CMAKE_MATCH_1}")
    else()
        set(TREECC_VERSION "unknown")
    endif()

    set(TREECC_FOUND TRUE)
else()
    set(TREECC_FOUND FALSE)
endif()

mark_as_advanced(TREECC_EXECUTABLE TREECC_VERSION)
