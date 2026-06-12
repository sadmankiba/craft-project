# CRAFT Hand Blog Submission

This repository is the standalone local submission for the CRAFT hand blog.

To preview it locally, open `index.html` directly in a browser. It should render without running Jekyll because all image and video paths are relative to the repository root.

To prepare the zip file for upload:

```sh
./scripts/prepare_craft_submission_zip.sh
```

The script creates:

```text
dist/craft-hand-project-report.zip
```

Recommended final check before uploading:

```sh
rm -rf /tmp/craft-hand-project-report-check
unzip -q dist/craft-hand-project-report.zip -d /tmp/craft-hand-project-report-check
open /tmp/craft-hand-project-report-check/index.html
```

The unzipped folder should have `index.html` at its root, alongside the `files/` and `img/` asset folders used by the blog.
