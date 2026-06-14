///|
/// Return user-provided Node.js command-line arguments.
extern "js" fn cli_arguments() -> Array[String] =
  #| function() {
  #|   return typeof process === "undefined" ? [] : process.argv.slice(2);
  #| }

///|
/// Stop the Node.js CLI with a failure status.
extern "js" fn exit_failure(code : Int) -> Unit =
  #| function(code) {
  #|   if (typeof process !== "undefined") {
  #|     process.exit(code);
  #|   }
  #| }

///|
/// Read sorted Markdown files as alternating name/content values.
extern "js" fn read_markdown_directory(path : String) -> Array[String] =
  #| function(path) {
  #|   const fs = require("node:fs");
  #|   const nodePath = require("node:path");
  #|   const names = fs.readdirSync(path, { withFileTypes: true })
  #|     .filter((entry) => entry.isFile() && entry.name.toLowerCase().endsWith(".md"))
  #|     .map((entry) => entry.name)
  #|     .sort();
  #|   const result = [];
  #|   for (const name of names) {
  #|     result.push(name);
  #|     result.push(fs.readFileSync(nodePath.join(path, name), "utf8"));
  #|   }
  #|   return result;
  #| }

///|
/// Read one UTF-8 text file.
extern "js" fn read_text_file(path : String) -> String =
  #| function(path) {
  #|   const fs = require("node:fs");
  #|   return fs.readFileSync(path, "utf8");
  #| }

///|
/// Write a generated output manifest to a directory.
extern "js" fn write_output_directory(
  directory : String,
  paths : Array[String],
  contents : Array[String],
) -> Int =
  #| function(directory, paths, contents) {
  #|   const fs = require("node:fs");
  #|   const nodePath = require("node:path");
  #|   fs.mkdirSync(directory, { recursive: true });
  #|   for (let i = 0; i < paths.length; i++) {
  #|     const target = nodePath.join(directory, paths[i]);
  #|     fs.mkdirSync(nodePath.dirname(target), { recursive: true });
  #|     fs.writeFileSync(target, contents[i], "utf8");
  #|   }
  #|   return paths.length;
  #| }
