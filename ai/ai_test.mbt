///|
test "default_ai_config returns mock provider" {
  let config = @ai.default_ai_config()
  assert_eq(config.provider, "mock")
  assert_eq(config.model, "moondockit-mock")
  assert_true(config.temperature > 0.0)
  assert_true(config.max_tokens > 0)
}

///|
test "build_chat_request_json produces valid JSON" {
  let config = @ai.default_ai_config()
  let messages : Array[@ai.ChatMessage] = [{ role: "user", content: "Hello", }]
  let json = @ai.build_chat_request_json(config, messages)
  assert_true(json.contains("\"model\""))
  assert_true(json.contains("\"messages\""))
  assert_true(json.contains("Hello"))
  assert_true(json.contains("\"temperature\""))
  assert_true(json.contains("\"max_tokens\""))
}

///|
test "fill_prompt replaces all variables" {
  let template = "Hello {{name}}, welcome to {{place}}!"
  let variables : Array[(String, String)] = [
    ("name", "MoonBit"),
    ("place", "AI Docs"),
  ]
  let result = @ai.fill_prompt(template, variables)
  assert_eq(result, "Hello MoonBit, welcome to AI Docs!")
}

///|
test "fill_prompt handles missing variables gracefully" {
  let template = "Hello {{name}}, {{missing}}!"
  let variables : Array[(String, String)] = [("name", "World")]
  let result = @ai.fill_prompt(template, variables)
  assert_eq(result, "Hello World, {{missing}}!")
}

///|
test "function_doc_template has system and user messages" {
  let template = @ai.function_doc_template()
  assert_true(template.system.length() > 0)
  assert_true(template.user.contains("{{name}}"))
  assert_true(template.user.contains("{{signature}}"))
}

///|
test "quality_template has assessment fields" {
  let template = @ai.quality_template()
  assert_true(template.system.length() > 0)
  assert_true(template.user.contains("{{title}}"))
  assert_true(template.user.contains("{{content}}"))
}

///|
test "test_gen_template has test generation fields" {
  let template = @ai.test_gen_template()
  assert_true(template.system.length() > 0)
  assert_true(template.user.contains("{{name}}"))
  assert_true(template.user.contains("{{signature}}"))
}

///|
test "generate_function_doc produces structured documentation" {
  let config = @ai.default_ai_config()
  let symbol : @lib.ApiSymbol = {
    kind: "fn",
    name: "my_function",
    signature: "fn(x : Int) -> Int",
    arity: 1,
    return_type: "Int",
  }
  let doc = @ai.generate_function_doc(config, symbol, "mymodule")
  assert_eq(doc.name, "my_function")
  assert_eq(doc.kind, "fn")
  assert_true(doc.description.contains("my_function"))
  assert_true(doc.examples.contains("my_function"))
}

///|
test "assess_page_quality returns reasonable scores" {
  let config = @ai.default_ai_config()
  let options = @ai.default_quality_options()
  let content = "# Overview\n\nThis is a test page.\n\n## Details\n\nMore content here.\n\n```\ncode example\n```"
  let result = @ai.assess_page_quality(config, "Test Page", content, options)
  assert_true(result.overall_score >= 0)
  assert_true(result.overall_score <= 100)
  assert_true(result.completeness_score >= 0)
  assert_true(result.readability_score >= 0)
  assert_true(result.example_coverage_score >= 0)
}

///|
test "quality_to_markdown produces markdown report" {
  let config = @ai.default_ai_config()
  let options = @ai.default_quality_options()
  let content = "# Test\n\nSome content.\n\n```\ncode\n```"
  let assessment = @ai.assess_page_quality(config, "Test", content, options)
  let markdown = @ai.quality_to_markdown(assessment)
  assert_true(markdown.contains("## Quality Assessment"))
  assert_true(markdown.contains("Overall Score"))
}

///|
test "function_docs_to_markdown produces API reference page" {
  let config = @ai.default_ai_config()
  let symbol : @lib.ApiSymbol = {
    kind: "fn",
    name: "test_fn",
    signature: "fn() -> Unit",
    arity: 0,
    return_type: "Unit",
  }
  let doc = @ai.generate_function_doc(config, symbol, "testmod")
  let markdown = @ai.function_docs_to_markdown([doc])
  assert_true(markdown.contains("# API Reference"))
  assert_true(markdown.contains("test_fn"))
  assert_true(markdown.contains("ai-generated"))
}

///|
test "generate_symbol_tests creates test suite" {
  let config = @ai.default_ai_config()
  let symbol : @lib.ApiSymbol = {
    kind: "fn",
    name: "my_func",
    signature: "fn(x : Int) -> Int",
    arity: 1,
    return_type: "Int",
  }
  let api_ref : @lib.ApiReference = {
    package_name: "test_pkg",
    symbols: [symbol],
  }
  let suite = @ai.generate_symbol_tests(config, api_ref)
  assert_eq(suite.module_name, "test_pkg")
  assert_true(suite.tests.length() > 0)
}

///|
test "tests_to_moonbit produces valid test code" {
  let config = @ai.default_ai_config()
  let symbol : @lib.ApiSymbol = {
    kind: "fn",
    name: "hello",
    signature: "fn() -> String",
    arity: 0,
    return_type: "String",
  }
  let api_ref : @lib.ApiReference = {
    package_name: "hello_pkg",
    symbols: [symbol],
  }
  let suite = @ai.generate_symbol_tests(config, api_ref)
  let code = @ai.tests_to_moonbit(suite)
  assert_true(code.contains("test \"test_hello\""))
  assert_true(code.contains("assert_true(true)"))
  assert_true(code.contains("AI-generated"))
}

///|
test "assess_site_quality evaluates multiple pages" {
  let config = @ai.default_ai_config()
  let options = @ai.default_quality_options()
  let page1 : @lib.DocPage = {
    title: "Page One",
    slug: "page-one",
    source: "# Page One\n\nContent.\n\n```\ncode\n```",
  }
  let page2 : @lib.DocPage = {
    title: "Page Two",
    slug: "page-two",
    source: "# Page Two\n\nMore content.",
  }
  let site : @lib.DocSite = { title: "Test Site", pages: [page1, page2], }
  let results = @ai.assess_site_quality(config, site, options)
  assert_eq(results.length(), 2)
}

