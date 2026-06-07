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
