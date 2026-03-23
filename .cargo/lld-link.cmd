@echo off
:: Wrapper that invokes Rust's bundled LLD in MSVC/COFF (lld-link) mode.
:: This is needed when the only link.exe on PATH is Git's GNU hard-link
:: utility, which is not a linker and causes build-script compilation to fail.
::
:: %USERPROFILE% expands to C:\Users\<you> so no hard-coded username is needed.
:: The toolchain name must match what `rustup toolchain list` shows as active.

set "RUST_LLD=%USERPROFILE%\.rustup\toolchains\stable-x86_64-pc-windows-msvc\lib\rustlib\x86_64-pc-windows-msvc\bin\rust-lld.exe"

if not exist "%RUST_LLD%" (
    echo lld-link.cmd: could not find rust-lld.exe at "%RUST_LLD%" >&2
    echo lld-link.cmd: run `rustup toolchain install stable-x86_64-pc-windows-msvc` >&2
    exit /b 1
)

:: --flavor link  puts LLD into MSVC-compatible COFF mode (same as lld-link.exe)
"%RUST_LLD%" --flavor link %*