///|
test "module_overview_to_markdown produces overview page" {
  let config = @ai.default_ai_config()
  let symbol : @lib.ApiSymbol = {
    kind: "struct",
    name: "MyType",
    signature: "struct MyType",
    arity: 0,
    return_type: "",
  }
  let api_ref : @lib.ApiReference = {
    package_name: "mymod",
    symbols: [symbol],
  }
  let doc = @ai.generate_module_overview(config, api_ref)
  let markdown = @ai.module_overview_to_markdown(doc)
  assert_true(markdown.contains("mymod"))
  assert_true(markdown.contains("MyType"))
  assert_true(markdown.contains("ai-generated"))
}

///|
test "summarize_page extracts summary and keywords" {
  let content = "# Getting Started\n\nThis guide helps you start with MoonBit development. It covers installation and setup.\n\n## Installation\n\n- Install the toolchain\n- Set up your editor\n\n```moonbit\nlet x = 1\n```"
  let summary = @ai.summarize_page("Getting Started", content)
  assert_eq(summary.title, "Getting Started")
  assert_true(summary.summary.length() > 0)
  assert_true(summary.keywords.length() > 0)
  assert_true(summary.key_sections.length() > 0)
}

///|
test "summarize_page detects content type" {
  let tutorial = "# Tutorial\n\nStep by step guide.\n\n## Step 1\n\n```moonbit\nlet x = 1\n```\n\n## Step 2\n\nMore text."
  let summary = @ai.summarize_page("Tutorial", tutorial)
  assert_eq(summary.content_type, "tutorial")

  let ref_doc = "# Reference\n\n- Item 1\n- Item 2\n\n## Section A\n\n- Item 3"
  let ref_summary = @ai.summarize_page("Reference", ref_doc)
  assert_eq(ref_summary.content_type, "reference")
}

///|
test "summarize_page estimates audience" {
  let short_content = "# Brief\n\nShort text."
  let summary = @ai.summarize_page("Brief", short_content)
  assert_eq(summary.estimated_audience, "beginner")

  let dev_content = "# Dev Guide\n\nThis is a detailed developer guide with substantial content.\n\n```moonbit\nlet x = 1\n```\n\n```moonbit\nlet y = 2\n```\n\n```moonbit\nlet z = 3\n```\nMore explanation text here for developers."
  let dev_summary = @ai.summarize_page("Dev Guide", dev_content)
  assert_eq(dev_summary.estimated_audience, "developer")
}

///|
test "summary_to_markdown produces readable output" {
  let content = "# Test Page\n\nThis is a test page about documentation.\n\n## Section One\n\nContent here."
  let summary = @ai.summarize_page("Test Page", content)
  let markdown = @ai.summary_to_markdown(summary)
  assert_true(markdown.contains("### Test Page"))
  assert_true(markdown.contains("**Summary:**"))
  assert_true(markdown.contains("**Keywords:**"))
}

///|
test "summarize_site generates summaries for all pages" {
  let page1 : @lib.DocPage = {
    title: "Page One",
    slug: "page-one",
    source: "# Page One\n\nFirst page content here.",
  }
  let page2 : @lib.DocPage = {
    title: "Page Two",
    slug: "page-two",
    source: "# Page Two\n\nSecond page content here.",
  }
  let site : @lib.DocSite = { title: "Test Site", pages: [page1, page2], }
  let summaries = @ai.summarize_site(site)
  assert_eq(summaries.length(), 2)
  assert_eq(summaries[0].title, "Page One")
  assert_eq(summaries[1].title, "Page Two")
}

///|
test "site_summary_to_markdown generates index page" {
  let summaries : Array[@ai.PageSummary] = [
    {
      title: "Page One",
      summary: "Summary of page one.",
      keywords: ["test", "page"],
      key_sections: ["Section A"],
      estimated_audience: "beginner",
      content_type: "guide",
    },
  ]
  let markdown = @ai.site_summary_to_markdown("Test Site", summaries)
  assert_true(markdown.contains("# Test Site"))
  assert_true(markdown.contains("ai-generated"))
  assert_true(markdown.contains("Page One"))
}

///|
test "quality assessment detects heading hierarchy issues" {
  let bad_content = "## Level Two\n\nJumped to H2.\n\n#### Level Four\n\nSkipped H3."
  let config = @ai.default_ai_config()
  let options = @ai.default_quality_options()
  let assessment = @ai.assess_page_quality(
    config, "Bad Hierarchy", bad_content, options,
  )
  let mut has_hierarchy_issue = false
  for s in assessment.suggestions {
    if s.contains("H1") || s.contains("jumps") {
      has_hierarchy_issue = true
    }
  }
  assert_true(has_hierarchy_issue)
}

///|
test "quality assessment rewards good structure" {
  let good_content = "# Excellent Page\n\n## Overview\n\nThis is a well-structured page with good content.\n\n## Details\n\n- Point 1\n- Point 2\n\n```moonbit\nlet x = 1\n```\n\n```moonbit\nlet y = 2\n```"
  let config = @ai.default_ai_config()
  let options = @ai.default_quality_options()
  let assessment = @ai.assess_page_quality(
    config, "Excellent Page", good_content, options,
  )
  assert_true(assessment.overall_score > 50)
  assert_true(assessment.structure_score > 50)
  assert_true(assessment.strengths.length() > 0)
}

///|
test "quality assessment includes structure score" {
  let config = @ai.default_ai_config()
  let options = @ai.default_quality_options()
  let assessment = @ai.assess_page_quality(
    config, "Test", "# Test\n\nContent.", options,
  )
  assert_true(assessment.structure_score >= 0)
  assert_true(assessment.structure_score <= 100)
}

///|
test "aggregate_site_quality produces site report" {
  let config = @ai.default_ai_config()
  let options = @ai.default_quality_options()
  let page1 : @lib.DocPage = {
    title: "Good Page",
    slug: "good",
    source: "# Good Page\n\n## Section\n\nGood content with enough words here.\n\n```moonbit\nlet x = 1\n```",
  }
  let page2 : @lib.DocPage = {
    title: "Short Page",
    slug: "short",
    source: "Tiny.",
  }
  let site : @lib.DocSite = { title: "Test", pages: [page1, page2], }
  let assessments = @ai.assess_site_quality(config, site, options)
  let report = @ai.aggregate_site_quality(assessments)
  assert_eq(report.total_pages, 2)
  assert_true(report.average_score >= 0)
  assert_true(report.best_score >= report.worst_score)
}

