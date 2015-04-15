This is the `drfts.com` middleman website.

## Automated Tests

Run the tests with `rake test` after a successful build.

The tests will make sure that all pages in the sitemap and all internal
links return `200 OK` and have a valid `<title>` tag.

More tests will be added soon.

### Testing Setup
The build dir is served at a port and Anemone crawls everything during
the test setup, starting at `/`. Pages are saved and actual tests loop
over the data.
