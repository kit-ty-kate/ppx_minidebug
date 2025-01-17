ppx_minidebug
=============

## `ppx_minidebug`: A poor man's version of [`ppx_debug`](https://github.com/dariusf/ppx_debug)

`ppx_minidebug` traces selected code if it has type annotations. `ppx_minidebug` offers three ways of instrumenting the code: `%debug_pp` and `%debug_show` based on `deriving.show`, and `%debug_sexp` based on `sexplib0` and `ppx_sexp_conv`. The syntax extension expects a module `Debug_runtime` in the scope. The `ppx_minidebug.runtime` library (part of the `ppx_minidebug` package) offers three ways of logging the traces, as functors generating `Debug_runtime` modules given an output channel (e.g. for a file).

Take a look at [`ppx_debug`](https://github.com/dariusf/ppx_debug) which is significantly more powerful!

See also [the generated documentation](https://lukstafi.github.io/ppx_minidebug/).

 To install `ppx_minidebug` from sources, download it with e.g. `gh repo clone lukstafi/ppx_minidebug; cd ppx_minidebug` and then either `dune install` or `opam install .`

To use `ppx_minidebug` in a Dune project, add/modify these stanzas: `(preprocess (pps ... ppx_minidebug))`, and `(libraries ... ppx_minidebug.runtime)`.

### `Pp_format`-based traces

Define a `Debug_runtime` using the `Pp_format` functor. The helper functor `Debug_ch` opens a file for appending.
E.g. either `module Debug_runtime = Minidebug_runtime.Pp_format(struct let debug_ch = stdout end)`, or:
```ocaml
module Debug_runtime =
  Minidebug_runtime.Pp_format(
    Minidebug_runtime.Debug_ch(struct let filename = "path/to/debugger_format.log" end))
```
The logged traces will be indented using OCaml's `Format` module. Truncated example (using `%debug_pp`):
```ocaml
BEGIN DEBUG SESSION at time 2023-03-02 22:20:39.302 +01:00
"test/test_debug_pp.ml":4:17-4:71 at time 2023-03-02 22:20:39.302 +01:00: bar
x = { Test_debug_pp.first = 7; second = 42 }  bar = 336  
"test/test_debug_pp.ml":8:17-9:89 at time 2023-03-02 22:20:39.302 +01:00: baz
x = { Test_debug_pp.first = 7; second = 42 }  baz = 339  
"test/test_debug_pp.ml":12:22-18:9 at time 2023-03-02 22:20:39.302 +01:00: loop
depth = 0  x = { Test_debug_pp.first = 7; second = 42 }  "test/test_debug_pp.ml":16:8: 
  "test/test_debug_pp.ml":12:22-18:9 at time 2023-03-02 22:20:39.302 +01:00: loop
    depth = 1  x = { Test_debug_pp.first = 41; second = 9 }  "test/test_debug_pp.ml":16:8: 
      "test/test_debug_pp.ml":12:22-18:9 at time 2023-03-02 22:20:39.302 +01:00: loop
        depth = 2  x = { Test_debug_pp.first = 8; second = 43 }  "test/test_debug_pp.ml":16:8: 
          "test/test_debug_pp.ml":12:22-18:9 at time 2023-03-02 22:20:39.302 +01:00: loop
            depth = 3  x = { Test_debug_pp.first = 42; second = 10 } 
              "test/test_debug_pp.ml":16:8: 
              "test/test_debug_pp.ml":12:22-18:9 at time 2023-03-02 22:20:39.302 +01:00: loop
```

### `PrintBox`-based traces

Define a `Debug_runtime` using the `PrintBox` functor.
E.g. either `module Debug_runtime = Minidebug_runtime.PrintBox(struct let debug_ch = stdout end)`, or:
```ocaml
module Debug_runtime =
  Minidebug_runtime.PrintBox(
    Minidebug_runtime.Debug_ch(struct let filename = "path/to/debugger_printbox.log" end))
```
The logged traces will be pretty-printed as trees using the `printbox` package. Truncated example (using `%debug_sexp`):
```ocaml
BEGIN DEBUG SESSION at time 2023-03-02 22:20:39.305 +01:00
"test/test_debug_sexp.ml":4:19-6:15 at time
2023-03-02 22:20:39.305 +01:00: foo
├─x = 7
└─foo = (7 8 16)
"test/test_debug_sexp.ml":11:19-11:73 at time
2023-03-02 22:20:39.305 +01:00: bar
├─x = ((first 7) (second 42))
└─bar = 336
"test/test_debug_sexp.ml":14:19-15:67 at time
2023-03-02 22:20:39.305 +01:00: baz
├─x = ((first 7) (second 42))
└─baz = 339
"test/test_debug_sexp.ml":18:24-24:9 at time
2023-03-02 22:20:39.305 +01:00: loop
├─depth = 0
├─x = ((first 7) (second 42))
├─"test/test_debug_sexp.ml":22:8: 
│ ├─"test/test_debug_sexp.ml":18:24-24:9 at time
│ │ 2023-03-02 22:20:39.305 +01:00: loop
│ │ ├─depth = 1
│ │ ├─x = ((first 41) (second 9))
│ │ ├─"test/test_debug_sexp.ml":22:8: 
│ │ │ ├─"test/test_debug_sexp.ml":18:24-24:9 at time
│ │ │ │ 2023-03-02 22:20:39.305 +01:00: loop
│ │ │ │ ├─depth = 2
│ │ │ │ ├─x = ((first 8) (second 43))
│ │ │ │ ├─"test/test_debug_sexp.ml":18:24-24:9 at time
│ │ │ │ │ 2023-03-02 22:20:39.305 +01:00: loop
│ │ │ │ │ ├─depth = 3
│ │ │ │ │ ├─x = ((first 44) (second 4))
```

### `Flushing`-based traces

Define a `Debug_runtime` using the `Flushing` functor.
E.g. either `module Debug_runtime = Minidebug_runtime.Flushing(struct let debug_ch = stdout end)`, or:
```ocaml
module Debug_runtime =
  Minidebug_runtime.Flushing(
    Minidebug_runtime.Debug_ch(struct let filename = "path/to/debugger_flushing.log" end))
```
The logged traces are still indented, but if the values to print are multi-line, their formatting might be messy. The benefit of `Flushing` traces is that the output is flushed line-at-a-time, so no output should be lost if the traced program crashes. The indentation is also smaller (half of PrintBox). Truncated example (using `%debug_show`):
```ocaml
BEGIN DEBUG SESSION at time 2023-03-02 23:19:40.763950 +01:00
2023-03-02 23:19:40.763980 +01:00 - foo begin "test/test_debug_show.ml":3:19-5:15
 x = 7
 foo = [7; 8; 16]
2023-03-02 23:19:40.764000 +01:00 - foo end
2023-03-02 23:19:40.764011 +01:00 - bar begin "test/test_debug_show.ml":10:19-10:73
 x = { Test_debug_show.first = 7; second = 42 }
 bar = 336
2023-03-02 23:19:40.764028 +01:00 - bar end
2023-03-02 23:19:40.764034 +01:00 - baz begin "test/test_debug_show.ml":13:19-14:67
 x = { Test_debug_show.first = 7; second = 42 }
 baz = 339
2023-03-02 23:19:40.764048 +01:00 - baz end
2023-03-02 23:19:40.764054 +01:00 - loop begin "test/test_debug_show.ml":17:24-23:9
 depth = 0
 x = { Test_debug_show.first = 7; second = 42 }
  "test/test_debug_show.ml":21:8: 
  2023-03-02 23:19:40.764073 +01:00 - loop begin "test/test_debug_show.ml":17:24-23:9
   depth = 1
   x = { Test_debug_show.first = 41; second = 9 }
    "test/test_debug_show.ml":21:8: 
    2023-03-02 23:19:40.764094 +01:00 - loop begin "test/test_debug_show.ml":17:24-23:9
     depth = 2
     x = { Test_debug_show.first = 8; second = 43 }
      "test/test_debug_show.ml":21:8: 
      2023-03-02 23:19:40.764109 +01:00 - loop begin "test/test_debug_show.ml":17:24-23:9
       depth = 3
       x = { Test_debug_show.first = 42; second = 10 }
        "test/test_debug_show.ml":21:8: 
```

## Usage

To trace a function, you have to type-annotate the function result. To trace an argument of a traced function, or a `let`-binding, you need to type-annotate it. You can control how much gets logged by adding or removing type annotations.

Tracing only happens in explicitly marked scopes, using the extension points: `%debug_pp`, `%debug_this_pp`, `%debug_show`, `%debug_this_show` (based on printing functionality provided by `deriving.show`), `%debug_sexp`, `%debug_this_sexp` (using functionality provided by `sexplib0` and `ppx_sexp_conv`). See examples in [the test directory](test/).

The `%debug_this` variants are intended only for `let`-bindings: `let%debug_this v: t = compute value in body` will trace `v` and the type-annotated bindings and functions inside `compute value`, but it will not trace `body`.

To properly trace in concurrent settings, ensure that different threads use different log channels. For example, you can bind `Debug_runtime` locally: `let module Debug_runtime = Minidebug_runtime.Flushing(struct let debug_ch = thread_specific_ch end) in ...` In particular, when performing `dune runtest` in the `ppx_minidebug` directory, the `test_debug_n` and the `test_debug_n_expected` pairs of programs will interfere with each other, unless you adjust the log file names in them.

`Minidebug_runtime.Debug_ch` appends to log files, so you need to delete them as appropriate for your convenience.

The `PrintBox` logs are the prettiest, I could not get the `Pp_format`-functor-based output look the way I wanted. The `Flushing` logs enable [Log Inspector (sub-millisecond)](https://marketplace.visualstudio.com/items?itemName=lukstafi.loginspector-submillisecond) flame graphs. One should be able to get other logging styles to work with `Log Inspector` by configuring its regexp patterns.

`ppx_minidebug` and `minidebug_runtime` can be installed using `opam` in the normal way. `minidebug_runtime` depends on `printbox` and `ptime`, and only optionally on `base` (for the s-expression functionality).

## VS Code suggestions

### Add / remove type annotations and visit files using [VOCaml](https://marketplace.visualstudio.com/items?itemName=lukstafi.vocaml)

[VOCaml helpers for coding in OCaml](https://marketplace.visualstudio.com/items?itemName=lukstafi.vocaml) provide commands to add and remove annotations on selected bindings. They can be used to introduce logging, tune it, and cleanup afterward. It also has a command to populate the _Quick Open_ dialog with a file name and location from a line under cursor. It can be used to jump to the source code from a log file.

Note that you can add and remove type annotations using VSCode OCaml Platform's code actions, and the _Find and Transform_ suggestion below is a more flexible go-to-file solution -- so VOCaml is somewhat redundant. But, it is still valuable: (1) it annotates multiple `let`-bindings at once in a selection, and (2) it annotates the argument types and the return type of a function (as required by `ppx_debug`) when invoked on a function definition.

### Visualize the flame graph using [Log Inspector](https://marketplace.visualstudio.com/items?itemName=lukstafi.loginspector-submillisecond)

[Log Inspector (sub-millisecond)](https://marketplace.visualstudio.com/items?itemName=lukstafi.loginspector-submillisecond)'s main feature is visualizing timestamped logs as flame graphs. To invoke it in VS Code, go to a `Minidebug_runtime.Flushing`-style logs file, press `crtl+shift+P`, and execute the command "Log Inspector: Draw". Example effect:
![Log Inspector flame graph](docs/ppx_minidebug-LogInspector.png)

Note that [Log Inspector (sub-millisecond)](https://marketplace.visualstudio.com/items?itemName=lukstafi.loginspector-submillisecond) is a forked variant of the Log Inspector extension.

### Go to file location using [Find and Transform](https://marketplace.visualstudio.com/items?itemName=ArturoDent.find-and-transform)

This will expand your general-purpose VS Code toolbox!

[Find and Transform](https://marketplace.visualstudio.com/items?itemName=ArturoDent.find-and-transform) is a powerful VS Code extension. I put the following in my `keybindings.json` file (command: `Open Keyboard Shortcuts (JSON)`):
```json
  {
    "key": "alt+q",
    "command": "findInCurrentFile",
    "args": {
      "description": "Open file at cursor",
      "find": "\"([^\"]+)\":([0-9]+)",
      "run": [
        "$${",
          "const pos = new vscode.Position($2, 0);",
          "const range = new vscode.Range(pos, pos);",
          "const options = {selection: range};",
          "const wsFolderUri = vscode.workspace.workspaceFolders[0].uri;",
          "const uri = await vscode.Uri.joinPath(wsFolderUri, '$1');",
          "await vscode.commands.executeCommand('vscode.open', uri, options);",
          
          // "await vscode.commands.executeCommand('workbench.action.quickOpen', `$1:$2`);",
        "}$$",
      ],
      "isRegex": true,
      "restrictFind": "line",
    }
  }
```
Then, pressing `alt+q` will go to the file directly, assuming the logs contain the full relative path.