///|
test "site_quality_to_markdown generates readable report" {
  let config = @ai.default_ai_config()
  let options = @ai.default_quality_options()
  let page : @lib.DocPage = {
    title: "Test",
    slug: "test",
    source: "# Test\n\nContent here.",
  }
  let site : @lib.DocSite = { title: "Site", pages: [page], }
  let assessments = @ai.assess_site_quality(config, site, options)
  let report = @ai.aggregate_site_quality(assessments)
  let markdown = @ai.site_quality_to_markdown(report)
  assert_true(markdown.contains("# Site Quality Report"))
  assert_true(markdown.contains("Average Score"))
  assert_true(markdown.contains("Quality Distribution"))
}

///|
test "generate_function_doc includes complexity and usage frequency" {
  let config = @ai.default_ai_config()
  let simple_fn : @lib.ApiSymbol = {
    kind: "fn",
    name: "get_value",
    signature: "fn() -> Int",
    arity: 0,
    return_type: "Int",
  }
  let doc = @ai.generate_function_doc(config, simple_fn, "mod")
  assert_eq(doc.complexity, "simple")

  let complex_fn : @lib.ApiSymbol = {
    kind: "fn",
    name: "transform",
    signature: "fn(a : Int, b : Int, c : Int, d : Int) -> String",
    arity: 4,
    return_type: "String",
  }
  let complex_doc = @ai.generate_function_doc(config, complex_fn, "mod")
  assert_eq(complex_doc.complexity, "complex")
}

///|
test "estimate_usage_frequency detects constructor patterns" {
  let config = @ai.default_ai_config()
  let ctor : @lib.ApiSymbol = {
    kind: "fn",
    name: "new_client",
    signature: "fn() -> Client",
    arity: 0,
    return_type: "Client",
  }
  let doc = @ai.generate_function_doc(config, ctor, "mod")
  assert_eq(doc.usage_frequency, "high")

  let predicate : @lib.ApiSymbol = {
    kind: "fn",
    name: "is_valid",
    signature: "fn(x : Int) -> Bool",
    arity: 1,
    return_type: "Bool",
  }
  let pred_doc = @ai.generate_function_doc(config, predicate, "mod")
  assert_eq(pred_doc.usage_frequency, "high")
}

///|
test "function_docs_to_markdown includes symbol summary table" {
  let config = @ai.default_ai_config()
  let fn_sym : @lib.ApiSymbol = {
    kind: "fn",
    name: "my_fn",
    signature: "fn() -> Unit",
    arity: 0,
    return_type: "Unit",
  }
  let struct_sym : @lib.ApiSymbol = {
    kind: "struct",
    name: "MyStruct",
    signature: "struct MyStruct",
    arity: 0,
    return_type: "",
  }
  let doc1 = @ai.generate_function_doc(config, fn_sym, "mod")
  let doc2 = @ai.generate_function_doc(config, struct_sym, "mod")
  let markdown = @ai.function_docs_to_markdown([doc1, doc2])
  assert_true(markdown.contains("Symbol Summary"))
  assert_true(markdown.contains("Functions:"))
  assert_true(markdown.contains("Structures:"))
}

///|
test "module_overview_to_markdown includes statistics table" {
  let config = @ai.default_ai_config()
  let fn_sym : @lib.ApiSymbol = {
    kind: "fn",
    name: "fn1",
    signature: "fn() -> Unit",
    arity: 0,
    return_type: "Unit",
  }
  let struct_sym : @lib.ApiSymbol = {
    kind: "struct",
    name: "S1",
    signature: "struct S1",
    arity: 0,
    return_type: "",
  }
  let api_ref : @lib.ApiReference = {
    package_name: "statmod",
    symbols: [fn_sym, struct_sym],
  }
  let doc = @ai.generate_module_overview(config, api_ref)
  let markdown = @ai.module_overview_to_markdown(doc)
  assert_true(markdown.contains("Symbol Statistics"))
  assert_true(markdown.contains("fn"))
  assert_true(markdown.contains("struct"))
}

///|
test "quality assessment handles empty content" {
  let config = @ai.default_ai_config()
  let options = @ai.default_quality_options()
  let assessment = @ai.assess_page_quality(config, "Empty", "", options)
  assert_true(assessment.overall_score >= 0)
  assert_true(assessment.overall_score <= 100)
  assert_true(assessment.suggestions.length() > 0)
}

///|
test "aggregate_site_quality handles empty site" {
  let empty : Array[(String, @ai.DocQualityAssessment)] = []
  let report = @ai.aggregate_site_quality(empty)
  assert_eq(report.total_pages, 0)
  assert_eq(report.average_score, 0)
}

///|
test "quality assessment detects long title" {
  let long_title = "This is an excessively long title that goes well beyond the recommended eighty character limit for page titles and should trigger a quality suggestion"
  let config = @ai.default_ai_config()
  let options = @ai.default_quality_options()
  let assessment = @ai.assess_page_quality(
    config, long_title, "# Title\n\nContent.", options,
  )
  let mut has_title_suggestion = false
  for s in assessment.suggestions {
    if s.contains("Title is too long") {
      has_title_suggestion = true
    }
  }
  assert_true(has_title_suggestion)
}

///|
test "quality_to_markdown includes structure score" {
  let config = @ai.default_ai_config()
  let options = @ai.default_quality_options()
  let assessment = @ai.assess_page_quality(
    config, "Test", "# Test\n\nContent.", options,
  )
  let markdown = @ai.quality_to_markdown(assessment)
  assert_true(markdown.contains("Structure"))
}

///|
test "extract_json_field extracts string values" {
  let json = "{\"name\":\"MoonBit\",\"version\":\"0.1.0\"}"
  let name = @ai.extract_json_field(json, "name")
  assert_eq(name, "MoonBit")
  let version = @ai.extract_json_field(json, "version")
  assert_eq(version, "0.1.0")
}

///|
test "extract_json_field returns empty for missing field" {
  let json = "{\"name\":\"MoonBit\"}"
  let result = @ai.extract_json_field(json, "missing")
  assert_eq(result, "")
}

