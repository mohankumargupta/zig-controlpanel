set shell := ["sh", "-c"]
set windows-shell := ["powershell", "-c"]

buildrun:
    zig build run

build:
    zig build
