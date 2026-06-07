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

/// A generated output file ready for a CLI to write to disk.
pub(all) struct OutputFile {
  path : String
  content : String
}

/// Planned route metadata for one documentation page.
pub(all) struct RouteEntry {
  title : String
  slug : String
  path : String
  order : Int?
  tags : Array[String]
}

/// Parsed page metadata from a leading front matter block.
pub(all) struct FrontMatter {
  title : String?
  order : Int?
  tags : Array[String]
  fields : Array[(String, String)]
}

/// Markdown source split into metadata and body blocks.
pub(all) struct ParsedDocument {
  front_matter : FrontMatter
  blocks : Array[MarkdownBlock]
}

/// A heading entry extracted from a source page.
pub(all) struct TocItem {
  level : Int
  title : String
  anchor : String
}

/// A heading with a page-unique anchor.
pub(all) struct AnchoredHeading {
  level : Int
  title : String
  anchor : String
}

/// Block-level Markdown nodes used by the documentation pipeline.
pub(all) enum MarkdownBlock {
  Heading(Int, String)
  Paragraph(String)
  UnorderedList(Array[String])
  BlockQuote(String)
  CodeBlock(String, String)
}

/// Return empty front matter metadata.
pub fn empty_front_matter() -> FrontMatter {
  { title: None, order: None, tags: [], fields: [] }
}

/// Site metadata and pages.
pub(all) struct DocSite {
  title : String
  pages : Array[DocPage]
}

/// Build a stable route table for all pages in a site.
pub fn plan_routes(site : DocSite) -> Array[RouteEntry] {
  let routes : Array[RouteEntry] = []
  for page in site.pages {
    routes.push(route_for_page(page))
  }
  routes.sort_by(compare_routes)
  routes
}

fn compare_routes(left : RouteEntry, right : RouteEntry) -> Int {
  match (left.order, right.order) {
    (Some(a), Some(b)) =>
      if a != b {
        a - b
      } else {
        compare_route_title(left, right)
      }
    (Some(_), None) => -1
    (None, Some(_)) => 1
    (None, None) => compare_route_title(left, right)
  }
}

fn compare_route_title(left : RouteEntry, right : RouteEntry) -> Int {
  let by_title = left.title.compare(right.title)
  if by_title != 0 {
    by_title
  } else {
    left.slug.compare(right.slug)
  }
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
  blocks_to_toc(parse_blocks(markdown))
}

/// Extract heading entries from parsed Markdown blocks.
pub fn blocks_to_toc(blocks : Array[MarkdownBlock]) -> Array[TocItem] {
  extract_headings(blocks).map(heading => {
    level: heading.level,
    title: heading.title,
    anchor: heading.anchor,
  })
}

/// Extract headings and assign page-unique anchors.
pub fn extract_headings(blocks : Array[MarkdownBlock]) -> Array[AnchoredHeading] {
  let headings : Array[AnchoredHeading] = []
  let seen : Array[String] = []
  for block in blocks {
    match block {
      Heading(level, title) => {
        let base = slugify(title)
        let anchor = unique_anchor(base, seen)
        seen.push(anchor)
        headings.push({ level, title, anchor })
      }
      _ => ()
    }
  }
  headings
}

fn unique_anchor(base : String, seen : Array[String]) -> String {
  let stable_base = if base == "" { "section" } else { base }
  let mut count = 1
  for item in seen {
    if item == stable_base || item.has_prefix(stable_base + "-") {
      count = count + 1
    }
  }
  if count == 1 {
    stable_base
  } else {
    stable_base + "-" + count.to_string()
  }
}

/// Parse a useful Markdown subset into block-level nodes.
pub fn parse_blocks(markdown : String) -> Array[MarkdownBlock] {
  parse_document(markdown).blocks
}

/// Parse optional front matter and Markdown blocks.
pub fn parse_document(markdown : String) -> ParsedDocument {
  let (front_matter, body) = split_front_matter(markdown)
  { front_matter, blocks: parse_body_blocks(body) }
}

fn split_front_matter(markdown : String) -> (FrontMatter, String) {
  let lines = markdown.split("\n").map(line => line.to_owned()).to_array()
  if lines.length() == 0 || lines[0].trim().to_owned() != "---" {
    return (empty_front_matter(), markdown)
  }
  let meta_lines : Array[String] = []
  let body_lines : Array[String] = []
  let mut in_meta = true
  let mut closed = false
  for i in 1..<lines.length() {
    let line = lines[i]
    if in_meta && line.trim().to_owned() == "---" {
      in_meta = false
      closed = true
      continue
    }
    if in_meta {
      meta_lines.push(line)
    } else {
      body_lines.push(line)
    }
  }
  if !closed {
    return (empty_front_matter(), markdown)
  }
  (parse_front_matter_lines(meta_lines), body_lines.join("\n"))
}