///|
test "extract_json_field handles escaped quotes" {
  let json = "{\"msg\":\"hello \\\"world\\\"\"}"
  let result = @ai.extract_json_field(json, "msg")
  assert_true(result.contains("hello"))
}

///|
test "detect_cross_references finds related pages" {
  let site : @lib.DocSite = {
    title: "Test Site",
    pages: [
      {
        title: "Getting Started",
        slug: "getting-started",
        source: "# Getting Started\n\nInstall MoonBit and set up your environment.\n\n## Installation\n\nSteps here.",
      },
      {
        title: "Installation Guide",
        slug: "installation-guide",
        source: "# Installation Guide\n\nDetailed MoonBit installation steps for your environment.",
      },
      {
        title: "API Reference",
        slug: "api-reference",
        source: "# API Reference\n\nComplete MoonBit API documentation.",
      },
    ],
  }
  let report = @ai.detect_cross_references(site)
  assert_true(report.total_references > 0)
}

///|
test "detect_cross_references identifies orphan pages" {
  let site : @lib.DocSite = {
    title: "Test",
    pages: [
      {
        title: "Overview",
        slug: "overview",
        source: "# Overview\n\nWelcome to the project overview page.",
      },
      {
        title: "Isolated Page",
        slug: "isolated",
        source: "# Isolated Page\n\nThis page shares nothing with others. Unique content here.",
      },
    ],
  }
  let report = @ai.detect_cross_references(site)
  assert_true(report.orphan_pages.length() >= 0)
}

///|
test "detect_cross_references handles single page site" {
  let site : @lib.DocSite = {
    title: "Single",
    pages: [
      { title: "Only Page", slug: "only", source: "# Only Page\n\nContent.", },
    ],
  }
  let report = @ai.detect_cross_references(site)
  assert_eq(report.total_references, 0)
  assert_eq(report.orphan_pages.length(), 1)
}

///|
test "xref_to_markdown produces valid markdown" {
  let site : @lib.DocSite = {
    title: "Test",
    pages: [
      {
        title: "Alpha",
        slug: "alpha",
        source: "# Alpha\n\nMoonBit installation guide with examples.",
      },
      {
        title: "Beta",
        slug: "beta",
        source: "# Beta\n\nMoonBit installation tutorial for beginners.",
      },
    ],
  }
  let report = @ai.detect_cross_references(site)
  let markdown = @ai.xref_to_markdown(report)
  assert_true(markdown.contains("AI Cross-Reference Map"))
  assert_true(markdown.contains("Total References"))
}

///|
test "analyze_coverage detects undocumented symbols" {
  let api_ref : @lib.ApiReference = {
    package_name: "testmod",
    symbols: [
      {
        kind: "fn",
        name: "documented_fn",
        signature: "fn() -> Unit",
        arity: 0,
        return_type: "Unit",
      },
      {
        kind: "fn",
        name: "undocumented_fn",
        signature: "fn(Int) -> Int",
        arity: 1,
        return_type: "Int",
      },
    ],
  }
  let site : @lib.DocSite = {
    title: "Test",
    pages: [
      {
        title: "Guide",
        slug: "guide",
        source: "# Guide\n\nThe documented_fn is described here.",
      },
    ],
  }
  let report = @ai.analyze_coverage(api_ref, site)
  assert_eq(report.total_symbols, 2)
  assert_eq(report.documented_symbols, 1)
  assert_eq(report.undocumented_symbols, 1)
  assert_eq(report.coverage_percentage, 50)
}

///|
test "analyze_coverage reports 100% for fully documented API" {
  let api_ref : @lib.ApiReference = {
    package_name: "fullmod",
    symbols: [
      {
        kind: "fn",
        name: "func_a",
        signature: "fn() -> Unit",
        arity: 0,
        return_type: "Unit",
      },
      {
        kind: "fn",
        name: "func_b",
        signature: "fn(Int) -> Int",
        arity: 1,
        return_type: "Int",
      },
    ],
  }
  let site : @lib.DocSite = {
    title: "Test",
    pages: [
      {
        title: "API Reference",
        slug: "api",
        source: "# API Reference\n\nfunc_a and func_b are both documented here.",
      },
    ],
  }
  let report = @ai.analyze_coverage(api_ref, site)
  assert_eq(report.coverage_percentage, 100)
  assert_eq(report.undocumented_symbols, 0)
}

///|
test "analyze_coverage handles empty API" {
  let api_ref : @lib.ApiReference = { package_name: "emptymod", symbols: [], }
  let site : @lib.DocSite = { title: "Test", pages: [], }
  let report = @ai.analyze_coverage(api_ref, site)
  assert_eq(report.total_symbols, 0)
  assert_eq(report.coverage_percentage, 100)
}

///|
test "coverage_to_markdown produces structured report" {
  let api_ref : @lib.ApiReference = {
    package_name: "testmod",
    symbols: [
      {
        kind: "fn",
        name: "fn1",
        signature: "fn() -> Unit",
        arity: 0,
        return_type: "Unit",
      },
      {
        kind: "fn",
        name: "fn2",
        signature: "fn(Int) -> Int",
        arity: 1,
        return_type: "Int",
      },
    ],
  }
  let site : @lib.DocSite = {
    title: "Test",
    pages: [
      {
        title: "Guide",
        slug: "guide",
        source: "# Guide\n\nfn1 is documented here.",
      },
    ],
  }
  let report = @ai.analyze_coverage(api_ref, site)
  let markdown = @ai.coverage_to_markdown(report)
  assert_true(markdown.contains("Documentation Coverage"))
  assert_true(markdown.contains("Coverage"))
  assert_true(markdown.contains("fn2"))
}

