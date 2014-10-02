#!/usr/bin/env bats

@test "nodejs binary is found in PATH" {
  run which nodejs
  [ "$status" -eq 0 ]
}
