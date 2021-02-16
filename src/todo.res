let helpString = "Usage :-
$ ./todo add \"todo item\"  # Add a new todo
$ ./todo ls               # Show remaining todos
$ ./todo del NUMBER       # Delete a todo
$ ./todo done NUMBER      # Complete a todo
$ ./todo help             # Show usage
$ ./todo report           # Statistics";

/* Returns date with the format: 2021-02-04 */
let getToday: unit => string = %raw(`
function() {
  let date = new Date();
  return new Date(date.getTime() - (date.getTimezoneOffset() * 60000))
    .toISOString()
    .split("T")[0];
}
  `)

type fsConfig = {encoding: string, flag: string}

/* https://nodejs.org/api/fs.html#fs_fs_existssync_path */
@bs.module("fs") external existsSync: string => bool = "existsSync"

/* https://nodejs.org/api/fs.html#fs_fs_readfilesync_path_options */
@bs.module("fs")
external readFileSync: (string, fsConfig) => string = "readFileSync"

/* https://nodejs.org/api/fs.html#fs_fs_writefilesync_file_data_options */
@bs.module("fs")
external appendFileSync: (string, string, fsConfig) => unit = "appendFileSync"

@bs.module("fs")
external writeFileSync: (string, string, fsConfig) => unit = "writeFileSync"

/* https://nodejs.org/api/os.html#os_os_eol */
@bs.module("os") external eol: string = "EOL"

let encoding = "utf8"

/*
NOTE: The code below is provided just to show you how to use the
date and file functions defined above. Remove it to begin your implementation.
*/

/* Js.log("Hello! today is " ++ getToday())

if existsSync("todo.txt") {
  Js.log("Todo file exists.")
} else {
  writeFileSync("todo.txt", "This is todo!" ++ eol, {encoding: encoding, flag: "w"})
  Js.log("Todo file created.")
} */

type process = {argv: array<string>}
@val external process: process = "process"

let argv = process.argv
let command = argv[2]
let arg = argv[3]

let isEmpty = text => text->Js.String2.trim->Js.String2.length > 0
let help = () => Js.log(helpString)

let readFile = () => {
  if (!existsSync("todo.txt")) {
    []
  } else {
    let text = readFileSync("todo.txt", {encoding: encoding, flag: "r"})
    text->Js.String2.split(eol)
  }
}

if isEmpty(command) {
  help()
} else {
  switch command->Js.String2.trim->Js.String2.toLowerCase {
    | "help" => Js.log("help")
    | "ls" => Js.log("ls")
    | "add" => Js.log("add")
    | "del" => Js.log("del")
    | "done" => Js.log("done")
    | "report" => Js.log("report")
    | _ => help()
  }
}