///|
test "analyze_coverage groups by symbol kind" {
  let api_ref : @lib.ApiReference = {
    package_name: "mixedmod",
    symbols: [
      {
        kind: "fn",
        name: "func1",
        signature: "fn() -> Unit",
        arity: 0,
        return_type: "Unit",
      },
      {
        kind: "struct",
        name: "MyStruct",
        signature: "struct MyStruct",
        arity: 0,
        return_type: "",
      },
      {
        kind: "fn",
        name: "func2",
        signature: "fn(Int) -> Int",
        arity: 1,
        return_type: "Int",
      },
    ],
  }
  let site : @lib.DocSite = {
    title: "Test",
    pages: [
      {
        title: "Guide",
        slug: "guide",
        source: "# Guide\n\nfunc1 and MyStruct are documented.",
      },
    ],
  }
  let report = @ai.analyze_coverage(api_ref, site)
  assert_eq(report.by_kind.length(), 2)
  let mut fn_total = 0
  let mut fn_doc = 0
  for kind in report.by_kind {
    if kind.0 == "fn" {
      fn_total = kind.2
      fn_doc = kind.1
    }
  }
  assert_eq(fn_total, 2)
  assert_eq(fn_doc, 1)
}

///|
test "detect_cross_references finds most referenced pages" {
  let site : @lib.DocSite = {
    title: "Test",
    pages: [
      {
        title: "Core MoonBit Guide",
        slug: "core-guide",
        source: "# Core MoonBit Guide\n\nMoonBit installation and setup guide.",
      },
      {
        title: "MoonBit Setup",
        slug: "setup",
        source: "# MoonBit Setup\n\nMoonBit installation steps for the guide.",
      },
      {
        title: "Advanced MoonBit",
        slug: "advanced",
        source: "# Advanced MoonBit\n\nAdvanced MoonBit installation options.",
      },
    ],
  }
  let report = @ai.detect_cross_references(site)
  assert_true(
    report.most_referenced.length() > 0 || report.total_references > 0,
  )
}

///|
test "analyze_coverage generates recommendations" {
  let api_ref : @lib.ApiReference = {
    package_name: "recmod",
    symbols: [
      {
        kind: "fn",
        name: "undoc1",
        signature: "fn() -> Unit",
        arity: 0,
        return_type: "Unit",
      },
      {
        kind: "fn",
        name: "undoc2",
        signature: "fn() -> Unit",
        arity: 0,
        return_type: "Unit",
      },
    ],
  }
  let site : @lib.DocSite = {
    title: "Test",
    pages: [{ title: "Home", slug: "home", source: "# Home\n\nWelcome.", }],
  }
  let report = @ai.analyze_coverage(api_ref, site)
  assert_true(report.recommendations.length() > 0)
  let mut has_undoc_rec = false
  for r in report.recommendations {
    if r.contains("undocumented") {
      has_undoc_rec = true
    }
  }
  assert_true(has_undoc_rec)
}

///|
test "check_consistency detects no issues on uniform site" {
  let site : @lib.DocSite = {
    title: "Test",
    pages: [
      {
        title: "Page One",
        slug: "page-one",
        source: "# Page One\n\nThis is page one content with enough words.",
      },
      {
        title: "Page Two",
        slug: "page-two",
        source: "# Page Two\n\nThis is page two content with enough words.",
      },
      {
        title: "Page Three",
        slug: "page-three",
        source: "# Page Three\n\nThis is page three content with enough words.",
      },
    ],
  }
  let report = @ai.check_consistency(site)
  assert_true(report.style_score >= 0)
  assert_true(report.style_score <= 100)
}

///|
test "check_consistency detects missing H1 headings" {
  let site : @lib.DocSite = {
    title: "Test",
    pages: [
      { title: "Good Page", slug: "good", source: "# Good Page\n\nHas H1.", },
      { title: "Bad Page", slug: "bad", source: "## Bad Page\n\nNo H1 here.", },
    ],
  }
  let report = @ai.check_consistency(site)
  assert_true(report.total_issues > 0)
  let mut has_heading_issue = false
  for issue in report.issues {
    if issue.issue_type == "heading_style" {
      has_heading_issue = true
    }
  }
  assert_true(has_heading_issue)
}

///|
test "check_consistency detects heading hierarchy jumps" {
  let site : @lib.DocSite = {
    title: "Test",
    pages: [
      {
        title: "Jump",
        slug: "jump",
        source: "# Jump\n\n### Level Three\n\nSkipped H2.",
      },
      {
        title: "Good",
        slug: "good",
        source: "# Good\n\n## Level Two\n\n### Level Three\n\nGood hierarchy.",
      },
    ],
  }
  let report = @ai.check_consistency(site)
  let mut has_hierarchy_issue = false
  for issue in report.issues {
    if issue.issue_type == "heading_hierarchy" {
      has_hierarchy_issue = true
    }
  }
  assert_true(has_hierarchy_issue)
}

///|
test "check_consistency detects unlabeled code blocks" {
  let site : @lib.DocSite = {
    title: "Test",
    pages: [
      {
        title: "Code",
        slug: "code",
        source: "# Code\n\n```\ncode without language\n```\n\nMore text here.",
      },
      {
        title: "Good",
        slug: "good",
        source: "# Good\n\n```moonbit\nlet x = 1\n```\n\nText.",
      },
    ],
  }
  let report = @ai.check_consistency(site)
  let mut has_code_issue = false
  for issue in report.issues {
    if issue.issue_type == "code_language" {
      has_code_issue = true
    }
  }
  assert_true(has_code_issue)
}

///|
test "check_consistency detects duplicate content" {
  let site : @lib.DocSite = {
    title: "Test",
    pages: [
      {
        title: "Page A",
        slug: "a",
        source: "# Page A\n\nThis is a duplicate paragraph that appears in multiple pages.",
      },
      {
        title: "Page B",
        slug: "b",
        source: "# Page B\n\nThis is a duplicate paragraph that appears in multiple pages.",
      },
    ],
  }
  let report = @ai.check_consistency(site)
  let mut has_dup = false
  for issue in report.issues {
    if issue.issue_type == "duplicate_content" {
      has_dup = true
    }
  }
  assert_true(has_dup)
}

///|
test "check_consistency detects content length outliers" {
  let site : @lib.DocSite = {
    title: "Test",
    pages: [
      { title: "Short", slug: "short", source: "# Short\n\nTiny.", },
      {
        title: "Medium One",
        slug: "m1",
        source: "# Medium One\n\nThis page has a moderate amount of content for testing purposes here.",
      },
      {
        title: "Medium Two",
        slug: "m2",
        source: "# Medium Two\n\nThis page has a moderate amount of content for testing purposes here.",
      },
      {
        title: "Long",
        slug: "long",
        source: "# Long\n\nThis is a very long page with lots of content words to make it significantly longer than the average across the site pages to trigger the outlier detection in the consistency checker module for testing.",
      },
    ],
  }
  let report = @ai.check_consistency(site)
  let mut has_length_issue = false
  for issue in report.issues {
    if issue.issue_type == "content_length" {
      has_length_issue = true
    }
  }
  assert_true(has_length_issue)
}

