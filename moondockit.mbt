/// A source page in a MoonDocKit documentation site.
pub(all) struct DocPage {
  title : String
  slug : String
  source : String
}

/// A rendered page that can be written to disk by a CLI package.
pub(all) struct RenderedPage {
  path : String
  html : String
}

/// A heading entry extracted from a source page.
pub(all) struct TocItem {
  level : Int
  title : String
  anchor : String
}

/// Site metadata and pages.
pub(all) struct DocSite {
  title : String
  pages : Array[DocPage]
}

/// Escape text for safe HTML output.
pub fn html_escape(input : String) -> String {
  let out = StringBuilder(size_hint=input.length())
  for _, ch in input {
    match ch {
      '&' => out.write_string("&amp;")
      '<' => out.write_string("&lt;")
      '>' => out.write_string("&gt;")
      '"' => out.write_string("&quot;")
      '\'' => out.write_string("&#39;")
      _ => out.write_char(ch)
    }
  }
  out.to_string()
}

/// Convert a heading or page title into a stable URL slug.
pub fn slugify(title : String) -> String {
  let out = StringBuilder(size_hint=title.length())
  let mut pending_dash = false
  let mut wrote = false
  for _, ch in title {
    let lower = ch.to_ascii_lowercase()
    if lower is ('a'..='z') || lower is ('0'..='9') {
      if pending_dash && wrote {
        out.write_char('-')
      }
      out.write_char(lower)
      pending_dash = false
      wrote = true
    } else {
      pending_dash = wrote
    }
  }
  out.to_string()
}

/// Extract level-1 and level-2 headings from Markdown source.
pub fn extract_toc(markdown : String) -> Array[TocItem] {
  let items : Array[TocItem] = []
  let mut in_code = false
  for raw in markdown.split("\n") {
    let line = raw.to_owned().trim().to_owned()
    if line == "```" {
      in_code = !in_code
      continue
    }
    if in_code {
      continue
    }
    if line.has_prefix("# ") {
      let title = line[2:].to_owned()
      items.push({ level: 1, title, anchor: slugify(title) })
    } else if line.has_prefix("## ") {
      let title = line[3:].to_owned()
      items.push({ level: 2, title, anchor: slugify(title) })
    }
  }
  items
}

/// Render a useful subset of Markdown into HTML.
///
/// The current milestone intentionally keeps the parser line-oriented:
/// headings, paragraphs, unordered lists, block quotes and fenced code blocks.
/// Later milestones will replace this with a block AST while preserving the API.
pub fn render_markdown(markdown : String) -> String {
  let out = StringBuilder(size_hint=markdown.length() + 128)
  let mut in_code = false
  let mut in_list = false
  for raw in markdown.split("\n") {
    let line = raw.to_owned()
    let trimmed = line.trim().to_owned()
    if trimmed == "```" {
      if in_list {
        out.write_string("</ul>\n")
        in_list = false
      }
      if in_code {
        out.write_string("</code></pre>\n")
      } else {
        out.write_string("<pre><code>")
      }
      in_code = !in_code
      continue
    }
    if in_code {
      out.write_string(html_escape(line))
      out.write_char('\n')
      continue
    }
    if trimmed == "" {
      if in_list {
        out.write_string("</ul>\n")
        in_list = false
      }
      continue
    }
    if trimmed.has_prefix("# ") {
      close_list(out, in_list)
      in_list = false
      let text = trimmed[2:].to_owned()
      out.write_string("<h1 id=\"")
      out.write_string(slugify(text))
      out.write_string("\">")
      out.write_string(html_escape(text))
      out.write_string("</h1>\n")
    } else if trimmed.has_prefix("## ") {
      close_list(out, in_list)
      in_list = false
      let text = trimmed[3:].to_owned()
      out.write_string("<h2 id=\"")
      out.write_string(slugify(text))
      out.write_string("\">")
      out.write_string(html_escape(text))
      out.write_string("</h2>\n")
    } else if trimmed.has_prefix("- ") {
      if !in_list {
        out.write_string("<ul>\n")
        in_list = true
      }
      out.write_string("<li>")
      out.write_string(render_inline(trimmed[2:].to_owned()))
      out.write_string("</li>\n")
    } else if trimmed.has_prefix("> ") {
      close_list(out, in_list)
      in_list = false
      out.write_string("<blockquote>")
      out.write_string(render_inline(trimmed[2:].to_owned()))
      out.write_string("</blockquote>\n")
    } else {
      close_list(out, in_list)
      in_list = false
      out.write_string("<p>")
      out.write_string(render_inline(trimmed))
      out.write_string("</p>\n")
    }
  }
  if in_list {
    out.write_string("</ul>\n")
  }
  if in_code {
    out.write_string("</code></pre>\n")
  }
  out.to_string()
}

