# Releasing guide

Release preparation and publication are automated with GitHub Actions. Java,
NodeJS, and Python preparation pull requests may be open at the same time.

## Release metadata

Each language has a `<language>/version.txt` file with named values:

```text
current_version=1.41.0
upstream_release_tag=layer-python/0.20.0
```

- `current_version` is the latest Sumo Logic release for that language.
- `upstream_release_tag` is the upstream OpenTelemetry Lambda release detected
  for that language.

The upstream tag prefixes are:

- Java: `layer-javaagent/`
- NodeJS: `layer-nodejs/`
- Python: `layer-python/`

Every prepare workflow pins the shared `opentelemetry-lambda` gitlink to the
selected language-specific upstream tag before deriving component versions. The
prepare pull request records both that tag and its resolved immutable commit SHA.

## Prepare a release

The `Check Upstream Releases` workflow runs weekly and can also be dispatched
manually. It compares the latest language-specific upstream tag with
`upstream_release_tag` and dispatches `Release Prepare` when it finds a newer
release.

`Release Prepare` can also be dispatched directly with:

- `language`: `java`, `nodejs`, or `python`
- `version`: the next release version without a `v` prefix
- `otel_lambda_tag`: the matching language-specific upstream tag

The workflow opens `prepare-<language>-v<version>` with these changes:

- `CHANGELOG.md` (a new section for the release)
- `<language>/version.txt`
- `<language>/layer-data.sh`
- `<language>/sample-apps/template.yaml`
- `<language>/README.md`
- root `README.md`
- `opentelemetry-lambda` gitlink

The workflow uses the GitHub App token to push the branch and open the pull
request, so the pull request checks start without manual approval.

Before merging the pull request:

1. Replace the TODO in the new `CHANGELOG.md` section with the release changes.
2. Verify the named values in `<language>/version.txt`.
3. Verify the layer version in `<language>/layer-data.sh`.
4. Verify the layer version in `<language>/sample-apps/template.yaml`.
5. Verify the version in the title of `<language>/README.md`.
6. Verify the root README release link and component versions.
7. Verify that `opentelemetry-lambda` points to the upstream tag and commit SHA
   listed in the pull request.
8. Resolve any normal pull-request conflict. When another release was merged
   first, `CHANGELOG.md`, the root README and the submodule gitlink can
   conflict. Keep both changelog sections. Keep the upstream pin selected for
   the pull request being merged, then recheck the generated component
   versions.

Only one open prepare pull request is allowed per language. An open Java
prepare pull request does not block NodeJS or Python preparation.

## Automatic post-merge flow

No workflow pushes to `main`. Merging a prepare pull request triggers the
following sequence:

1. `Release Tag` checks that `CHANGELOG.md` has a section for the release.
2. It creates `<language>-v<version>` at the merge commit and pushes only the
   tag, with the GitHub App token. Tag pushes made with the app token start
   `release-build-<language>.yml`. Tag pushes made with `GITHUB_TOKEN` do not.
3. The release-build workflow creates artifacts and publishes Lambda layers.
4. It creates a GitHub pre-release. The body contains the `CHANGELOG.md`
   section of the tag, the ARN tables and the container links.
5. It creates `release-<language>-v<version>` from the tag. In
   `<language>/README.md` it sets the version title, the ARN tables and the
   container links.
6. Review the pre-release. The GitHub release remains a pre-release.
7. When ready to publish, open the pre-release on the GitHub Releases page,
   edit it, clear the pre-release setting, mark it as the latest release, and
   publish it.

Final promotion is a manual GitHub UI step.

## Recovery

- If preparation fails, correct the input or workflow issue and dispatch
  `Release Prepare` again.
- If `Check Upstream Releases` fails with `Tag ... already exists`, the named
  values in `<language>/version.txt` are older than the latest release. Set them
  to the latest release and its upstream tag.
- If `Release Tag` fails because `CHANGELOG.md` has no section for the release,
  add the section to `main` in a pull request. Then push the tag by hand from
  the merge commit of the prepare pull request.
- If a tag exists but its build did not start or must be retried, dispatch the
  matching `release-build-<language>.yml` workflow with the existing release
  tag as its ref.
- If the release branch was not created, dispatch `Release Finalize` with the
  release tag. It reads the ARNs from the GitHub release. Pushes to an existing
  release branch are restricted, so delete a wrong branch first (repository
  admin).

Do not promote the pre-release before its contents have been reviewed.
