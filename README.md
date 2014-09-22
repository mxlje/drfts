This is the `drfts.com` website.
There are many like it, but this one is mine.

[ ![Codeship Status for mxlje/drfts](https://codeship.io/projects/1a6e7e50-218f-0132-a891-22cde3786202/status)](https://codeship.io/projects/36296)

## Automated Tests

Run the tests with `rake test` after a successful build. The order will
be optimized in the future.

The tests will make sure that all pages in the sitemap and all internal
links return `200 OK` and have a valid `<title>` tag.

More tests will be added soon.

### Testing Setup

The build dir is served at a port and Anemone crawls everything during
the test setup, starting at `/`. Pages are saved and actual tests loop
over the data.