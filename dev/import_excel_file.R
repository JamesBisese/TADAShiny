# When developing, work within a project (do not commit the project file to GitHub).
# Set your working directory to the package directory on your local drive.
# Then use devtools to load TADAShiny
library(devtools)
devtools::load_all()

# getwd()
example_file = "C:\\Data_and_Tools\\tada\\working\\data\\tada_import_example.xlsx"
example_df <- suppressWarnings(readxl::read_excel(example_file, sheet = 1))
EPATADA::TADA_AutoClean(example_df)
# this one works (doesn't fatal error) here

# The same file submitted to TADAShiny results in a fatal error
# # Error: (converted from warning) Error in dplyr::group_by: Must group by variables found in `.data`.
# # ✖ Column `TADA.CharacteristicName` is not found.

# So TADAShiny is considering the TADA.* fields as required.  This 


example_file = "C:\\Data_and_Tools\\tada\\working\\data\\tada_import_example_missing_Characteristic_values.xlsx"
example_df <- suppressWarnings(readxl::read_excel(example_file, sheet = 1))
EPATADA::TADA_AutoClean(example_df)
# > example_file = "C:\\Data_and_Tools\\tada\\working\\data\\tada_import_example_missing_Characteristic_values.xlsx"
# > example_df <- suppressWarnings(readxl::read_excel(example_file, sheet = 1))
# > EPATADA::TADA_AutoClean(example_df)
# [1] "TADA_Autoclean: creating TADA-specific columns."
# Error in if (any(.data$CharacteristicName == "Dissolved oxygen (DO)")) { : 
#   missing value where TRUE/FALSE needed

# Load the same file in TADAShiny and get this fatal error in the Console

# Error: (converted from warning) Error in dplyr::group_by: Must group by variables found in `.data`.
# ✖ Column `TADA.CharacteristicName` is not found.


# example_file = "C:\\Data_and_Tools\\tada\\working\\data\\tada_import_example_missing_columns.xlsx"
# example_df <- suppressWarnings(readxl::read_excel(example_file, sheet = 1))
# EPATADA::TADA_AutoClean(example_df)
# > example_file = "C:\\Data_and_Tools\\tada\\working\\data\\tada_import_example_missing_columns.xlsx"
# > example_df <- suppressWarnings(readxl::read_excel(example_file, sheet = 1))
# > EPATADA::TADA_AutoClean(example_df)
# Error in TADA_CheckColumns(.data, required_cols) : 
#   The dataframe does not contain the required fields. 
# Use either the full physical/chemical profile downloaded from WQP 
# or download the TADA profile template available on the EPA TADA webpage.


# Load the same file in TADAShiny and get this fatal error in the Console
# 
# Browse[2]> n
# Error: (converted from warning) Error in dplyr::group_by: Must group by variables found in `.data`.
# ✖ Column `TADA.CharacteristicName` is not found.

# > TADA_CheckRequiredFields(example_df)
# Error in TADA_CheckRequiredFields(example_df) : 
#   The dataframe does not contain the required fields to use TADA Module 1.

example_file = "C:\\Data_and_Tools\\tada\\working\\data\\tada_output_9rows_by_64columns.xlsx"
example_df <- suppressWarnings(readxl::read_excel(example_file, sheet = 1))
EPATADA::TADA_AutoClean(example_df)
# this works here and in TADAShiny
df3 <- EPATADA::TADA_CreateUnitRef(example_df)


example_file = "C:\\Data_and_Tools\\tada\\working\\data\\tada_output_9rows_by_58columns.xlsx"
example_df <- suppressWarnings(readxl::read_excel(example_file, sheet = 1))
EPATADA::TADA_AutoClean(example_df)
# this works here and import fatal errors in TADAShiny
# Error: (converted from warning) Error in dplyr::group_by: Must group by variables found in `.data`.
# ✖ Column `TADA.CharacteristicName` is not found.
df3 <- EPATADA::TADA_CreateUnitRef(example_df)

# > df3 <- EPATADA::TADA_CreateUnitRef(example_df)
# Error in `dplyr::select()`:
# ! Can't select columns that don't exist.
# ✖ Column `TADA.CharacteristicName` doesn't exist.
# Run `rlang::last_trace()` to see where the error occurred.

# > df3 <- EPATADA::TADA_CreateUnitRef(example_df)
# Error in `dplyr::select()`:
# ! Can't select columns that don't exist.
# ✖ Column `TADA.CharacteristicName` doesn't exist.
# Run `rlang::last_trace()` to see where the error occurred.