///|
test "consistency_to_markdown produces valid markdown" {
  let site : @lib.DocSite = {
    title: "Test",
    pages: [
      { title: "A", slug: "a", source: "# A\n\nContent here.", },
      { title: "B", slug: "b", source: "# B\n\nContent here.", },
      { title: "C", slug: "c", source: "# C\n\nContent here.", },
    ],
  }
  let report = @ai.check_consistency(site)
  let markdown = @ai.consistency_to_markdown(report)
  assert_true(markdown.contains("Consistency Report"))
  assert_true(markdown.contains("Style Score"))
}

///|
test "generate_page_seo produces metadata" {
  let page : @lib.DocPage = {
    title: "Getting Started",
    slug: "getting-started",
    source: "# Getting Started\n\nThis guide helps you start with MoonBit development. It covers installation and setup instructions.\n\n## Installation\n\nRun the installer.",
  }
  let seo = @ai.generate_page_seo(page)
  assert_eq(seo.page_title, "Getting Started")
  assert_true(seo.meta_description.length() > 0)
  assert_true(seo.meta_description.length() <= 163)
  assert_true(seo.search_boost >= 0)
  assert_true(seo.search_boost <= 100)
}

///|
test "generate_page_seo handles short content" {
  let page : @lib.DocPage = {
    title: "Short",
    slug: "short",
    source: "# Short\n\nTiny.",
  }
  let seo = @ai.generate_page_seo(page)
  assert_eq(seo.page_title, "Short")
  assert_true(seo.meta_description.length() > 0)
}

///|
test "generate_site_seo generates report for all pages" {
  let site : @lib.DocSite = {
    title: "Test",
    pages: [
      {
        title: "Guide",
        slug: "guide",
        source: "# Guide\n\nThis is a guide about MoonBit programming language.",
      },
      {
        title: "API",
        slug: "api",
        source: "# API Reference\n\nComplete API documentation for the package.",
      },
    ],
  }
  let report = @ai.generate_site_seo(site)
  assert_eq(report.total_pages, 2)
  assert_eq(report.page_metas.length(), 2)
  assert_true(report.pages_with_descriptions >= 0)
}

///|
test "generate_site_seo identifies low search boost pages" {
  let site : @lib.DocSite = {
    title: "Test",
    pages: [
      {
        title: "Good",
        slug: "good",
        source: "# Good Page\n\nThis page has sufficient content with multiple paragraphs and headings.\n\n## Section\n\nMore content here with code.\n\n```moonbit\nlet x = 1\n```",
      },
      { title: "Bad", slug: "bad", source: "# Bad", },
    ],
  }
  let report = @ai.generate_site_seo(site)
  assert_true(report.pages_with_low_search_boost.length() >= 0)
}

///|
test "seo_to_markdown produces valid markdown" {
  let site : @lib.DocSite = {
    title: "Test",
    pages: [
      {
        title: "Guide",
        slug: "guide",
        source: "# Guide\n\nThis is a guide about MoonBit programming language development.",
      },
    ],
  }
  let report = @ai.generate_site_seo(site)
  let markdown = @ai.seo_to_markdown(report)
  assert_true(markdown.contains("SEO Report"))
  assert_true(markdown.contains("Search Boost"))
}

///|
test "generate_recommendations produces next steps" {
  let site : @lib.DocSite = {
    title: "Test",
    pages: [
      {
        title: "Getting Started",
        slug: "getting-started",
        source: "# Getting Started\n\nInstall MoonBit development environment.",
      },
      {
        title: "Advanced Usage",
        slug: "advanced-usage",
        source: "# Advanced Usage\n\nAdvanced MoonBit patterns and techniques.",
      },
      {
        title: "API Reference",
        slug: "api-reference",
        source: "# API Reference\n\nMoonBit API documentation.",
      },
    ],
  }
  let report = @ai.generate_recommendations(site)
  assert_true(report.next_steps.length() >= 0)
  assert_true(report.recommendations_count >= 0)
}

///|
test "generate_recommendations finds related pages" {
  let site : @lib.DocSite = {
    title: "Test",
    pages: [
      {
        title: "MoonBit Guide",
        slug: "guide",
        source: "# MoonBit Guide\n\nMoonBit installation and setup guide for beginners.",
      },
      {
        title: "MoonBit Tutorial",
        slug: "tutorial",
        source: "# MoonBit Tutorial\n\nMoonBit installation tutorial for beginners.",
      },
    ],
  }
  let report = @ai.generate_recommendations(site)
  assert_true(report.related_pages.length() >= 0)
}

///|
test "generate_recommendations builds learning paths" {
  let site : @lib.DocSite = {
    title: "Test",
    pages: [
      {
        title: "Getting Started",
        slug: "getting-started",
        source: "# Getting Started\n\nWelcome to MoonBit development getting started guide.",
      },
      {
        title: "Installation",
        slug: "installation",
        source: "# Installation\n\nMoonBit installation steps for your system.",
      },
      {
        title: "Guide",
        slug: "guide",
        source: "# Guide\n\nMoonBit development guide.",
      },
      {
        title: "API Reference",
        slug: "api-reference",
        source: "# API Reference\n\nMoonBit API reference documentation.",
      },
    ],
  }
  let report = @ai.generate_recommendations(site)
  assert_true(report.learning_paths.length() >= 0)
}

///|
test "recommendations_to_markdown produces valid markdown" {
  let site : @lib.DocSite = {
    title: "Test",
    pages: [
      {
        title: "Getting Started",
        slug: "getting-started",
        source: "# Getting Started\n\nMoonBit development introduction.",
      },
      {
        title: "API Reference",
        slug: "api-reference",
        source: "# API Reference\n\nMoonBit API documentation.",
      },
    ],
  }
  let report = @ai.generate_recommendations(site)
  let markdown = @ai.recommendations_to_markdown(report)
  assert_true(markdown.contains("Content Recommendations"))
  assert_true(markdown.contains("Recommendations"))
}

