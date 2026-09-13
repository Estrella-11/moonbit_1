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
fn choose_theme(name : String) -> @lib.SiteTheme {
  match name.trim().to_owned() {
    "" | "default" => @lib.default_theme()
    "package" => @lib.package_theme()
    "api" | "api-reference" => @lib.api_reference_theme()
    other => {
      fail("unknown theme preset: \{other}; expected default, package, or api")
      @lib.default_theme()
    }
  }
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
fn split_path(path : String) -> (String, String) {
  let mut last = -1
  let mut i = 0
  for ch in path {
    if ch == '/' || ch == '\\' {
      last = i
    }
    i = i + 1
  }
  let dir = StringBuilder()
  let name = StringBuilder()
  let mut j = 0
  for ch in path {
    if j < last {
      dir.write_char(ch)
    } else if j > last {
      name.write_char(ch)
    }
    j = j + 1
  }
  if dir.to_string() == "" {
    (".", name.to_string())
  } else {
    (dir.to_string(), name.to_string())
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
    pages.push({ title: page_stem, slug: page_stem, source: raw[i + 1], })
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
      @argparse.FlagArg(
        "ai-doc",
        about="Generate AI-enhanced API documentation from .mbti file.",
      ),
      @argparse.FlagArg(
        "ai-quality",
        about="Run AI quality assessment on all pages.",
      ),
      @argparse.FlagArg(
        "ai-tests",
        about="Generate AI test stubs from .mbti file.",
      ),
      @argparse.FlagArg(
        "ai-summary",
        about="Generate AI content summaries for all pages.",
      ),
      @argparse.FlagArg(
        "ai-xref",
        about="Generate AI cross-reference map between pages.",
      ),
      @argparse.FlagArg(
        "ai-coverage",
        about="Analyze API documentation coverage gaps.",
      ),
      @argparse.FlagArg(
        "ai-consistency",
        about="Check documentation style and content consistency.",
      ),
      @argparse.FlagArg(
        "ai-seo",
        about="Generate SEO metadata and search optimization report.",
      ),
      @argparse.FlagArg(
        "ai-recommend",
        about="Generate content recommendations and learning paths.",
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
      @argparse.OptionArg(
        "theme",
        about="Theme preset: default, package, or api.",
        default_values=[""],
      ),
      @argparse.OptionArg(
        "doctest-output",
        about="Write runnable MoonBit examples to a test source file.",
        default_values=[""],
      ),
      @argparse.OptionArg(
        "doctest-package",
        about="Package to import in the generated doc test file.",
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
  let theme_name = choose_value(
    first_value(matches, "theme", ""),
    config_value(config_file, "theme"),
    "default",
  )
  let doctest_output = choose_value(
    first_value(matches, "doctest-output", ""),
    config_value(config_file, "doctest_output"),
    "",
  )
  let doctest_package = choose_value(
    first_value(matches, "doctest-package", ""),
    config_value(config_file, "doctest_package"),
    "",
  )
  let dry_run = flag_enabled(matches, "dry-run")
  let strict = flag_enabled(matches, "strict")
  let ai_doc_enabled = flag_enabled(matches, "ai-doc")
  let ai_quality_enabled = flag_enabled(matches, "ai-quality")
  let ai_tests_enabled = flag_enabled(matches, "ai-tests")
  let ai_summary_enabled = flag_enabled(matches, "ai-summary")
  let ai_xref_enabled = flag_enabled(matches, "ai-xref")
  let ai_coverage_enabled = flag_enabled(matches, "ai-coverage")
  let ai_consistency_enabled = flag_enabled(matches, "ai-consistency")
  let ai_seo_enabled = flag_enabled(matches, "ai-seo")
  let ai_recommend_enabled = flag_enabled(matches, "ai-recommend")
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
  let pages = load_pages(source, api_file)
  if ai_doc_enabled && api_file.trim().to_owned() != "" {
    let api_ref = @lib.parse_mbti(read_text_file(api_file))
    let ai_config = @ai.default_ai_config()
    let module_doc = @ai.generate_module_overview(ai_config, api_ref)
    pages.push({
      title: "AI Overview",
      slug: "ai-overview",
      source: @ai.module_overview_to_markdown(module_doc),
    })
    pages.push({
      title: "AI API Reference",
      slug: "ai-api-reference",
      source: @ai.function_docs_to_markdown(module_doc.function_docs),
    })
  }
  let site : @lib.DocSite = { title, pages, }
  if doctest_output != "" {
    let examples : Array[@lib.DocExample] = []
    for page in pages {
      for example in @lib.extract_doc_examples(page.source) {
        examples.push({ index: examples.length(), code: example.code, })
      }
    }
    let test_source = @lib.render_doc_test_file(examples, doctest_package)
    let target = split_path(doctest_output)
    let _ = write_output_directory(target.0, [target.1], [test_source])
    println("doc tests: \{examples.length()} example(s) -> \{doctest_output}")
  }
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
    choose_theme(theme_name),
    options,
  )
  if ai_quality_enabled {
    let ai_config = @ai.default_ai_config()
    let ai_options = @ai.default_quality_options()
    let results = @ai.assess_site_quality(ai_config, site, ai_options)
    let quality_report = StringBuilder()
    quality_report.write_string("# AI Quality Report\n\n")
    let mut idx = 0
    while idx < results.length() {
      let pair = results[idx]
      let page_title = pair.0
      let assessment = pair.1
      quality_report.write_string("## ")
      quality_report.write_string(page_title)
      quality_report.write_string("\n\n")
      quality_report.write_string(@ai.quality_to_markdown(assessment))
      quality_report.write_string("\n\n")
      idx = idx + 1
    }
    manifest.push({
      path: "ai-quality-report.md",
      content: quality_report.to_string(),
    })
  }
  if ai_tests_enabled && api_file.trim().to_owned() != "" {
    let api_ref = @lib.parse_mbti(read_text_file(api_file))
    let ai_config = @ai.default_ai_config()
    let suite = @ai.generate_symbol_tests(ai_config, api_ref)
    let test_code = @ai.tests_to_moonbit(suite)
    manifest.push({ path: "ai-generated-test.mbt", content: test_code, })
  }
  if ai_summary_enabled {
    let summaries = @ai.summarize_site(site)
    let summary_md = @ai.site_summary_to_markdown(title, summaries)
    manifest.push({ path: "ai-site-summary.md", content: summary_md, })
  }
  if ai_quality_enabled {
    let ai_config = @ai.default_ai_config()
    let ai_options = @ai.default_quality_options()
    let assessments = @ai.assess_site_quality(ai_config, site, ai_options)
    let site_report = @ai.aggregate_site_quality(assessments)
    let site_report_md = @ai.site_quality_to_markdown(site_report)
    manifest.push({
      path: "ai-site-quality-report.md",
      content: site_report_md,
    })
  }
  if ai_xref_enabled {
    let xref_report = @ai.detect_cross_references(site)
    let xref_md = @ai.xref_to_markdown(xref_report)
    manifest.push({ path: "ai-cross-reference.md", content: xref_md, })
  }
  if ai_coverage_enabled && api_file.trim().to_owned() != "" {
    let api_ref = @lib.parse_mbti(read_text_file(api_file))
    let coverage = @ai.analyze_coverage(api_ref, site)
    let coverage_md = @ai.coverage_to_markdown(coverage)
    manifest.push({ path: "ai-coverage-report.md", content: coverage_md, })
  }
  if ai_consistency_enabled {
    let consistency = @ai.check_consistency(site)
    let consistency_md = @ai.consistency_to_markdown(consistency)
    manifest.push({ path: "ai-consistency-report.md", content: consistency_md, })
  }
  if ai_seo_enabled {
    let seo = @ai.generate_site_seo(site)
    let seo_md = @ai.seo_to_markdown(seo)
    manifest.push({ path: "ai-seo-report.md", content: seo_md, })
  }
  if ai_recommend_enabled {
    let recs = @ai.generate_recommendations(site)
    let recs_md = @ai.recommendations_to_markdown(recs)
    manifest.push({ path: "ai-recommendations.md", content: recs_md, })
  }
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
  if ai_doc_enabled {
    println("ai-doc: enabled")
  }
  if ai_quality_enabled {
    println("ai-quality: enabled")
  }
  if ai_tests_enabled {
    println("ai-tests: enabled")
  }
  if ai_summary_enabled {
    println("ai-summary: enabled")
  }
  if ai_xref_enabled {
    println("ai-xref: enabled")
  }
  if ai_coverage_enabled {
    println("ai-coverage: enabled")
  }
  if ai_consistency_enabled {
    println("ai-consistency: enabled")
  }
  if ai_seo_enabled {
    println("ai-seo: enabled")
  }
  if ai_recommend_enabled {
    println("ai-recommend: enabled")
  }
  if diagnostics != "ok" {
    println("diagnostics:")
    println(diagnostics)
  }
  println("files: \{written}, bytes: \{report.total_bytes}")
}