fn parse_front_matter_lines(lines : Array[String]) -> FrontMatter {
  let fields : Array[(String, String)] = []
  let tags : Array[String] = []
  let mut title : String? = None
  let mut order : Int? = None
  for raw in lines {
    let line = raw.trim().to_owned()
    if line == "" || line.has_prefix("#") {
      continue
    }
    match line.split_once(":") {
      Some((key_view, value_view)) => {
        let key = key_view.to_owned().trim().to_owned()
        let value = value_view.to_owned().trim().to_owned()
        fields.push((key, value))
        if key == "title" {
          title = Some(unquote(value))
        } else if key == "order" {
          order = parse_positive_int(value)
        } else if key == "tags" {
          for tag in parse_tags(value) {
            tags.push(tag)
          }
        }
      }
      None => ()
    }
  }
  { title, order, tags, fields }
}

fn parse_tags(value : String) -> Array[String] {
  let inner = strip_brackets(value)
  let tags : Array[String] = []
  for item in inner.split(",") {
    let tag = unquote(item.to_owned().trim().to_owned())
    if tag != "" {
      tags.push(tag)
    }
  }
  tags
}

fn strip_brackets(value : String) -> String {
  let trimmed = value.trim().to_owned()
  if trimmed.length() >= 2 && trimmed.has_prefix("[") && trimmed.has_suffix("]") {
    trimmed[1:trimmed.length() - 1].to_owned()
  } else {
    trimmed
  }
}

fn unquote(value : String) -> String {
  let trimmed = value.trim().to_owned()
  if trimmed.length() >= 2 {
    let first = trimmed[0]
    let last = trimmed[trimmed.length() - 1]
    if (first == '"' && last == '"') || (first == '\'' && last == '\'') {
      return trimmed[1:trimmed.length() - 1].to_owned()
    }
  }
  trimmed
}

fn parse_positive_int(value : String) -> Int? {
  let trimmed = value.trim().to_owned()
  if trimmed == "" {
    return None
  }
  let mut result = 0
  for _, ch in trimmed {
    if !(ch is ('0'..='9')) {
      return None
    }
    result = result * 10 + (ch.to_int() - '0'.to_int())
  }
  Some(result)
}

fn parse_body_blocks(markdown : String) -> Array[MarkdownBlock] {
  let blocks : Array[MarkdownBlock] = []
  let mut in_code = false
  let mut code_language = ""
  let code = StringBuilder()
  let mut in_list = false
  let list_items : Array[String] = []
  let paragraph = StringBuilder()
  for raw in markdown.split("\n") {
    let line = raw.to_owned()
    let trimmed = line.trim().to_owned()
    if trimmed.has_prefix("```") {
      close_pending_paragraph(blocks, paragraph)
      close_pending_list(blocks, list_items, in_list)
      in_list = false
      if in_code {
        blocks.push(CodeBlock(code_language, code.to_string()))
        code.reset()
        code_language = ""
      } else {
        code.reset()
        code_language = trimmed[3:].to_owned().trim().to_owned()
      }
      in_code = !in_code
      continue
    }
    if in_code {
      code.write_string(line)
      code.write_char('\n')
      continue
    }
    if trimmed == "" {
      close_pending_paragraph(blocks, paragraph)
      close_pending_list(blocks, list_items, in_list)
      in_list = false
      continue
    }
    if trimmed.has_prefix("# ") {
      close_pending_paragraph(blocks, paragraph)
      close_pending_list(blocks, list_items, in_list)
      in_list = false
      blocks.push(Heading(1, trimmed[2:].to_owned()))
    } else if trimmed.has_prefix("## ") {
      close_pending_paragraph(blocks, paragraph)
      close_pending_list(blocks, list_items, in_list)
      in_list = false
      blocks.push(Heading(2, trimmed[3:].to_owned()))
    } else if trimmed.has_prefix("- ") {
      close_pending_paragraph(blocks, paragraph)
      in_list = true
      list_items.push(trimmed[2:].to_owned())
    } else if trimmed.has_prefix("> ") {
      close_pending_paragraph(blocks, paragraph)
      close_pending_list(blocks, list_items, in_list)
      in_list = false
      blocks.push(BlockQuote(trimmed[2:].to_owned()))
    } else {
      if in_list {
        close_pending_list(blocks, list_items, in_list)
        in_list = false
      }
      append_paragraph_line(paragraph, trimmed)
    }
  }
  close_pending_paragraph(blocks, paragraph)
  if in_list {
    blocks.push(UnorderedList(list_items.copy()))
  }
  if in_code {
    blocks.push(CodeBlock(code_language, code.to_string()))
  }
  blocks
}

