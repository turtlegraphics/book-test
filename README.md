This is a bookdown book with minimal content but powerful additional functionality.  It is the tech behind
[*Probability, Statistics, and Data: A Fresh Approach Using R*](https://mathstat.slu.edu/~speegle/_book/) by Darrin Speegle and Bryan Clair.

This book has all the bells and whistles of the big book without any of the content.  It was developed from 2018-2021,
and had its origin in the minimal "Bookdown Demo" book by Yihui Xie,
available at https://github.com/rstudio/bookdown-demo.

Yihui's "Bookdown Demo" was intended as a minimal working example, although it has evolved since
this book/project forked off.
This project is more of a batteries included example, which evolved as *A Fresh Approach* grew.  If you
are interested in writing a texbook (as opposed to a reference manual), you will
probably find features in this demo project helpful.  Like all (good) bookdown projects, this
book produces high quality PDF and html versions from the same source.

This book has (and demonstrates how to make):

* Numbered theorems, examples, etc.
* Custom environments ("alert" and "tryit", for example).
* Numbered exercises and a solutions manual.
* An index.
* A separate data index.
* Photo credits that work smoothly in both html and latex for both inline and floated images.
* Vignettes.
* Good looking html and latex output.
* A makefile that can perform single-chapter PDF builds.
* A clean directory and file structure.
* CRC's `krantz.cls` style for books. The included `krantz.cls` has been altered from the file CRC distributes, first by Yihui Xie to repair bugs and second by Bryan Clair to fix a TOC bug and to handle running headers for unnumbered sections.

Build this book into a PDF using `make pdf`, or build a chapter with `make pdf chapter=02`.  Build the html version with `make`, or use RStudio's Build menu.  But see the note below before building.

--------

**Fenced Blocks**

This book makes heavy use of fenced blocks, which are blocks enclosed in `:::`.
These are now supported by bookdown, but were not at the time this book was created.
We are using our own hacky implementation of fenced blocks, which unfortunately differ slightly in syntax from the newer bookdown implementation.

Our implementation is in the file `fenced-blocks.lua`, and is included in the pandoc build line.

Unfortunately, this now conflicts with bookdown's implementation which is included as two pandoc filters, `latex-div.lua` and `custom-environment.lua`.
These filters are included in the build by default, with no way to disable them.
So, to make the book build, **you need to disable these filters manually**.
An effective way is to comment away the contents of these two files.
Find the full paths to the filters by looking at the pandoc build, and put their entire contents in
comments, between `--[[` and `]]--`

---------

**License**

To the extent possible, this project is licensed under CC 1.0 Universal, by which the author intends it to be free to use and adapt.  However, sample images and text in this project were cut/pasted without careful consideration of copyright, so all actual book content should be replaced if you are writing a book based on this technology.