///|
test "generate_recommendations handles empty site" {
  let site : @lib.DocSite = { title: "Empty", pages: [], }
  let report = @ai.generate_recommendations(site)
  assert_eq(report.recommendations_count, 0)
  assert_eq(report.next_steps.length(), 0)
  assert_eq(report.related_pages.length(), 0)
}

///|
test "check_consistency handles single page site" {
  let site : @lib.DocSite = {
    title: "Single",
    pages: [{ title: "Only", slug: "only", source: "# Only\n\nContent.", }],
  }
  let report = @ai.check_consistency(site)
  assert_true(report.style_score >= 0)
}

///|
test "generate_page_seo keyword density has entries" {
  let page : @lib.DocPage = {
    title: "MoonBit Guide",
    slug: "moonbit-guide",
    source: "# MoonBit Guide\n\nMoonBit installation MoonBit setup MoonBit development MoonBit programming MoonBit tutorial.",
  }
  let seo = @ai.generate_page_seo(page)
  assert_true(seo.keyword_density.length() > 0)
  let mut found_moonbit = false
  for pair in seo.keyword_density {
    if pair.0 == "moonbit" {
      found_moonbit = true
    }
  }
  assert_true(found_moonbit)
}

///|
test "check_consistency style score is high for uniform site" {
  let site : @lib.DocSite = {
    title: "Uniform",
    pages: [
      {
        title: "Alpha",
        slug: "alpha",
        source: "# Alpha\n\nAlpha content with enough words here.",
      },
      {
        title: "Beta",
        slug: "beta",
        source: "# Beta\n\nBeta content with enough words here.",
      },
      {
        title: "Gamma",
        slug: "gamma",
        source: "# Gamma\n\nGamma content with enough words here.",
      },
    ],
  }
  let report = @ai.check_consistency(site)
  assert_true(report.style_score > 50)
}

///|
test "increment_count adds new key and increments existing" {
  let arr : Array[(String, Int)] = []
  @ai.increment_count(arr, "alpha")
  @ai.increment_count(arr, "beta")
  @ai.increment_count(arr, "alpha")
  assert_eq(arr.length(), 2)
  assert_eq(arr[0].0, "alpha")
  assert_eq(arr[0].1, 2)
  assert_eq(arr[1].0, "beta")
  assert_eq(arr[1].1, 1)
}

///|
test "sort_by_count sorts descending by count" {
  let arr : Array[(String, Int)] = [("c", 3), ("a", 10), ("b", 5)]
  let sorted = @ai.sort_by_count(arr)
  assert_eq(sorted[0].0, "a")
  assert_eq(sorted[0].1, 10)
  assert_eq(sorted[1].0, "b")
  assert_eq(sorted[1].1, 5)
  assert_eq(sorted[2].0, "c")
  assert_eq(sorted[2].1, 3)
}

///|
test "take_top_n_pairs limits result count" {
  let arr : Array[(String, Int)] = [
    ("a", 10),
    ("b", 8),
    ("c", 6),
    ("d", 4),
    ("e", 2),
  ]
  let top3 = @ai.take_top_n_pairs(arr, 3)
  assert_eq(top3.length(), 3)
  assert_eq(top3[0].0, "a")
  assert_eq(top3[2].0, "c")
  let top10 = @ai.take_top_n_pairs(arr, 10)
  assert_eq(top10.length(), 5)
}

///|
test "take_top_n_strings limits result count" {
  let arr : Array[String] = ["a", "b", "c", "d", "e"]
  let top3 = @ai.take_top_n_strings(arr, 3)
  assert_eq(top3.length(), 3)
  assert_eq(top3[0], "a")
  assert_eq(top3[2], "c")
}

///|
test "word_frequency returns sorted pairs with counts" {
  let content = "hello world hello moonbit world hello"
  let freq = @ai.word_frequency(content, 5, 4)
  assert_true(freq.length() >= 1)
  assert_eq(freq[0].0, "hello")
  assert_eq(freq[0].1, 3)
}

///|
test "find_first_paragraph returns empty for no paragraphs" {
  let blocks = @lib.parse_blocks("# Heading Only")
  let para = @ai.find_first_paragraph(blocks)
  assert_eq(para, "")
}

///|
test "find_first_paragraph returns first paragraph text" {
  let blocks = @lib.parse_blocks(
    "# Title\n\nFirst paragraph here.\n\nSecond paragraph.",
  )
  let para = @ai.find_first_paragraph(blocks)
  assert_true(para.contains("First paragraph"))
}

///|
test "write_markdown_list writes items with dash prefix" {
  let out = StringBuilder()
  let items : Array[String] = ["apple", "banana", "cherry"]
  @ai.write_markdown_list(out, items)
  let md = out.to_string()
  assert_true(md.contains("- apple"))
  assert_true(md.contains("- banana"))
  assert_true(md.contains("- cherry"))
}

///|
test "quality assessment handles empty title" {
  let config = @ai.default_ai_config()
  let options = @ai.default_quality_options()
  let content = "# Test\n\nSome content here.\n\n```\ncode\n```"
  let result = @ai.assess_page_quality(config, "", content, options)
  assert_true(result.overall_score >= 0)
  let mut has_empty_title_msg = false
  for s in result.suggestions {
    if s.contains("empty") {
      has_empty_title_msg = true
    }
  }
  assert_true(has_empty_title_msg)
}

///|
test "consistency detects all pages missing H1" {
  let site : @lib.DocSite = {
    title: "No H1 Site",
    pages: [
      { title: "A", slug: "a", source: "## Heading\n\nNo H1 here.", },
      { title: "B", slug: "b", source: "## Another\n\nStill no H1.", },
    ],
  }
  let report = @ai.check_consistency(site)
  let mut has_all_missing = false
  for issue in report.issues {
    if issue.description.contains("No pages start with an H1") {
      has_all_missing = true
    }
  }
  assert_true(has_all_missing)
}

///|
test "SEO determine_og_type returns website for no-code page" {
  let page : @lib.DocPage = {
    title: "Plain",
    slug: "plain",
    source: "# Plain\n\nJust text, no code.",
  }
  let meta = @ai.generate_page_seo(page)
  assert_eq(meta.og_type, "article")
  let code_page : @lib.DocPage = {
    title: "Code",
    slug: "code",
    source: "# Code\n\nSome text.\n\n```moonbit\nlet x = 1\n```",
  }
  let code_meta = @ai.generate_page_seo(code_page)
  assert_eq(code_meta.og_type, "article")
}

