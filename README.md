# AutoTagger

## What is it?

This is an experimental automatic content tagger for GOV.UK pages
based on the [Ankusa](https://github.com/bmuller/ankusa) gem, using
the naive Bayes algorithm.

It attempts to determine correct tags for a page by learning
from other, manually tagged pages.

## How to use it?
To run the script locally, run `./bin/tag.rb file_name` in your
command line.

The file you pass to the script should be in CSV format with
three columns - URL, tag and content. For an example, see the
[sample_content.csv](data/sample_content.csv) file.

## How to run the tests?
Just run `rspec` in the command line (which will work once the
tests are written).

## License
See the [LICENSE](LICENSE) file.
