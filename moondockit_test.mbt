///|
test "html_escape protects generated pages" {
  inspect(
    @moondockit.html_escape("<script>alert('x') & \"y\"</script>"),
    content="&lt;script&gt;alert(&#39;x&#39;) &amp; &quot;y&quot;&lt;/script&gt;",
  )
}

///|
test "slugify keeps stable ascii anchors" {
  inspect(
    @moondockit.slugify("MoonBit Docs: Quick Start!"),
    content="moonbit-docs-quick-start",
  )
  inspect(@moondockit.slugify("  API   Reference  "), content="api-reference")
}

///|
test "render_markdown supports the first block set" {
  let html = @moondockit.render_markdown(
    "# Intro\n\nA <safe> paragraph.\n\n- fast\n- typed\n\n> reusable\n\n```\nlet x = 1 < 2\n```",
  )
  assert_true(html.contains("<h1 id=\"intro\">Intro</h1>"))
  assert_true(html.contains("<p>A &lt;safe&gt; paragraph.</p>"))
  assert_true(html.contains("<ul>\n<li>fast</li>\n<li>typed</li>\n</ul>"))
  assert_true(html.contains("<blockquote>reusable</blockquote>"))
  assert_true(html.contains("let x = 1 &lt; 2"))
}

///|
test "render_markdown supports inline code strong and links" {
  let html = @moondockit.render_markdown(
    "Use `moon test`, read **safe docs**, and open [MoonBit](https://www.moonbitlang.com).",
  )
  assert_true(html.contains("<code>moon test</code>"))
  assert_true(html.contains("<strong>safe docs</strong>"))
  assert_true(
    html.contains("<a href=\"https://www.moonbitlang.com\">MoonBit</a>"),
  )
}

///|
test "render_markdown supports emphasis inside inline content" {
  let html = @moondockit.render_markdown(
    "Write *focused docs* and **ship *reviewable* pages**.",
  )
  assert_true(html.contains("<em>focused docs</em>"))
  assert_true(html.contains("<strong>ship <em>reviewable</em> pages</strong>"))
}

///|
test "render_markdown supports safe image syntax" {
  let html = @moondockit.render_markdown(
    "Preview ![MoonBit <logo>](./assets/logo.png) and block ![bad](javascript:alert(1)).",
  )
  assert_true(
    html.contains("<img src=\"./assets/logo.png\" alt=\"MoonBit &lt;logo&gt;\">"),
  )
  assert_true(html.contains("<img src=\"#\" alt=\"bad\">"))
}

///|
test "render_markdown escapes inline text and blocks unsafe links" {
  let html = @moondockit.render_markdown(
    "Click [bad <link>](javascript:alert(1)) and keep `<raw>` safe.",
  )
  assert_true(html.contains("<a href=\"#\">bad &lt;link&gt;</a>"))
  assert_true(html.contains("<code>&lt;raw&gt;</code>"))
}

///|
test "extract_toc ignores code fences" {
  let toc = @moondockit.extract_toc(
    "# Guide\n\n## Install\n\n```\n# Not a heading\n```\n## Usage",
  )
  inspect(toc.length(), content="3")
  inspect(toc[0].anchor, content="guide")
  inspect(toc[1].title, content="Install")
  inspect(toc[2].anchor, content="usage")
}

///|
test "headings receive unique anchors" {
  let blocks = @moondockit.parse_blocks("# Intro\n\n## Intro\n\n# Intro")
  let headings = @moondockit.extract_headings(blocks)
  inspect(headings.length(), content="3")
  inspect(headings[0].anchor, content="intro")
  inspect(headings[1].anchor, content="intro-2")
  inspect(headings[2].anchor, content="intro-3")
  let html = @moondockit.render_blocks(blocks)
  assert_true(html.contains("<h1 id=\"intro\">Intro</h1>"))
  assert_true(html.contains("<h2 id=\"intro-2\">Intro</h2>"))
  assert_true(html.contains("<h1 id=\"intro-3\">Intro</h1>"))
}

