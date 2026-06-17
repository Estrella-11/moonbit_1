# Windows Toolchain Troubleshooting

This note records a Windows-specific failure mode observed during local
verification and how to handle it without confusing it with a project failure.

## Symptom

Running MoonBit commands may fail before the tool starts:

```text
'C:\Users\<user>\.moon\bin\moon.exe' was blocked by the organization's
Device Guard policy.
```

Affected commands include:

```bash
moon info
moon fmt
moon check
moon test
moon run cmd/main
```

## Meaning

This is an operating-system application-control decision. The MoonBit compiler
binary is blocked before MoonDocKit code, tests, or package metadata are
loaded.

It should not be interpreted as:

- a MoonDocKit compile failure;
- a failed unit test;
- a broken `moon.mod` or `moon.pkg`;
- a generated `.mbti` mismatch.

## Quick Diagnosis

Run:

```cmd
where moon
moon info
```

If `where moon` points to `C:\Users\<user>\.moon\bin\moon.exe` and `moon info`
prints a Device Guard or organization policy message, the local machine is
blocking the executable.

## Recommended Fixes

Use one of these options:

1. Ask the Windows administrator to allow the MoonBit executable.
2. Install MoonBit in a trusted developer-tools directory approved by the
   machine policy.
3. Run the verification commands on another Windows machine without Device
   Guard restrictions.
4. Run verification in Linux, WSL, or CI where the MoonBit toolchain is allowed.

## Reviewer Guidance

If this happens during review, verify the repository on an environment where
`moon` can execute, then run the normal acceptance path:

```bash
moon info
moon fmt
moon check
moon check --target js
moon test
python tools/test_cli.py
python tools/verify_project.py
```

If only Python is available, reviewers can still inspect non-MoonBit generated
evidence:

```bash
python tools/build_example_site.py
python -m py_compile tools/verify_project.py tools/test_cli.py
```

Those commands do not replace MoonBit checks, but they help distinguish
repository-documentation issues from local OS policy issues.

## Current Project Note

Recent inline-renderer changes only affect private rendering logic and tests.
They do not change the public MoonBit API surface, so unchanged
`pkg.generated.mbti` files are expected unless a public function, struct, enum,
or trait is added or modified.
