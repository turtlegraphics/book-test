This is a bookdown book with minimal content but powerful additional functionality.  It is the tech behind [Foundations of Statistics with R](https://mathstat.slu.edu/~speegle/_book/) by Darrin Speegle and Bryan Clair.

This book has all the bells and whistles of the big book without any of the content.

It had its origin in the minimal "Bookdown Demo" book by Yihui Xie,
available at https://github.com/rstudio/bookdown-demo.

While "Bookdown Demo" was intended as a minimal working example, this book/project
is more of a batteries included example, which evolved as FoS grew.  If you
are interested in writing a texbook (as opposed to a reference manual), you will
probably find features in this book helpful.

This book has (and demonstrates how to make):

* Numbered theorems, examples, etc.
* Custom environments ("alert" and "tryit", for example).
* Numbered exercises with solutions.
* An index.
* Vignettes.
* Good looking html and latex output.
* Usage of CRC's `krantz.cls` style for books.
* A makefile that can perform single-chapter PDF builds.
* A clean directory and file structure.

--------

**Fenced Divs**

This book makes heavy use of fenced blocks, which are blocks enclosed in `:::`.
These are only just now being supported by bookdown, and so we are using our
own hacky implementation.

Our implementation is in the file `fenced-blocks.lua`, and is included in the pandoc build line.

Unfortunately, this conflicts with bookdown's implementation which is included as two pandoc filters, `latex-div.lua` and `custom-environment.lua`.
These filters are included in the build by default, with no way to disable them.
So, to make the book build, **you need to disable these filters manually**.
An effective way is to comment away the contents of these two files.
Find the full paths to the filters by looking at the pandoc build, and put their entire contents in
comments, between `--[[` and `]]--`