///|
test "parse_document reads simple front matter" {
  let doc = @moondockit.parse_document(
    "---\ntitle: \"Quick Start\"\norder: 12\ntags: [guide, moonbit]\nlayout: docs\n---\n# Quick Start\n\nBody",
  )
  match doc.front_matter.title {
    Some(title) => inspect(title, content="Quick Start")
    None => fail("expected title")
  }
  match doc.front_matter.order {
    Some(order) => inspect(order, content="12")
    None => fail("expected order")
  }
  inspect(doc.front_matter.tags.length(), content="2")
  inspect(doc.front_matter.tags[1], content="moonbit")
  inspect(doc.front_matter.fields.length(), content="4")
  inspect(doc.blocks.length(), content="2")
  match doc.blocks[0] {
    Heading(_, title) => inspect(title, content="Quick Start")
    _ => fail("expected body heading")
  }
}

///|
test "parse_document ignores unclosed front matter" {
  let doc = @moondockit.parse_document("---\ntitle: Draft\n# Still body")
  match doc.front_matter.title {
    None => ()
    Some(_) => fail("expected no title")
  }
  inspect(doc.blocks.length(), content="2")
  assert_true(@moondockit.render_blocks(doc.blocks).contains("title: Draft"))
}

///|
test "plan_routes uses front matter and stable ordering" {
  let intro : @moondockit.DocPage = {
    title: "Fallback Intro",
    slug: "",
    source: "---\ntitle: Intro\norder: 2\ntags: [guide]\n---\n# Intro",
  }
  let api : @moondockit.DocPage = {
    title: "API",
    slug: "api",
    source: "---\norder: 1\ntags: [reference, moonbit]\n---\n# API",
  }
  let changelog : @moondockit.DocPage = {
    title: "Changelog",
    slug: "changelog",
    source: "# Changelog",
  }
  let site : @moondockit.DocSite = {
    title: "Docs",
    pages: [intro, changelog, api],
  }
  let routes = @moondockit.plan_routes(site)
  inspect(routes.length(), content="3")
  inspect(routes[0].title, content="API")
  inspect(routes[0].path, content="api.html")
  inspect(routes[0].tags[1], content="moonbit")
  inspect(routes[1].title, content="Intro")
  inspect(routes[1].slug, content="intro")
  inspect(routes[2].title, content="Changelog")
}

///|
test "build_site_manifest returns deterministic output files" {
  let intro : @moondockit.DocPage = {
    title: "Intro",
    slug: "",
    source: "---\ntitle: Intro\norder: 2\n---\n# Intro",
  }
  let api : @moondockit.DocPage = {
    title: "API",
    slug: "api",
    source: "---\norder: 1\n---\n# API",
  }
  let site : @moondockit.DocSite = { title: "Docs", pages: [intro, api] }
  let files = @moondockit.build_site_manifest(site)
  inspect(files.length(), content="7")
  inspect(files[0].path, content="api.html")
  inspect(files[1].path, content="index.html")
  inspect(files[2].path, content="intro.html")
  inspect(files[3].path, content="robots.txt")
  assert_true(
    files.filter(file => file.path == "search-index.json").length() == 1,
  )
  assert_true(
    files.filter(file => file.path == "site-manifest.json").length() == 1,
  )
  assert_true(files.filter(file => file.path == "sitemap.xml").length() == 1)
  assert_true(files[2].content.contains("<title>Intro - Docs</title>"))
  assert_true(files[2].content.contains("<a href=\"api.html\">API</a>"))
  assert_true(files[1].content.contains("url=api.html"))
  let manifest = files.filter(file => file.path == "site-manifest.json")[0]
  assert_true(manifest.content.contains("\"file_count\": 6"))
  assert_true(manifest.content.contains("\"path\":\"api.html\""))
}

