let helpString = "Usage :-
$ ./todo add \"todo item\"  # Add a new todo
$ ./todo ls               # Show remaining todos
$ ./todo del NUMBER       # Delete a todo
$ ./todo done NUMBER      # Complete a todo
$ ./todo help             # Show usage
$ ./todo report           # Statistics";

let getToday = () => {
  let date = Js.Date.make()
  let rawDateInFloat = date->Js.Date.getTime -.  (date->Js.Date.getTimezoneOffset *. 60000.)
  let formatedFullDate = rawDateInFloat->Js.Date.fromFloat->Js.Date.toISOString
  (formatedFullDate->Js.String2.split("T"))[0]
}

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

type process = {argv: array<string>}
@val external process: process = "process"

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
    text
      ->Js.String2.split(eol)
      ->Js.Array2.filter(todo => !isEmpty(~text=todo, ()))
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
    let todoIndex = switch index->Belt.Int.fromString {
      | Some(num) => num
      | None => -1
    }

    updateFile(pendingTodoFile, todos => {
      if (todoIndex < 1 || todoIndex > todos->Js.Array2.length) {
        Js.log("Error: todo #" ++ index ++ " does not exist. Nothing deleted.")
        todos
      } else {
        Js.log("Deleted todo #" ++ index)
        let _ = todos->Js.Array2.spliceInPlace(~pos=todoIndex - 1, ~remove=1, ~add=[])
        todos
      }
    })
  }
}

let markDone = index => {
  if isEmpty(~text=index, ()) {
    Js.log(`Error: Missing NUMBER for marking todo as done.`)
  } else {
    let todoIndex = switch index->Belt.Int.fromString {
      | Some(num) => num
      | None => -1
    }

    let todos = readFile(pendingTodoFile)
    let todosLength = todos->Js.Array2.length

    if (todoIndex < 1 || todoIndex > todosLength) {
      Js.log("Error: todo #" ++ index ++ " does not exist.")
    } else {
      let completedTodo = todos->Js.Array2.spliceInPlace(~pos=todoIndex - 1, ~remove=1, ~add=[])

      pendingTodoFile->writeToFile(todos)
      completedTodoFile->appendToFile(completedTodo[0] ++ eol)

      Js.log("Marked todo #" ++ index ++ " as done.")
    }
  }
}

let report = () => {
  let pending = readFile(pendingTodoFile)->Js.Array2.length
  let completed = readFile(completedTodoFile)->Js.Array2.length

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
    | "report" => report()
    | _ => help()
  }
}
