# Support

## Help yourself first

Most questions are answered by the package itself:

1. Run the test suite - `python tests/test-method-patterns.py`. It validates the authoritative sources directly (templates, red lines, counts, encoding hygiene).
2. Check tier readiness - `powershell -ExecutionPolicy Bypass -File scripts/self-scale.ps1 -Action status`.
3. Read the spec - `README_FOR_AI.md` is the self-contained, authoritative specification for this standalone project; its section 14 lists the red lines and section 15 the acceptance checks.
4. Search the [issue tracker](https://github.com/JohnSmithfan/AI-Company/issues) and the `CHANGELOG.md` - the answer may already exist.

## Where to take a question

| Need | Channel |
|---|---|
| Bug in skill behavior, scripts, tests, or documentation | Open an issue using the bug report template |
| New capability or improvement | Open an issue using the feature request template |
| Security vulnerability | **Never a public issue** - follow the private channel in `SECURITY.md` |
| Usage question | Open an issue; a documentation gap will be re-labeled as such |

## Response expectations

- General issues are triaged on a best-effort basis; there is no guaranteed first-response SLA.
- Security reports follow the SLA in `SECURITY.md`: acknowledgment within 7 days and a 90-day coordinated disclosure window.
- This is a standalone skill package maintained in the maintainer's spare time. Please be kind.