///|
test "custom themes change generated page style" {
  let page : @moondockit.DocPage = {
    title: "Guide",
    slug: "guide",
    source: "# Guide\n\nShip docs.",
  }
  let site : @moondockit.DocSite = { title: "Docs", pages: [page] }
  let theme : @moondockit.SiteTheme = {
    background: "#111111",
    surface: "#fafafa",
    text: "#222222",
    accent: "#008a7a",
    border: "#cccccc",
    code_background: "#202020",
    code_text: "#f6f6f6",
    sidebar_width_px: 280,
    content_width_px: 900,
  }
  let rendered = @moondockit.render_page_with_theme(site, page, theme)
  assert_true(rendered.html.contains("background:#111111"))
  assert_true(rendered.html.contains("color:#008a7a"))
  assert_true(rendered.html.contains("width:280px"))
  assert_true(rendered.html.contains("max-width:900px"))
}

///|
test "site options add page metadata and footer" {
  let page : @moondockit.DocPage = {
    title: "guide",
    slug: "guide",
    source: "---\ntitle: Guide\n---\n# Guide\n\nShip docs.",
  }
  let site : @moondockit.DocSite = { title: "Docs", pages: [page] }
  let options : @moondockit.SiteOptions = {
    language: "zh-CN",
    description: "MoonBit docs <site>",
    site_url: "https://docs.example/moondockit/",
    footer: "Built with `MoonDocKit`",
  }
  let rendered = @moondockit.render_page_with_options(
    site,
    page,
    @moondockit.default_theme(),
    options,
  )
  assert_true(rendered.html.contains("<html lang=\"zh-CN\">"))
  assert_true(rendered.html.contains("<title>Guide - Docs</title>"))
  assert_true(
    rendered.html.contains(
      "<meta name=\"description\" content=\"MoonBit docs &lt;site&gt;\">",
    ),
  )
  assert_true(
    rendered.html.contains(
      "<meta property=\"og:title\" content=\"Guide - Docs\">",
    ),
  )
  assert_true(
    rendered.html.contains(
      "<meta property=\"og:description\" content=\"MoonBit docs &lt;site&gt;\">",
    ),
  )
  assert_true(
    rendered.html.contains(
      "<link rel=\"canonical\" href=\"https://docs.example/moondockit/guide.html\">",
    ),
  )
  assert_true(
    rendered.html.contains(
      "<meta property=\"og:url\" content=\"https://docs.example/moondockit/guide.html\">",
    ),
  )
  assert_true(
    rendered.html.contains(
      "<footer>Built with <code>MoonDocKit</code></footer>",
    ),
  )
}

///|
test "site options sanitize invalid language values" {
  let page : @moondockit.DocPage = {
    title: "Guide",
    slug: "guide",
    source: "# Guide",
  }
  let site : @moondockit.DocSite = { title: "Docs", pages: [page] }
  let options : @moondockit.SiteOptions = {
    language: "zh_CN<script>",
    description: "",
    site_url: "javascript:alert(1)",
    footer: "",
  }
  let rendered = @moondockit.render_page_with_options(
    site,
    page,
    @moondockit.default_theme(),
    options,
  )
  assert_true(rendered.html.contains("<html lang=\"en\">"))
  assert_false(rendered.html.contains("<footer>"))
  assert_false(rendered.html.contains("description"))
  assert_false(rendered.html.contains("canonical"))
  assert_false(rendered.html.contains("og:url"))
}

///|
test "build_search_index serializes searchable page text" {
  let page : @moondockit.DocPage = {
    title: "Guide",
    slug: "guide",
    source: "---\ntags: [docs, moonbit]\n---\n# Guide\n\nUse \"safe\" docs.\n\n- fast",
  }
  let site : @moondockit.DocSite = { title: "Docs", pages: [page] }
  let entries = @moondockit.collect_search_entries(site)
  inspect(entries.length(), content="1")
  inspect(entries[0].path, content="guide.html")
  assert_true(entries[0].text.contains("Use \"safe\" docs."))
  let json = @moondockit.build_search_index(site)
  assert_true(json.contains("\"path\":\"guide.html\""))
  assert_true(json.contains("Use \\\"safe\\\" docs."))
  assert_true(json.contains("\"tags\":[\"docs\",\"moonbit\"]"))
}

