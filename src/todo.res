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

@val external number: (string) => int = "Number"

let argv = process.argv
let command = argv->Js.Array2.length > 2 ? argv[2] : ""
let arg = argv->Js.Array2.length > 3 ? argv[3] : ""
let pendingTodoFile = "todo.txt"
let completedTodoFile = "done.txt"

let isEmpty: (~text: string=?, unit) => bool = (~text="", ()) => {
  text->Js.String2.trim->Js.String2.length <= 0
}

let help = () => Js.log(helpString)

let readFile = filename => {
  if (!existsSync(filename)) {
    []
  } else {
    let text = readFileSync(filename, {encoding: encoding, flag: "r"})
    text->Js.String2.split(eol)
  }
}

let appendToFile = (filename, text) => appendFileSync(filename, text, {encoding: encoding, flag: "a+"})

let writeToFile = (filename, lines) => {
  let text = lines->Js.Array2.joinWith(eol)
  filename->writeFileSync(text, {encoding: encoding, flag: "w"})
}

let updateFile = (filename, updaterFn: (array<string>) => array<string>) => {
  let contents = filename->readFile
  let modifiedContents = contents->updaterFn
  filename->writeToFile(modifiedContents)
}

let list = () => {
  let todos = readFile(pendingTodoFile)
  let todosLength = todos->Js.Array2.length

  if todosLength == 0 {
    Js.log("There are no pending todos!")
  } else {
    todos
      ->Js.Array2.reverseInPlace
      ->Js.Array2.mapi((todo, index) => "[" ++ Belt.Int.toString(todosLength - index) ++ "] " ++ todo)
      ->Js.Array2.joinWith("\n")
      ->Js.log
  }
}

let addTodo = text => {
  if isEmpty(~text=text, ()) {
    Js.log("Error: Missing todo string. Nothing added!")
  }

  updateFile(pendingTodoFile, todos => todos->Js.Array2.concat([text]))
  Js.log("Added todo: \"" ++ text ++ "\"")
}

let deleteTodo = index => {
  if isEmpty(~text=index, ()) {
    Js.log("Error: Missing NUMBER for deleting todo.")
  } else {
    let todoIndex = index->number
    updateFile(pendingTodoFile, todos => {
      if (todoIndex < 1 || todoIndex > todos->Js.Array2.length) {
        Js.log("Error: todo #" ++ index ++ " does not exist. Nothing deleted.")
        todos
      } else {
        Js.log("Deleted todo #" ++ index)
        let _ = todos->Js.Array2.slice(~start=todoIndex, ~end_=1)
        todos
      }
    })
  }
}

let markDone = index => {
  if isEmpty(~text=index, ()) {
    Js.log(`Error: Missing NUMBER for marking todo as done.`)
  } else {
    let todoIndex = index->number
    let todos = readFile(pendingTodoFile)

    if (todoIndex < 1 || todoIndex > todos->Js.Array2.length) {
      Js.log("Error: todo #" ++ index ++ " does not exist.")
    }

    let completedTodo = todos->Js.Array2.slice(~start=todoIndex, ~end_=1)
    pendingTodoFile->writeToFile(todos)

    completedTodoFile->appendToFile(completedTodo[0] ++ eol)
    Js.log("Marked todo #" ++ index ++ " as done.")
  }
}

let report = () => {
  let pending = readFile(pendingTodoFile)->Js.Array2.length - 1
  let completed = readFile(completedTodoFile)->Js.Array2.length - 1

  Js.log(getToday() ++ " Pending : " ++ Belt.Int.toString(pending) ++ " Completed : " ++ Belt.Int.toString(completed))
}

if isEmpty(~text=command, ()) {
  help()
} else {
  switch command->Js.String2.trim->Js.String2.toLowerCase {
    | "help" => help()
    | "ls" => list()
    | "add" => addTodo(arg)
    | "del" => deleteTodo(arg)
    | "done" => markDone(arg)
    | "report" => Js.log("report")
    | _ => help()
  }
}
