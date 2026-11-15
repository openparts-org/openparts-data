# Contributing to openparts-data

Most of the data here was extracted from datasheets by AI agents. Those
documents are **candidates**: nobody has checked them yet. The most
useful contribution is to check them against the datasheet and say so
in a pull request. Fixes and new parts are welcome too. No time to fix
a value? Use "Report an error" on its part page: it opens the
[data error](https://github.com/openparts-org/openparts-data/issues/new?template=data-error.yml)
issue form with the part and its files filled in.

Each part has three documents: the Part (`parts/`), its Device (pins,
`devices/`) and its Package (dimensions, `packages/`). The sources they
cite are in `sources/`. The format is the
[Canonical Data Specification](https://github.com/openparts-org/openparts/blob/main/docs/spec/canonical-data.md).

## Verify a value against the datasheet

Every value is cited in the document's `provenance` (an illustration):

```yaml
dimensions:
  body_width: {nominal: 7.0, unit: mm}
provenance:
  /dimensions/body_width:
    - source: raspberrypi/RP-008371-DS@rev1
      page: 642
      locator: "QFN-56 7x7mm, E"
```

1. Find the Source with that id in `sources/` and open its `url`, adding
   `#page=642` (the cited page) to jump to the page (the part page on the OpenParts site
   links each value there for you).
2. Find the place the `locator` names (a table, a figure, a dimension
   letter) and compare: value, unit, and min/typ/max. A range stated
   only as min/max must not have a nominal.
3. Check the Source too: the document's revision and date must match
   its `revision` and `date`. A newer revision may say something else.

## Mark a document reviewed

When you have checked **every** value of a document (and found it right,
or fixed it), add a `review` block at the end of the file:

```yaml
review:
  status: reviewed
  by: [your-github-login]   # everyone who checked it
  pr: 123                   # the number of your pull request
  date: 2026-11-20
```

Open the pull request first to get its number, then push the commit
that sets `pr`. Only mark what you checked: a part counts as reviewed on
the site when its Part, Device and Package are all reviewed, so a
reviewed Package alone is fine and useful.

Never mark a document reviewed without having checked it yourself, and
don't mark documents in a pull request you did not review. AI agents
never set this block.

## Fix a value, with provenance

1. Change the value.
2. Update its provenance entry: the `source` you read (add a file under
   `sources/` for a document or revision that isn't there yet), the PDF
   `page`, and a `locator` precise enough for someone else to find it.
3. If the document had a `review` block, delete it -- unless you then
   review the whole document, in which case update `by`, `pr` and
   `date`. A changed value is not reviewed until someone checks it.

Don't invent or estimate values: leave out what the datasheet doesn't
state. Don't commit PDFs; link to the manufacturer's copy.

## Check and open the pull request

- Quick fixes: use "Edit on GitHub" on the part page (or the pencil on
  any file here). GitHub forks the repository and opens the pull
  request for you.
- Locally: clone [openparts](https://github.com/openparts-org/openparts)
  next to this repository and run `./scripts/validate.sh`.

The pull request runs the validator and posts a comment with a table of
every value it changes: file, field, old and new value, and a link to
the cited source page with the locator. Reviewers use it to check the
change; check it yourself first.

Can't fix it yourself? Use "Report an error" on the part page, or
[open an issue](https://github.com/openparts-org/openparts-data/issues/new).
