[![Run tests](https://github.com/rbaltrusch/file_management_gui/actions/workflows/run_tests.yml/badge.svg)](https://github.com/rbaltrusch/file_management_gui/actions/workflows/run_tests.yml)
[![Run linter](https://github.com/rbaltrusch/file_management_gui/actions/workflows/run_linter.yml/badge.svg)](https://github.com/rbaltrusch/file_management_gui/actions/workflows/run_linter.yml)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

# File management GUI

This GUI showcases MATLAB's graphical user interface capabilities and combines three common file management tasks:

1) Copy all selected files from a specified directory to a new, specified directory
1) Move all selected files from a specified directory to a new, specified directory
1) Delete all selected files from a specified directory and move them to the Recycle bin.

![Screenshot of the graphical user interface](https://github.com/rbaltrusch/file_management_gui/blob/main/media/screenshot.png?raw=true)

## Getting started

To get a copy of this repository, simply open up git bash in an empty folder and use the command:

    $ git clone https://github.com/rbaltrusch/file_management_gui

Open and run [gui.m](https://github.com/rbaltrusch/file_management_gui/blob/main/src/gui.m) in MATLAB or directly on the command line:

    cd src
    matlab -r run_gui

## More information

Detailed information on each GUI widget may be found in the gui documentation directly in the [gui source code](https://github.com/rbaltrusch/file_management_gui/blob/main/src/gui.m) or in the MATLAB command line using:
```MATLAB
help gui.Gui
```

## Contributions

To contribute to this repository, please read the [contribution guidelines](CONTRIBUTING.md).

## MATLAB Version

Written in MATLAB R2021a.

## License

This repository is open-source software available under the [AGPL-3.0 License](https://github.com/rbaltrusch/file_management_gui/blob/main/LICENSE).

## Contact

Please raise an issue for code changes. To reach out, please send an email to richard@baltrusch.net.
