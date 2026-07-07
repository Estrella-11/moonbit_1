## Summary

- Describe the change.

## Checks

- [ ] `moon info`
- [ ] `git diff --exit-code`
- [ ] `moon fmt`
- [ ] `git diff --exit-code`
- [ ] `moon check`
- [ ] `moon check --target js`
- [ ] `moon test`
- [ ] `python tools/test_cli.py`
- [ ] `python tools/verify_project.py`

## Impact

- [ ] Public MoonBit API changed
- [ ] Generated output changed
- [ ] CLI behavior changed
- [ ] Reviewer evidence changed
- [ ] Documentation-only change

## Notes

Use `docs/change-impact-matrix.md` to confirm the required checks and evidence.
If local Windows policy blocks `moon.exe`, mention it and link
`docs/windows-toolchain-troubleshooting.md`.
