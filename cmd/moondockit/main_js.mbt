///|
fn first_value(
  matches : @argparse.Matches,
  key : String,
  fallback : String,
) -> String {
  match matches.values.get(key) {
    Some(values) => if values.length() > 0 { values[0] } else { fallback }
    None => fallback
  }
}

///|
fn flag_enabled(matches : @argparse.Matches, key : String) -> Bool {
  match matches.flags.get(key) {
    Some(value) => value
    None => false
  }
}

///|
fn choose_value(
  cli_value : String,
  config_value : String,
  fallback : String,
) -> String {
  let cli = cli_value.trim().to_owned()
  if cli != "" {
    cli
  } else {
    let config = config_value.trim().to_owned()
    if config != "" {
      config
    } else {
      fallback
    }
  }
}

///|
fn config_value(config_file : String, key : String) -> String {
  let value = read_config_value(config_file, key)
  if value.has_prefix("__MOONDOC_CONFIG_ERROR__") {
    fail("cannot read config file: " + value[24:].to_owned())
    return ""
  }
  value
}

///|
fn stem(filename : String) -> String {
  if filename.has_suffix(".md") {
    filename[0:filename.length() - 3].to_owned()
  } else {
    filename
  }
}

///|
fn load_pages(directory : String, api_file : String) -> Array[@lib.DocPage] {
  let raw = read_markdown_directory(directory)
  let pages : Array[@lib.DocPage] = []
  let mut i = 0
  while i + 1 < raw.length() {
    let name = raw[i]
    let page_stem = stem(name)
    pages.push({ title: page_stem, slug: page_stem, source: raw[i + 1] })
    i = i + 2
  }
  if api_file.trim().to_owned() != "" {
    pages.push(@lib.mbti_to_page(read_text_file(api_file)))
  }
  pages
}

///|
fn write_manifest(directory : String, files : Array[@lib.OutputFile]) -> Int {
  let paths : Array[String] = []
  let contents : Array[String] = []
  for file in files {
    paths.push(file.path)
    contents.push(file.content)
  }
  write_output_directory(directory, paths, contents)
}

///|
fn fail(message : String) -> Unit {
  println("MoonDocKit input error: \{message}")
  println(
    "hint: run with --config examples/moondockit.json or pass --source and --output explicitly",
  )
  exit_failure(1)
}

///|
fn main {
  let command = @argparse.Command(
    "moondockit",
    about="Build a static documentation site from a Markdown directory.",
    version="0.1.0",
    flags=[
      @argparse.FlagArg(
        "dry-run",
        about="Validate and report generated outputs without writing files.",
      ),
      @argparse.FlagArg(
        "strict",
        about="Fail when validation warnings are present.",
      ),
    ],
    options=[
      @argparse.OptionArg("config", about="Optional JSON configuration file.", default_values=[
        "",
      ]),
      @argparse.OptionArg(
        "source",
        short='s',
        about="Directory containing Markdown files.",
        default_values=[""],
      ),
      @argparse.OptionArg("output", short='o', about="Destination directory.", default_values=[
        "",
      ]),
      @argparse.OptionArg(
        "title",
        about="Generated documentation site title.",
        default_values=[""],
      ),
      @argparse.OptionArg(
        "site-url",
        about="Optional public base URL for canonical metadata.",
        default_values=[""],
      ),
      @argparse.OptionArg(
        "api",
        about="Optional generated .mbti file to include as API documentation.",
        default_values=[""],
      ),
      @argparse.OptionArg(
        "language",
        about="HTML language code for generated pages.",
        default_values=[""],
      ),
      @argparse.OptionArg(
        "description",
        about="Site description used in generated metadata.",
        default_values=[""],
      ),
      @argparse.OptionArg(
        "footer",
        about="Markdown-style inline footer content.",
        default_values=[""],
      ),
    ],
  )
  let matches = command.parse(argv=cli_arguments()) catch {
    error => {
      println("\{error}")
      exit_failure(2)
      return
    }
  }
  let config_file = first_value(matches, "config", "")
  if config_file.trim().to_owned() != "" && !is_file(config_file) {
    fail("config file not found: \{config_file}")
    return
  }
  let source = choose_value(
    first_value(matches, "source", ""),
    config_value(config_file, "source"),
    "",
  )
  let output = choose_value(
    first_value(matches, "output", ""),
    config_value(config_file, "output"),
    "dist",
  )
  let title = choose_value(
    first_value(matches, "title", ""),
    config_value(config_file, "title"),
    "MoonDocKit Site",
  )
  let site_url = choose_value(
    first_value(matches, "site-url", ""),
    config_value(config_file, "site_url"),
    "",
  )
  let api_file = choose_value(
    first_value(matches, "api", ""),
    config_value(config_file, "api"),
    "",
  )
  let language = choose_value(
    first_value(matches, "language", ""),
    config_value(config_file, "language"),
    "en",
  )
  let description = choose_value(
    first_value(matches, "description", ""),
    config_value(config_file, "description"),
    "",
  )
  let footer = choose_value(
    first_value(matches, "footer", ""),
    config_value(config_file, "footer"),
    "Generated by `MoonDocKit`",
  )
  let dry_run = flag_enabled(matches, "dry-run")
  let strict = flag_enabled(matches, "strict")
  if source.trim().to_owned() == "" {
    fail("source directory is required; pass --source or set source in config")
    return
  }
  if !path_exists(source) {
    fail("source directory not found: \{source}")
    return
  }
  if !is_directory(source) {
    fail("source path is not a directory: \{source}")
    return
  }
  if api_file.trim().to_owned() != "" && !is_file(api_file) {
    fail("API interface file not found: \{api_file}")
    return
  }
  if path_exists(output) && !is_directory(output) {
    fail("output path exists and is not a directory: \{output}")
    return
  }
  let site : @lib.DocSite = { title, pages: load_pages(source, api_file) }
  let validation = @lib.validate_site(site)
  let diagnostics = @lib.diagnostics_to_text(validation)
  let quality = @lib.evaluate_quality(site)
  if !quality.passed {
    println("MoonDocKit quality gate failed: \{quality.score}")
    println(diagnostics)
    println("hint: fix validation errors before publishing documentation")
    exit_failure(1)
    return
  }
  if strict && diagnostics != "ok" {
    println("MoonDocKit strict validation failed")
    println(diagnostics)
    println("hint: remove warnings or run without --strict for local previews")
    exit_failure(1)
    return
  }
  let options : @lib.SiteOptions = {
    language,
    description: if description.trim().to_owned() == "" {
      title + " documentation"
    } else {
      description
    },
    site_url,
    footer,
  }
  let manifest = @lib.build_site_manifest_with_options(
    site,
    @lib.default_theme(),
    options,
  )
  let report = @lib.inspect_manifest(manifest)
  let written = if dry_run {
    manifest.length()
  } else {
    write_manifest(output, manifest)
  }
  println("MoonDocKit build complete")
  println("source: \{source}")
  println("output: \{output}")
  println("quality: \{quality.score}")
  if dry_run {
    println("dry-run: true")
  }
  if diagnostics != "ok" {
    println("diagnostics:")
    println(diagnostics)
  }
  println("files: \{written}, bytes: \{report.total_bytes}")
}
