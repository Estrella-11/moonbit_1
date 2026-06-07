test "html_escape protects generated pages" {
  inspect(
    @moondockit.html_escape("<script>alert('x') & \"y\"</script>"),
    content="&lt;script&gt;alert(&#39;x&#39;) &amp; &quot;y&quot;&lt;/script&gt;",
  )
}

test "slugify keeps stable ascii anchors" {
  inspect(@moondockit.slugify("MoonBit Docs: Quick Start!"), content="moonbit-docs-quick-start")
  inspect(@moondockit.slugify("  API   Reference  "), content="api-reference")
}

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

test "extract_toc ignores code fences" {
  let toc = @moondockit.extract_toc("# Guide\n\n## Install\n\n```\n# Not a heading\n```\n## Usage")
  inspect(toc.length(), content="3")
  inspect(toc[0].anchor, content="guide")
  inspect(toc[1].title, content="Install")
  inspect(toc[2].anchor, content="usage")
}

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

test "parse_document reads simple front matter" {
  let doc = @moondockit.parse_document("---\ntitle: \"Quick Start\"\norder: 12\ntags: [guide, moonbit]\nlayout: docs\n---\n# Quick Start\n\nBody")
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

test "parse_document ignores unclosed front matter" {
  let doc = @moondockit.parse_document("---\ntitle: Draft\n# Still body")
  match doc.front_matter.title {
    None => ()
    Some(_) => fail("expected no title")
  }
  inspect(doc.blocks.length(), content="2")
  assert_true(@moondockit.render_blocks(doc.blocks).contains("title: Draft"))
}

test "parse_blocks builds stable block ast" {
  let blocks = @moondockit.parse_blocks("# Guide\n\nIntro\ncontinued\n\n- one\n- two\n\n> note\n\n```mbt\n# code\n```")
  inspect(blocks.length(), content="5")
  match blocks[0] {
    Heading(level, title) => {
      inspect(level, content="1")
      inspect(title, content="Guide")
    }
    _ => fail("expected heading")
  }
  match blocks[2] {
    UnorderedList(items) => {
      inspect(items.length(), content="2")
      inspect(items[1], content="two")
    }
    _ => fail("expected list")
  }
  match blocks[4] {
    CodeBlock(language, code) => {
      inspect(language, content="mbt")
      assert_true(code.contains("# code"))
    }
    _ => fail("expected code block")
  }
  match blocks[1] {
    Paragraph(text) => inspect(text, content="Intro continued")
    _ => fail("expected merged paragraph")
  }
}

test "render_blocks keeps renderer reusable" {
  let blocks : Array[@moondockit.MarkdownBlock] = [
    Heading(2, "API <Reference>"),
    Paragraph("Use <safe> text."),
    CodeBlock("mbt", "let ok = true"),
  ]
  let html = @moondockit.render_blocks(blocks)
  assert_true(html.contains("<h2 id=\"api-reference\">API &lt;Reference&gt;</h2>"))
  assert_true(html.contains("<p>Use &lt;safe&gt; text.</p>"))
  assert_true(html.contains("<code class=\"language-mbt\">let ok = true</code>"))
}

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
  assert_true(output[0].html.contains("<a href=\"guide.html\">Guide</a>"))
  assert_true(output[0].html.contains("<section class=\"toc\">"))
  assert_true(output[0].html.contains("href=\"#install\""))
}