///|
test "build_sitemap serializes sorted page routes" {
  let intro : @moondockit.DocPage = {
    title: "Intro",
    slug: "intro",
    source: "---\norder: 2\n---\n# Intro",
  }
  let api : @moondockit.DocPage = {
    title: "API",
    slug: "api",
    source: "---\norder: 1\n---\n# API",
  }
  let sitemap = @moondockit.build_sitemap({ title: "Docs", pages: [intro, api] })
  assert_true(sitemap.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
  assert_true(
    sitemap.contains(
      "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">",
    ),
  )
  assert_true(sitemap.contains("<loc>api.html</loc>"))
  assert_true(sitemap.contains("<loc>intro.html</loc>"))
}

///|
test "build_robots_txt allows crawlers and references sitemap" {
  let robots = @moondockit.build_robots_txt()
  assert_true(robots.contains("User-agent: *"))
  assert_true(robots.contains("Allow: /"))
  assert_true(robots.contains("Sitemap: sitemap.xml"))
}

///|
test "inspect_manifest reports generated output files" {
  let files : Array[@moondockit.OutputFile] = [
    { path: "index.html", content: "<html></html>" },
    { path: "search-index.json", content: "[]" },
    { path: "sitemap.xml", content: "<urlset></urlset>" },
  ]
  let report = @moondockit.inspect_manifest(files)
  inspect(report.file_count, content="3")
  inspect(report.html_count, content="1")
  inspect(report.data_count, content="2")
  inspect(report.total_bytes, content="32")
  inspect(report.files[0].path, content="index.html")
  inspect(report.files[0].kind, content="html")
  inspect(report.files[1].kind, content="data")
}

///|
test "build_output_manifest_json serializes output metadata" {
  let files : Array[@moondockit.OutputFile] = [
    { path: "guide.html", content: "<html></html>" },
    { path: "search-index.json", content: "[]" },
  ]
  let manifest = @moondockit.build_output_manifest_json(files)
  assert_true(manifest.contains("\"file_count\": 2"))
  assert_true(manifest.contains("\"html_count\": 1"))
  assert_true(manifest.contains("\"data_count\": 1"))
  assert_true(manifest.contains("\"path\":\"guide.html\""))
  assert_true(manifest.contains("\"kind\":\"html\""))
}

///|
test "build_site_report summarizes default manifest outputs" {
  let page : @moondockit.DocPage = {
    title: "Guide",
    slug: "guide",
    source: "# Guide\n\nShip docs.",
  }
  let report = @moondockit.build_site_report({ title: "Docs", pages: [page] })
  inspect(report.file_count, content="6")
  inspect(report.html_count, content="2")
  inspect(report.data_count, content="3")
  assert_true(report.total_bytes > 0)
}

///|
test "measure_document reports content metrics" {
  let metrics = @moondockit.measure_document(
    "# Guide\n\nIntro text.\n\n- one item\n- two\n\n> quoted note\n\n```mbt\nlet x = 1\n```",
  )
  inspect(metrics.heading_count, content="1")
  inspect(metrics.paragraph_count, content="2")
  inspect(metrics.list_item_count, content="2")
  inspect(metrics.code_block_count, content="1")
  inspect(metrics.word_count, content="8")
  inspect(metrics.reading_minutes, content="1")
}

///|
test "measure_site aggregates page metrics" {
  let a : @moondockit.DocPage = {
    title: "A",
    slug: "a",
    source: "# A\n\none two",
  }
  let b : @moondockit.DocPage = {
    title: "B",
    slug: "b",
    source: "# B\n\n```mbt\nlet ok = true\n```",
  }
  let metrics = @moondockit.measure_site({ title: "Docs", pages: [a, b] })
  inspect(metrics.page_count, content="2")
  inspect(metrics.heading_count, content="2")
  inspect(metrics.code_block_count, content="1")
  inspect(metrics.word_count, content="4")
  inspect(metrics.reading_minutes, content="1")
}

///|
test "evaluate_quality passes publishable sites" {
  let page : @moondockit.DocPage = {
    title: "Guide",
    slug: "guide",
    source: "# Guide\n\nShip docs.",
  }
  let gate = @moondockit.evaluate_quality({ title: "Docs", pages: [page] })
  assert_true(gate.passed)
  inspect(gate.score, content="100")
  inspect(gate.checks.length(), content="4")
  inspect(gate.checks[0].name, content="validation")
}

///|
test "evaluate_quality fails empty sites" {
  let gate = @moondockit.evaluate_quality({ title: "", pages: [] })
  assert_false(gate.passed)
  assert_true(gate.score < 100)
  assert_false(gate.checks[0].passed)
  assert_false(gate.checks[1].passed)
}

///|
test "evaluate_quality scales across many readable pages" {
  let pages : Array[@moondockit.DocPage] = []
  let mut index = 0
  while index < 40 {
    let source = StringBuilder()
    source.write_string("# Guide\n\n")
    let mut word = 0
    while word < 201 {
      source.write_string("content ")
      word = word + 1
    }
    pages.push({
      title: "Guide \{index}",
      slug: "guide-\{index}",
      source: source.to_string(),
    })
    index = index + 1
  }
  let gate = @moondockit.evaluate_quality({ title: "Large Docs", pages })
  assert_true(gate.passed)
  assert_true(
    @moondockit.measure_site({ title: "Large Docs", pages }).reading_minutes >
    30,
  )
}

///|
test "evaluate_quality flags one oversized page" {
  let source = StringBuilder()
  source.write_string("# Long Guide\n\n")
  let mut word = 0
  while word < 6201 {
    source.write_string("content ")
    word = word + 1
  }
  let gate = @moondockit.evaluate_quality({
    title: "Docs",
    pages: [
      { title: "Long Guide", slug: "long-guide", source: source.to_string() },
    ],
  })
  assert_false(gate.passed)
  assert_false(gate.checks[3].passed)
}

///|
test "summarize_site counts pages outputs search and tags" {
  let a : @moondockit.DocPage = {
    title: "A",
    slug: "a",
    source: "---\ntags: [docs, moonbit]\n---\n# A",
  }
  let b : @moondockit.DocPage = {
    title: "B",
    slug: "b",
    source: "---\ntags: [docs]\n---\n# B",
  }
  let summary = @moondockit.summarize_site({ title: "Docs", pages: [a, b] })
  inspect(summary.page_count, content="2")
  inspect(summary.output_count, content="7")
  inspect(summary.search_entry_count, content="2")
  inspect(summary.tag_count, content="2")
}

///|
test "validate_site accepts healthy documentation sites" {
  let page : @moondockit.DocPage = {
    title: "Guide",
    slug: "guide",
    source: "# Guide\n\nShip docs.",
  }
  let report = @moondockit.validate_site({ title: "Docs", pages: [page] })
  inspect(report.diagnostics.length(), content="0")
  assert_false(@moondockit.has_validation_errors(report))
  inspect(@moondockit.diagnostics_to_text(report), content="ok")
}

///|
test "validate_site reports empty and duplicate routes" {
  let empty_report = @moondockit.validate_site({ title: "", pages: [] })
  inspect(empty_report.diagnostics.length(), content="2")
  assert_true(@moondockit.has_validation_errors(empty_report))
  let empty_text = @moondockit.diagnostics_to_text(empty_report)
  assert_true(empty_text.contains("warning empty-site-title"))
  assert_true(empty_text.contains("error empty-site"))

  let first : @moondockit.DocPage = {
    title: "Intro",
    slug: "intro",
    source: "# Intro",
  }
  let second : @moondockit.DocPage = {
    title: "Intro Again",
    slug: "intro",
    source: "",
  }
  let duplicate_report = @moondockit.validate_site({
    title: "Docs",
    pages: [first, second],
  })
  assert_true(@moondockit.has_validation_errors(duplicate_report))
  let duplicate_text = @moondockit.diagnostics_to_text(duplicate_report)
  assert_true(duplicate_text.contains("error duplicate-route [Intro Again]"))
  assert_true(duplicate_text.contains("warning empty-source [Intro Again]"))
}

///|
test "parse_blocks builds stable block ast" {
  let blocks = @moondockit.parse_blocks(
    "# Guide\n\n### Detail\n\nIntro\ncontinued\n\n- one\n- two\n\n> note\n\n```mbt\n# code\n```",
  )
  inspect(blocks.length(), content="6")
  match blocks[0] {
    Heading(level, title) => {
      inspect(level, content="1")
      inspect(title, content="Guide")
    }
    _ => fail("expected heading")
  }
  match blocks[1] {
    Heading(level, title) => {
      inspect(level, content="3")
      inspect(title, content="Detail")
    }
    _ => fail("expected detail heading")
  }
  match blocks[3] {
    UnorderedList(items) => {
      inspect(items.length(), content="2")
      inspect(items[1], content="two")
    }
    _ => fail("expected list")
  }
  match blocks[5] {
    CodeBlock(language, code) => {
      inspect(language, content="mbt")
      assert_true(code.contains("# code"))
    }
    _ => fail("expected code block")
  }
  match blocks[2] {
    Paragraph(text) => inspect(text, content="Intro continued")
    _ => fail("expected merged paragraph")
  }
}

///|
test "render_blocks keeps renderer reusable" {
  let blocks : Array[@moondockit.MarkdownBlock] = [
    Heading(2, "API <Reference>"),
    Paragraph("Use <safe> text."),
    CodeBlock("mbt", "let ok = true"),
  ]
  let html = @moondockit.render_blocks(blocks)
  assert_true(
    html.contains("<h2 id=\"api-reference\">API &lt;Reference&gt;</h2>"),
  )
  assert_true(html.contains("<p>Use &lt;safe&gt; text.</p>"))
  assert_true(
    html.contains("<code class=\"language-mbt\">let ok = true</code>"),
  )
}

///|
test "render_site emits deterministic html pages" {
  let page : @moondockit.DocPage = {
    title: "Guide",
    slug: "guide",
    source: "# Guide\n\n## Install\n\nShip docs.",
  }
  let site : @moondockit.DocSite = { title: "MoonDocKit", pages: [page] }
  let output = @moondockit.render_site(site)
  inspect(output.length(), content="1")
  inspect(output[0].path, content="guide.html")
  assert_true(output[0].html.contains("<title>Guide - MoonDocKit</title>"))
  assert_true(
    output[0].html.contains(
      "<a href=\"guide.html\" class=\"active\" aria-current=\"page\">Guide</a>",
    ),
  )
  assert_true(output[0].html.contains("<section class=\"toc\">"))
  assert_true(output[0].html.contains("href=\"#install\""))
}

///|
test "rendered pages expose responsive and accessible navigation" {
  let intro : @moondockit.DocPage = {
    title: "Intro",
    slug: "intro",
    source: "# Intro",
  }
  let api : @moondockit.DocPage = { title: "API", slug: "api", source: "# API" }
  let rendered = @moondockit.render_page(
    { title: "MoonDocKit", pages: [intro, api] },
    api,
  )
  assert_true(rendered.html.contains("<nav aria-label=\"Documentation\">"))
  assert_true(
    rendered.html.contains(
      "href=\"api.html\" class=\"active\" aria-current=\"page\"",
    ),
  )
  assert_true(rendered.html.contains("class=\"brand-mark\">M</span>"))
  assert_true(rendered.html.contains("@media(max-width:760px)"))
  assert_true(rendered.html.contains("@media(prefers-reduced-motion:reduce)"))
}

///|
test "rendered pages include safe interactive search" {
  let page : @moondockit.DocPage = {
    title: "Guide",
    slug: "guide",
    source: "# Guide\n\nSearch the documentation.",
  }
  let rendered = @moondockit.render_page({ title: "Docs", pages: [page] }, page)
  assert_true(rendered.html.contains("data-search-input"))
  assert_true(rendered.html.contains("data-search-results"))
  assert_true(rendered.html.contains("fetch(\"search-index.json\")"))
  assert_true(rendered.html.contains("title.textContent = item.title"))
  assert_true(rendered.html.contains("excerpt.textContent = item.text"))
  assert_false(rendered.html.contains("innerHTML"))
}

///|
test "parser preserves malformed inline markers as safe text" {
  let html = @moondockit.render_markdown(
    "Keep `open, **strong, [label], [link](open and <safe>.",
  )
  assert_true(html.contains("Keep `open, **strong, [label], [link](open"))
  assert_true(html.contains("&lt;safe&gt;"))
  assert_false(html.contains("<a href="))
}

///|
test "parser closes lists and unclosed code blocks at end of input" {
  let blocks = @moondockit.parse_blocks(
    "- first\ncontinued paragraph\n\n```mbt\nlet value = 1",
  )
  inspect(blocks.length(), content="3")
  match blocks[0] {
    UnorderedList(items) => inspect(items.length(), content="1")
    _ => fail("expected list")
  }
  match blocks[2] {
    CodeBlock(language, code) => {
      inspect(language, content="mbt")
      assert_true(code.contains("let value = 1"))
    }
    _ => fail("expected code block")
  }
}

///|
test "front matter tolerates comments invalid lines and invalid values" {
  let doc = @moondockit.parse_document(
    "---\n# comment\ninvalid line\norder: soon\ntags: docs\n---\n# Guide",
  )
  match doc.front_matter.order {
    None => ()
    Some(_) => fail("expected invalid order to be ignored")
  }
  inspect(doc.front_matter.tags.length(), content="1")
  inspect(doc.front_matter.tags[0], content="docs")
}

///|
test "default rendering handles pages without headings" {
  let page : @moondockit.DocPage = {
    title: "Note",
    slug: "note",
    source: "A short note without a heading.",
  }
  let rendered = @moondockit.render_page({ title: "Docs", pages: [page] }, page)
  assert_false(rendered.html.contains("<section class=\"toc\">"))
  assert_true(rendered.html.contains("<p>A short note without a heading.</p>"))
}

///|
test "theme dimensions and language fall back to safe defaults" {
  let page : @moondockit.DocPage = {
    title: "Guide",
    slug: "guide",
    source: "# Guide",
  }
  let theme : @moondockit.SiteTheme = {
    background: "#ffffff",
    surface: "#f8fafc",
    text: "#111827",
    accent: "#047857",
    border: "#d1d5db",
    code_background: "#111827",
    code_text: "#ffffff",
    sidebar_width_px: 0,
    content_width_px: -1,
  }
  let options : @moondockit.SiteOptions = {
    language: "",
    description: "",
    site_url: "https://docs.example/base",
    footer: "",
  }
  let rendered = @moondockit.render_page_with_options(
    { title: "Docs", pages: [page] },
    page,
    theme,
    options,
  )
  assert_true(rendered.html.contains("<html lang=\"en\">"))
  assert_true(rendered.html.contains("width:240px"))
  assert_true(rendered.html.contains("max-width:820px"))
  assert_true(
    rendered.html.contains("href=\"https://docs.example/base/guide.html\""),
  )
}

///|
test "search and sitemap escape structured output characters" {
  let page : @moondockit.DocPage = {
    title: "API & SDK",
    slug: "api&sdk",
    source: "# API\n\nUse C:\\docs.",
  }
  let site : @moondockit.DocSite = { title: "Docs", pages: [page] }
  let search = @moondockit.build_search_index(site)
  let sitemap = @moondockit.build_sitemap(site)
  assert_true(search.contains("C:\\\\docs"))
  assert_true(sitemap.contains("<loc>api&amp;sdk.html</loc>"))
}

///|
test "validation reports empty page titles and routes" {
  let page : @moondockit.DocPage = { title: "", slug: "", source: "# Content" }
  let report = @moondockit.validate_site({ title: "Docs", pages: [page] })
  let text = @moondockit.diagnostics_to_text(report)
  assert_true(text.contains("error empty-page-title"))
  assert_true(text.contains("error empty-route"))
}

///|
test "index page points to the first planned route" {
  let later : @moondockit.DocPage = {
    title: "Later",
    slug: "later",
    source: "---\norder: 2\n---\n# Later",
  }
  let first : @moondockit.DocPage = {
    title: "First",
    slug: "first",
    source: "---\norder: 1\n---\n# First",
  }
  match
    @moondockit.build_index_page({
      title: "Docs & Tools",
      pages: [later, first],
    }) {
    Some(html) => {
      assert_true(html.contains("url=first.html"))
      assert_true(html.contains("href=\"first.html\""))
      assert_true(html.contains("<title>Docs &amp; Tools</title>"))
    }
    None => fail("expected index page")
  }
  match @moondockit.build_index_page({ title: "Empty", pages: [] }) {
    None => ()
    Some(_) => fail("expected no index page")
  }
}

///|
test "parse_mbti extracts package functions and public types" {
  let api = @moondockit.parse_mbti(
    "// Generated\npackage \"acme/widgets\"\n\n// Values\npub fn build(String) -> Int\npub fn empty() -> Unit\npub fn merge(Array[(String, String)], Map[String, Int]) -> Result[String, Error]\n\n// Types and methods\npub(all) struct Config {\n  name : String\n}\n\npub(all) enum Mode {\n  Fast\n  Safe\n}\n\n// Traits\npub trait Render {\n  render(Self) -> String\n}\n",
  )
  inspect(api.package_name, content="acme/widgets")
  inspect(api.symbols.length(), content="6")
  inspect(api.symbols[0].kind, content="function")
  inspect(api.symbols[0].name, content="build")
  inspect(api.symbols[0].arity, content="1")
  inspect(api.symbols[0].return_type, content="Int")
  inspect(api.symbols[2].name, content="merge")
  inspect(api.symbols[2].arity, content="2")
  inspect(api.symbols[2].return_type, content="Result[String, Error]")
  inspect(api.symbols[3].kind, content="struct")
  inspect(api.symbols[3].name, content="Config")
  assert_true(api.symbols[3].signature.contains("name : String"))
  inspect(api.symbols[4].kind, content="enum")
  inspect(api.symbols[5].kind, content="trait")
}

///|
test "mbti_to_page creates searchable api documentation" {
  let page = @moondockit.mbti_to_page(
    "package \"acme/widgets\"\n\n// Values\npub fn build(String) -> Int\n\n// Types and methods\npub(all) struct Config {\n  name : String\n}\n",
  )
  inspect(page.slug, content="api-reference")
  assert_true(page.source.contains("# MoonBit API"))
  assert_true(page.source.contains("Package `acme/widgets` exposes 2"))
  assert_true(page.source.contains("## API Summary"))
  assert_true(page.source.contains("- Functions: 1"))
  assert_true(page.source.contains("- Structs: 1"))
  assert_true(page.source.contains("## Symbol Index"))
  assert_true(page.source.contains("- [build](#build)"))
  assert_true(page.source.contains("- [Config](#config)"))
  assert_true(page.source.contains("## Functions"))
  assert_true(page.source.contains("### build"))
  assert_true(page.source.contains("- Parameters: 1"))
  assert_true(page.source.contains("- Returns: `Int`"))
  assert_true(page.source.contains("pub fn build(String) -> Int"))
  assert_true(page.source.contains("## Structs"))
  let html = @moondockit.render_markdown(page.source)
  assert_true(html.contains("class=\"language-mbt\""))
  assert_true(html.contains("<a href=\"#build\">build</a>"))
  assert_true(html.contains("<h3 id=\"build\">build</h3>"))
}

///|
test "mbti parser handles empty and truncated interfaces" {
  let empty = @moondockit.parse_mbti("")
  inspect(empty.package_name, content="")
  inspect(empty.symbols.length(), content="0")
  let empty_page = @moondockit.mbti_to_page("")
  inspect(empty_page.title, content="MoonBit API")
  assert_true(empty_page.source.contains("# MoonBit API"))

  let truncated = @moondockit.parse_mbti(
    "package \"acme/truncated\"\npub(all) struct Config {\n  value : Int",
  )
  inspect(truncated.symbols.length(), content="1")
  inspect(truncated.symbols[0].name, content="Config")
  assert_true(truncated.symbols[0].signature.contains("value : Int"))
}
