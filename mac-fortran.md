---
layout: default
title: osx gfortran installation instructions
---

### OSX 10.10 (Yosemite) and later

Make sure you have `Xcode` installed.
`Xcode` contains the tools needed to compile native code on your machine.
It can be downloaded from the App Store or from [https://developer.apple.com/xcode/downloads/](https://developer.apple.com/xcode/downloads/).

Open a terminal window and execute

```
xcode-select --install
```

To test it, try to install **pomp** from source.
To do so, run the following in an **R** session

```
library(devtools)  
install_github("kingaa/pomp")
```

Some users of `Xcode 9 beta 2` have reported needing to install the Command Line Tools package separately.
It is available at [https://developer.apple.com/download/more/](https://developer.apple.com/download/more/).

If these still don't work, complaining about a lack of FORTRAN support, try [installing `gfortran` binaries from GCC](https://gcc.gnu.org/wiki/GFortranBinaries#MacOS) as [recommended by CRAN](https://cran.r-project.org/bin/macosx/tools/).

### OSX 10.9 (Mavericks) and older

Make sure you have `Xcode` installed.
It is available at [https://developer.apple.com/xcode/downloads/](https://developer.apple.com/xcode/downloads/).
You may need to follow the "Additional Tools" link to find an older version of `Xcode`.

To test it, try to install **pomp** from source.
To do so, run the following in an **R** session

```
library(devtools)  
install_github("kingaa/pomp")
```

If these still don't work, complaining about a lack of FORTRAN support, try installing `gfortran` according to the following instructions.

The following is based on the [instructions given on the **R** website](https://cran.r-project.org/bin/macosx/tools).

To install `gfortran` in your user space in such a way that it can be easily removed later, download and run the `mac-fortran.sh` script from the course website by opening a terminal and executing

```
curl -O https://kingaa.github.io/scripts/mac-fortran.sh  
sh mac-fortran.sh
```

This will download and unpack a new version of `gfortran`, putting it into a new directory: `~/gfortran`.
It will also put a `Makevars` file into your `~/.R` directory so that **R** knows where to look when it wants `gfortran`.

To test it, install **pomp** from source by running the following in an **R** session

```
library(devtools)  
install_github("kingaa/pomp")
```

Should you ever need to uninstall the `gfortran` installation, simply remove the `~/gfortran` directory by executing the following in a terminal window,

```
rm -rf ~/gfortran
```

then edit the `~/.R/Makevars` file to remove the lines that refer to `~/gfortran`.

### Links

- [**R** project's recommendations on development tools and libraries for Mac OS X](https://cran.r-project.org/bin/macosx/tools)
- [Some more recent binaries of the <code>gfortran</code> compiler on gcc.gnu.org](https://gcc.gnu.org/wiki/GFortranBinaries#MacOS)
