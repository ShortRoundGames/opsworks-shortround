#!/usr/bin/env bats

@test "forever binary is found in PATH" {
  run which forever
  [ "$status" -eq 0 ]
}