fn append_paragraph_line(paragraph : StringBuilder, line : String) -> Unit {
  if !paragraph.is_empty() {
    paragraph.write_char(' ')
  }
  paragraph.write_string(line)
}

fn close_pending_paragraph(
  blocks : Array[MarkdownBlock],
  paragraph : StringBuilder,
) -> Unit {
  if !paragraph.is_empty() {
    blocks.push(Paragraph(paragraph.to_string()))
    paragraph.reset()
  }
}

fn close_pending_list(
  blocks : Array[MarkdownBlock],
  list_items : Array[String],
  is_open : Bool,
) -> Unit {
  if is_open {
    blocks.push(UnorderedList(list_items.copy()))
    list_items.clear()
  }
}

/// Render parsed Markdown blocks to HTML.
pub fn render_blocks(blocks : Array[MarkdownBlock]) -> String {
  let out = StringBuilder()
  let headings = extract_headings(blocks)
  let mut heading_index = 0
  for block in blocks {
    match block {
      Heading(level, text) => {
        let anchor = headings[heading_index].anchor
        heading_index = heading_index + 1
        out.write_string("<h")
        out.write_string(level.to_string())
        out.write_string(" id=\"")
        out.write_string(anchor)
        out.write_string("\">")
        out.write_string(html_escape(text))
        out.write_string("</h")
        out.write_string(level.to_string())
        out.write_string(">\n")
      }
      Paragraph(text) => {
        out.write_string("<p>")
        out.write_string(render_inline(text))
        out.write_string("</p>\n")
      }
      UnorderedList(items) => {
        out.write_string("<ul>\n")
        for item in items {
          out.write_string("<li>")
          out.write_string(render_inline(item))
          out.write_string("</li>\n")
        }
        out.write_string("</ul>\n")
      }
      BlockQuote(text) => {
        out.write_string("<blockquote>")
        out.write_string(render_inline(text))
        out.write_string("</blockquote>\n")
      }
      CodeBlock(language, code) => {
        if language == "" {
          out.write_string("<pre><code>")
        } else {
          out.write_string("<pre><code class=\"language-")
          out.write_string(html_escape(slugify(language)))
          out.write_string("\">")
        }
        out.write_string(html_escape(code))
        out.write_string("</code></pre>\n")
      }
    }
  }
  out.to_string()
}

/// Render a useful subset of Markdown into HTML.
pub fn render_markdown(markdown : String) -> String {
  render_blocks(parse_blocks(markdown))
}

fn render_inline(input : String) -> String {
  html_escape(input)
}

/// Render a complete HTML page with navigation.
pub fn render_page(site : DocSite, page : DocPage) -> RenderedPage {
  let route = route_for_page(page)
  let body = render_markdown(page.source)
  let toc = render_toc(extract_toc(page.source))
  let routes = plan_routes(site)
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
  for item in routes {
    out.write_string("<a href=\"")
    out.write_string(html_escape(item.path))
    out.write_string("\">")
    out.write_string(html_escape(item.title))
    out.write_string("</a>")
  }
  out.write_string("</nav></aside><main>\n")
  out.write_string(toc)
  out.write_string(body)
  out.write_string("</main></body></html>\n")
  { path: route.path, html: out.to_string() }
}

/// Render all pages in a documentation site.
pub fn render_site(site : DocSite) -> Array[RenderedPage] {
  site.pages.map(page => render_page(site, page))
}

/// Build all static output files for a site without touching the filesystem.
pub fn build_site_manifest(site : DocSite) -> Array[OutputFile] {
  let files : Array[OutputFile] = []
  for page in site.pages {
    let rendered = render_page(site, page)
    files.push({ path: rendered.path, content: rendered.html })
  }
  files.sort_by((left, right) => left.path.compare(right.path))
  files
}

fn route_for_page(page : DocPage) -> RouteEntry {
  let doc = parse_document(page.source)
  let title = match doc.front_matter.title {
    Some(value) => value
    None => page.title
  }
  let slug = if page.slug == "" { slugify(title) } else { page.slug }
  {
    title,
    slug,
    path: slug + ".html",
    order: doc.front_matter.order,
    tags: doc.front_matter.tags,
  }
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
