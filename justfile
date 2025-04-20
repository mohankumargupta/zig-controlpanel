set shell := ["sh", "-c"]
set windows-shell := ["powershell", "-c"]

buildrun:
    zig build run

build:
    zig build

build-test:
   zig test -femit-bin="zig-out/bin/zig_controlpaneltest.exe" --test-no-exec   src/utils.zig

run-test:
  zig-out/bin/zig_controlpaneltest.exe

test: build-test run-test