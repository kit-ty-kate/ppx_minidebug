type t = {first: int; second: int} [@@deriving show]

let%expect_test "%debug_show flushing to a file" =
  let module Debug_runtime =
    Minidebug_runtime.Flushing(
      Minidebug_runtime.Debug_ch(
        struct let v = "../../../debugger_expect_show_flushing.log" end)) in
  let%debug_this_show rec loop (depth: int) (x: t): int =
    if depth > 6 then x.first + x.second
    else if depth > 3 then loop (depth + 1) {first=x.second + 1; second=x.first / 2}
    else
      let y: int = loop (depth + 1) {first=x.second - 1; second=x.first + 2} in
      let z: int = loop (depth + 1) {first=x.second + 1; second=y} in
      z + 7 in
  print_endline @@ Int.to_string @@ loop 0 {first=7; second=42};
  [%expect {| 56 |}]

let%expect_test "%debug_show flushing to stdout" =
  let module Debug_runtime = Minidebug_runtime.Flushing(struct let debug_ch = stdout end) in
  let%debug_show bar (x: t): int = let y: int = x.first + 1 in x.second * y in
  let () = print_endline @@ Int.to_string @@ bar {first=7; second=42} in
  let baz (x: t): int =
    let (y, z as _yz): int * int = x.first + 1, 3 in x.second * y + z in
  let () = print_endline @@ Int.to_string @@ baz {first=7; second=42} in
  [%expect {|
    BEGIN DEBUG SESSION at time 2023-03-04 11:41:31.692740 +01:00
    2023-03-04 11:41:31.692756 +01:00 - bar begin "test/test_expect_test.ml":20:21-20:75
     x = { Test_expect_test.first = 7; second = 42 }
     bar = 336
    2023-03-04 11:41:31.692810 +01:00 - bar end
    336
    2023-03-04 11:41:31.692815 +01:00 - baz begin "test/test_expect_test.ml":22:10-23:69
     x = { Test_expect_test.first = 7; second = 42 }
     baz = 339
    2023-03-04 11:41:31.692823 +01:00 - baz end
    339 |}]