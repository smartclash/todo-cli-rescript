// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Fs = require("fs");
var Os = require("os");
var Curry = require("bs-platform/lib/js/curry.js");
var Belt_Int = require("bs-platform/lib/js/belt_Int.js");
var Belt_Array = require("bs-platform/lib/js/belt_Array.js");
var Caml_array = require("bs-platform/lib/js/caml_array.js");

var helpString = "Usage :-\n$ ./todo add \"todo item\"  # Add a new todo\n$ ./todo ls               # Show remaining todos\n$ ./todo del NUMBER       # Delete a todo\n$ ./todo done NUMBER      # Complete a todo\n$ ./todo help             # Show usage\n$ ./todo report           # Statistics";

function getToday(param) {
  var date = new Date();
  var rawDateInFloat = date.getTime() - date.getTimezoneOffset() * 60000;
  var formatedFullDate = new Date(rawDateInFloat).toISOString();
  return Caml_array.get(formatedFullDate.split("T"), 0);
}

var encoding = "utf8";

var cmd = Belt_Array.get(process.argv, 2);

var command = cmd !== undefined ? cmd : "";

var argument = Belt_Array.get(process.argv, 3);

var arg = argument !== undefined ? argument : "";

var pendingTodoFile = "todo.txt";

var completedTodoFile = "done.txt";

function isEmpty(textOpt, param) {
  var text = textOpt !== undefined ? textOpt : "";
  return text.trim().length <= 0;
}

function help(param) {
  console.log(helpString);
  
}

function readFile(filename) {
  if (!Fs.existsSync(filename)) {
    return [];
  }
  var text = Fs.readFileSync(filename, {
        encoding: encoding,
        flag: "r"
      });
  return Belt_Array.keep(text.split(Os.EOL), (function (todo) {
                return !isEmpty(todo, undefined);
              }));
}

function appendToFile(filename, text) {
  Fs.appendFileSync(filename, text, {
        encoding: encoding,
        flag: "a+"
      });
  
}

function writeToFile(filename, lines) {
  var text = Belt_Array.reduce(lines, "", (function (acc, line) {
          return acc + line + Os.EOL;
        }));
  Fs.writeFileSync(filename, text, {
        encoding: encoding,
        flag: "w"
      });
  
}

function updateFile(filename, updaterFn) {
  var contents = readFile(filename);
  var modifiedContents = Curry._1(updaterFn, contents);
  return writeToFile(filename, modifiedContents);
}

function list(param) {
  var todos = readFile(pendingTodoFile);
  var todosLength = todos.length;
  if (todosLength === 0) {
    console.log("There are no pending todos!");
  } else {
    console.log(Belt_Array.reduceWithIndex(Belt_Array.reverse(todos), "", (function (acc, todo, index) {
                return acc + "[" + String(todosLength - index | 0) + "] " + todo + "\n";
              })));
  }
  
}

function addTodo(text) {
  if (isEmpty(text, undefined)) {
    console.log("Error: Missing todo string. Nothing added!");
  }
  updateFile(pendingTodoFile, (function (todos) {
          return Belt_Array.concat(todos, [text]);
        }));
  console.log("Added todo: \"" + text + "\"");
  
}

function deleteTodo(index) {
  if (isEmpty(index, undefined)) {
    console.log("Error: Missing NUMBER for deleting todo.");
    return ;
  }
  var num = Belt_Int.fromString(index);
  var todoIndex = num !== undefined ? num : -1;
  return updateFile(pendingTodoFile, (function (todos) {
                if (todoIndex < 1 || todoIndex > todos.length) {
                  console.log("Error: todo #" + index + " does not exist. Nothing deleted.");
                  return todos;
                } else {
                  console.log("Deleted todo #" + index);
                  todos.splice(todoIndex - 1 | 0, 1);
                  return todos;
                }
              }));
}

function markDone(index) {
  if (isEmpty(index, undefined)) {
    console.log("Error: Missing NUMBER for marking todo as done.");
    return ;
  }
  var num = Belt_Int.fromString(index);
  var todoIndex = num !== undefined ? num : -1;
  var todos = readFile(pendingTodoFile);
  var todosLength = todos.length;
  if (todoIndex < 1 || todoIndex > todosLength) {
    console.log("Error: todo #" + index + " does not exist.");
    return ;
  }
  var completedTodo = todos.splice(todoIndex - 1 | 0, 1);
  writeToFile(pendingTodoFile, todos);
  appendToFile(completedTodoFile, Caml_array.get(completedTodo, 0) + Os.EOL);
  console.log("Marked todo #" + index + " as done.");
  
}

function report(param) {
  var pending = readFile(pendingTodoFile).length;
  var completed = readFile(completedTodoFile).length;
  console.log(getToday(undefined) + " Pending : " + String(pending) + " Completed : " + String(completed));
  
}

if (isEmpty(command, undefined)) {
  console.log(helpString);
} else {
  var match = command.trim().toLowerCase();
  switch (match) {
    case "add" :
        addTodo(arg);
        break;
    case "del" :
        deleteTodo(arg);
        break;
    case "done" :
        markDone(arg);
        break;
    case "help" :
        console.log(helpString);
        break;
    case "ls" :
        list(undefined);
        break;
    case "report" :
        report(undefined);
        break;
    default:
      console.log(helpString);
  }
}

exports.helpString = helpString;
exports.getToday = getToday;
exports.encoding = encoding;
exports.command = command;
exports.arg = arg;
exports.pendingTodoFile = pendingTodoFile;
exports.completedTodoFile = completedTodoFile;
exports.isEmpty = isEmpty;
exports.help = help;
exports.readFile = readFile;
exports.appendToFile = appendToFile;
exports.writeToFile = writeToFile;
exports.updateFile = updateFile;
exports.list = list;
exports.addTodo = addTodo;
exports.deleteTodo = deleteTodo;
exports.markDone = markDone;
exports.report = report;
/* cmd Not a pure module */