fn close_list(out : StringBuilder, is_open : Bool) -> Unit {
  if is_open {
    out.write_string("</ul>\n")
  }
}

fn render_inline(input : String) -> String {
  html_escape(input)
}

/// Render a complete HTML page with navigation.
pub fn render_page(site : DocSite, page : DocPage) -> RenderedPage {
  let body = render_markdown(page.source)
  let toc = render_toc(extract_toc(page.source))
  let out = StringBuilder(size_hint=body.length() + 1024)
  out.write_string("<!doctype html>\n<html><head><meta charset=\"utf-8\">\n")
  out.write_string("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n")
  out.write_string("<title>")
  out.write_string(html_escape(page.title))
  out.write_string(" - ")
  out.write_string(html_escape(site.title))
  out.write_string("</title>\n")
  out.write_string(default_style())
  out.write_string("</head><body><aside><strong>")
  out.write_string(html_escape(site.title))
  out.write_string("</strong><nav>")
  for item in site.pages {
    out.write_string("<a href=\"")
    out.write_string(html_escape(item.slug))
    out.write_string(".html\">")
    out.write_string(html_escape(item.title))
    out.write_string("</a>")
  }
  out.write_string("</nav></aside><main>\n")
  out.write_string(toc)
  out.write_string(body)
  out.write_string("</main></body></html>\n")
  { path: page.slug + ".html", html: out.to_string() }
}

/// Render all pages in a documentation site.
pub fn render_site(site : DocSite) -> Array[RenderedPage] {
  site.pages.map(page => render_page(site, page))
}

fn default_style() -> String {
  "<style>body{margin:0;font:16px/1.6 system-ui,sans-serif;color:#172033;background:#f7f8fb}aside{position:fixed;inset:0 auto 0 0;width:240px;padding:28px;background:#fff;border-right:1px solid #dde3ee}nav{display:grid;gap:8px;margin-top:20px}a{color:#2457c5;text-decoration:none}main{max-width:820px;margin-left:300px;padding:42px 32px}.toc{padding:16px 18px;margin:0 0 28px;border:1px solid #dde3ee;background:#fff}.toc-title{font-weight:700;margin-bottom:8px}.toc a{display:block}.toc .level-2{padding-left:16px}pre{padding:16px;background:#101828;color:#eef4ff;overflow:auto}code{font-family:ui-monospace,monospace}</style>\n"
}

fn render_toc(items : Array[TocItem]) -> String {
  if items.length() == 0 {
    return ""
  }
  let out = StringBuilder()
  out.write_string("<section class=\"toc\"><div class=\"toc-title\">On this page</div>\n")
  for item in items {
    out.write_string("<a class=\"level-")
    out.write_string(item.level.to_string())
    out.write_string("\" href=\"#")
    out.write_string(html_escape(item.anchor))
    out.write_string("\">")
    out.write_string(html_escape(item.title))
    out.write_string("</a>\n")
  }
  out.write_string("</section>\n")
  out.to_string()
}
