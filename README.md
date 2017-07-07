# ComputerCraftLibs
Libs and APIs that I've made to simplify scripting in ComputerCraft.

## How to use
+ All the code is tested on ComputerCraft v1.75, but not with other versions.
+ Most all files have to be rewritten to allow the usage of `os.loadAPI("file")` therefore please use `loadfile("file")()` at the beginning of file.

## Table of files
Name|Description
----|-----------
STD|Adds functions to these namespaces: `term`, `fs`, `math`, `string`, `table` and others
STDTurtle|Adds functions to `turtle` namespace
HGet|Allows downloading (text-based) files with an HTTP GET request (like wget)
Forms|Allows the creation of (static) windows with **Buttons**, **Panels**, single-line or multi-line **TextBoxes**, **Labels**, **Images**, **Custom items** and **Automated dialogs**.