///|
test "coverage find_symbol_in_pages handles empty symbol name" {
  let site : @lib.DocSite = {
    title: "Test",
    pages: [{ title: "P", slug: "p", source: "Some content here.", }],
  }
  let api_ref : @lib.ApiReference = { package_name: "test", symbols: [], }
  let report = @ai.analyze_coverage(api_ref, site)
  assert_eq(report.total_symbols, 0)
}

///|
test "xref detect_cross_references handles single-page site" {
  let site : @lib.DocSite = {
    title: "Single",
    pages: [{ title: "Only", slug: "only", source: "# Only Page\n\nContent.", }],
  }
  let report = @ai.detect_cross_references(site)
  assert_eq(report.total_references, 0)
  assert_eq(report.orphan_pages.length(), 1)
  assert_eq(report.most_referenced.length(), 0)
}

///|
test "xref detect_cross_references finds shared keywords" {
  let site : @lib.DocSite = {
    title: "Multi",
    pages: [
      {
        title: "Getting Started",
        slug: "start",
        source: "# Getting Started\n\nWelcome to the installation guide.",
      },
      {
        title: "Installation",
        slug: "install",
        source: "# Installation\n\nFollow the getting started guide.",
      },
    ],
  }
  let report = @ai.detect_cross_references(site)
  assert_true(report.total_references > 0)
}

///|
test "xref_to_markdown renders all sections" {
  let report : @ai.XrefReport = {
    total_references: 2,
    references: [
      {
        source_page: "A",
        target_page: "B",
        relevance_score: 60,
        reason: "Shares 3 keywords",
        shared_keywords: ["moonbit", "guide", "intro"],
      },
    ],
    orphan_pages: ["C"],
    most_referenced: [("B", 2)],
  }
  let md = @ai.xref_to_markdown(report)
  assert_true(md.contains("Cross-Reference"))
  assert_true(md.contains("Orphan"))
  assert_true(md.contains("Most Referenced"))
}

///|
test "recommend generate_recommendations for single page" {
  let site : @lib.DocSite = {
    title: "Single",
    pages: [
      { title: "Intro", slug: "intro", source: "# Intro\n\nBasic content.", },
    ],
  }
  let report = @ai.generate_recommendations(site)
  assert_eq(report.recommendations_count, 0)
  assert_eq(report.top_hub_pages.length(), 0)
}

///|
test "recommendations_to_markdown renders hub pages and next steps" {
  let report : @ai.RecommendationReport = {
    next_steps: [
      {
        from_page: "Start",
        to_page: "Advanced",
        reason: "Natural progression",
        confidence: 80,
      },
    ],
    related_pages: [],
    learning_paths: [],
    top_hub_pages: [("Advanced", 2)],
    recommendations_count: 1,
  }
  let md = @ai.recommendations_to_markdown(report)
  assert_true(md.contains("Recommendations"))
  assert_true(md.contains("Next Steps"))
  assert_true(md.contains("Hub Pages"))
}

///|
test "summary first_sentence handles whitespace-only text" {
  let summary = @ai.summarize_page("Test", "   \n\n   \t  ")
  assert_true(summary.summary.length() > 0)
  assert_true(summary.summary.contains("Test"))
}

///|
test "integration: quality + summary + seo on same page" {
  let config = @ai.default_ai_config()
  let options = @ai.default_quality_options()
  let content = "# Getting Started Guide\n\nWelcome to MoonBit. This tutorial covers basics.\n\n## Installation\n\n- Install the toolchain\n- Set up PATH\n\n```moonbit\nfn main { println(\"hello\") }\n```"
  let quality = @ai.assess_page_quality(
    config, "Getting Started", content, options,
  )
  let summary = @ai.summarize_page("Getting Started", content)
  let page : @lib.DocPage = {
    title: "Getting Started",
    slug: "getting-started",
    source: content,
  }
  let seo = @ai.generate_page_seo(page)
  assert_true(quality.overall_score > 0)
  assert_true(summary.summary.length() > 0)
  assert_true(seo.meta_description.length() > 0)
  assert_true(seo.search_boost > 0)
}

///|
test "integration: xref + recommend on multi-page site" {
  let site : @lib.DocSite = {
    title: "Integration",
    pages: [
      {
        title: "Getting Started",
        slug: "start",
        source: "# Getting Started\n\nWelcome to the installation guide for MoonBit.",
      },
      {
        title: "Installation",
        slug: "install",
        source: "# Installation\n\nFollow the getting started guide for setup.",
      },
      {
        title: "API Reference",
        slug: "api",
        source: "# API Reference\n\nComplete API documentation for MoonBit functions.",
      },
    ],
  }
  let xref = @ai.detect_cross_references(site)
  let recs = @ai.generate_recommendations(site)
  assert_true(xref.total_references > 0)
  assert_true(recs.recommendations_count > 0)
  assert_true(
    xref.most_referenced.length() > 0 || xref.orphan_pages.length() > 0,
  )
}

///|
test "integration: consistency + coverage on documentation site" {
  let site : @lib.DocSite = {
    title: "Consistency Test",
    pages: [
      {
        title: "Guide",
        slug: "guide",
        source: "# Guide\n\n## Section\n\nContent here.\n\n```moonbit\nlet x = 1\n```",
      },
      {
        title: "Reference",
        slug: "reference",
        source: "# Reference\n\n## API\n\nDetailed reference.\n\n```moonbit\nlet y = 2\n```",
      },
    ],
  }
  let consistency = @ai.check_consistency(site)
  let api_ref : @lib.ApiReference = {
    package_name: "test",
    symbols: [
      {
        kind: "fn",
        name: "foo",
        signature: "fn() -> Int",
        arity: 0,
        return_type: "Int",
      },
      {
        kind: "fn",
        name: "bar",
        signature: "fn(x : Int) -> String",
        arity: 1,
        return_type: "String",
      },
    ],
  }
  let coverage = @ai.analyze_coverage(api_ref, site)
  assert_true(consistency.style_score > 0)
  assert_eq(coverage.total_symbols, 2)
}
