# A Citation Metadata Scraper for Web Pages

This is a Rubygems package that provides a command-line tool `bbbib` for
collecting citation metadata for a website. The tool is specifically designed to
work with my personal Bluebook-based citation system, an old version of which is
available [here](https://github.com/charlesduan/legcite), but it could easily be
expanded to work with BibLaTeX or other reference managers.

A second command-line tool `cap` is provided, which capitalizes a title
according to Bluebook Rule 8.

## Prerequisites and Installation

This package requires Ruby and Rubygems. I run it using the default-installed
versions on MacOS 10.15 (Catalina). The only other dependency is the Rubygem
package [Nokogiri](https://nokogiri.org/).

To install, run in this directory `gem install bbbib-*.*.*.gem`.

## Usage

Run `bbbib [URL]`. This will collect the specified webpage, attempt to guess the
appropriate citation parameters, and print out the predicted citation form. On
certain operating systems, the program will also copy the result to the
clipboard; use `-n` to suppress this behavior. A full list of options is
available with `bbbib --help`.

## What's Going On

The `bbbib` program reads the given webpage and attempts to guess citation
metadata such as authors and titles. It does so deterministically using XPATH
and regular expressions, particularly relying on OpenGraph and Twitter Card
metadata. No attempt at artificial intelligence or fuzzy matching is made.

Since the quality of metadata on various webpages is highly inconsistent, this
program will give incorrect output for many pages, particularly older ones that
don't follow modern metadata conventions.

The program considers a few special cases for often-used classes of websites
and websites that require special citation forms. The code for these sites (and
thus a list of them) is in the directory `lib/bbbib/source`. For example, this
program is able to identify journal metadata from Bepress and Pubmed sites to
output journal citations, and parses Google Scholar case documents to produce
case citations.

In the general case, the program runs through a list of candidate tests for each
of the standard website metadata fields (author, title, journal, date, and url).
The code for these tests is found in `lib/bbbib/finder`.


