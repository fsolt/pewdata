## Version 0.2.0
1. Faster
    + Revised the function to be more compact with the `rvest` functions.
    + Replaced the `if-else if` chains with the switch statements.
    + Overwrote the `for` loop by a `sapply` function.
1. More user-friendly
    + Users do not need to set up the `.Rprofile` by themselves. If the informaiton is missing the function will automatically call an input request at the terminal to ask for required information for the downloading.
    + One can reset the register information stored in the `.Rprofile` by switching the argument `reset` to `TRUE`. 


## Version 0.1.1
Allows nested directories to be automatically created if necessary if specified using the `download_dir` argument

## Version 0.1.0
First release.
