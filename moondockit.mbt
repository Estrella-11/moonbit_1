///|
/// A source page in a MoonDocKit documentation site.
pub(all) struct DocPage {
  title : String
  slug : String
  source : String
}

///|
/// A rendered page that can be written to disk by a CLI package.
pub(all) struct RenderedPage {
  path : String
  html : String
}

///|
/// A generated output file ready for a CLI to write to disk.
pub(all) struct OutputFile {
  path : String
  content : String
}

///|
/// File metadata derived from a generated output manifest.
pub(all) struct OutputFileInfo {
  path : String
  kind : String
  byte_count : Int
}

///|
/// Aggregate report for generated output files.
pub(all) struct BuildReport {
  file_count : Int
  html_count : Int
  data_count : Int
  total_bytes : Int
  files : Array[OutputFileInfo]
}

///|
/// One quality gate check result.
pub(all) struct QualityCheck {
  name : String
  passed : Bool
  message : String
}

///|
/// Aggregate quality gate result for a documentation site.
pub(all) struct QualityGate {
  passed : Bool
  score : Int
  checks : Array[QualityCheck]
}

///|
/// Searchable text metadata for one route.
pub(all) struct SearchEntry {
  title : String
  path : String
  text : String
  tags : Array[String]
}

///|
/// One public declaration extracted from a generated MoonBit interface.
pub(all) struct ApiSymbol {
  kind : String
  name : String
  signature : String
  arity : Int
  return_type : String
}

///|
/// Public package information extracted from a `.mbti` interface.
pub(all) struct ApiReference {
  package_name : String
  symbols : Array[ApiSymbol]
}

///|
/// Aggregate metadata for a documentation site.
pub(all) struct SiteSummary {
  page_count : Int
  output_count : Int
  search_entry_count : Int
  tag_count : Int
}

///|
/// Content metrics for one parsed documentation page.
pub(all) struct DocumentMetrics {
  heading_count : Int
  paragraph_count : Int
  list_item_count : Int
  code_block_count : Int
  word_count : Int
  reading_minutes : Int
}

///|
/// Aggregate content metrics for a documentation site.
pub(all) struct SiteMetrics {
  page_count : Int
  heading_count : Int
  code_block_count : Int
  word_count : Int
  reading_minutes : Int
}

///|
/// Visual theme values used by generated HTML pages.
pub(all) struct SiteTheme {
  background : String
  surface : String
  text : String
  accent : String
  border : String
  code_background : String
  code_text : String
  sidebar_width_px : Int
  content_width_px : Int
}

///|
/// Page template options used by generated HTML pages.
pub(all) struct SiteOptions {
  language : String
  description : String
  site_url : String
  footer : String
}

///|
/// Severity level for site validation diagnostics.
pub(all) enum DiagnosticLevel {
  DiagError
  DiagWarning
}

///|
/// A validation finding for a site or one source page.
pub(all) struct SiteDiagnostic {
  level : DiagnosticLevel
  code : String
  message : String
  page : String?
}

///|
/// Site validation result returned before rendering or publishing.
pub(all) struct ValidationReport {
  diagnostics : Array[SiteDiagnostic]
}

///|
/// Planned route metadata for one documentation page.
pub(all) struct RouteEntry {
  title : String
  slug : String
  path : String
  order : Int?
  tags : Array[String]
}

///|
/// Parsed page metadata from a leading front matter block.
pub(all) struct FrontMatter {
  title : String?
  order : Int?
  tags : Array[String]
  fields : Array[(String, String)]
}

///|
/// Markdown source split into metadata and body blocks.
pub(all) struct ParsedDocument {
  front_matter : FrontMatter
  blocks : Array[MarkdownBlock]
}

///|
/// A heading entry extracted from a source page.
pub(all) struct TocItem {
  level : Int
  title : String
  anchor : String
}

///|
/// A heading with a page-unique anchor.
pub(all) struct AnchoredHeading {
  level : Int
  title : String
  anchor : String
}

///|
/// Block-level Markdown nodes used by the documentation pipeline.
pub(all) enum MarkdownBlock {
  Heading(Int, String)
  Paragraph(String)
  UnorderedList(Array[String])
  BlockQuote(String)
  CodeBlock(String, String)
}

///|
/// Return empty front matter metadata.
pub fn empty_front_matter() -> FrontMatter {
  { title: None, order: None, tags: [], fields: [] }
}

///|
/// Parse a generated MoonBit interface into public API declarations.
pub fn parse_mbti(source : String) -> ApiReference {
  let symbols : Array[ApiSymbol] = []
  let mut package_name = ""
  let lines = source.split("\n").collect()
  let mut i = 0
  while i < lines.length() {
    let line = lines[i].to_owned().trim().to_owned()
    if line.has_prefix("package \"") && line.has_suffix("\"") {
      package_name = line[9:line.length() - 1].to_owned()
    } else if line.has_prefix("pub fn ") {
      symbols.push({
        kind: "function",
        name: declaration_name(line, "pub fn "),
        signature: line,
        arity: function_arity(line),
        return_type: return_type(line),
      })
    } else if line.has_prefix("pub(all) struct ") {
      let captured = capture_interface_block(lines, i)
      symbols.push({
        kind: "struct",
        name: declaration_name(line, "pub(all) struct "),
        signature: captured.0,
        arity: 0,
        return_type: "",
      })
      i = captured.1
    } else if line.has_prefix("pub(all) enum ") {
      let captured = capture_interface_block(lines, i)
      symbols.push({
        kind: "enum",
        name: declaration_name(line, "pub(all) enum "),
        signature: captured.0,
        arity: 0,
        return_type: "",
      })
      i = captured.1
    } else if line.has_prefix("pub trait ") {
      let captured = capture_interface_block(lines, i)
      symbols.push({
        kind: "trait",
        name: declaration_name(line, "pub trait "),
        signature: captured.0,
        arity: 0,
        return_type: "",
      })
      i = captured.1
    }
    i = i + 1
  }
  { package_name, symbols }
}

///|
/// Convert a generated MoonBit interface into a documentation page.
pub fn mbti_to_page(source : String) -> DocPage {
  let api = parse_mbti(source)
  let title = if api.package_name == "" {
    "MoonBit API"
  } else {
    api.package_name + " API"
  }
  let out = StringBuilder()
  out.write_string(
    "---\ntitle: MoonBit API\norder: 900\ntags: [api, moonbit]\n---\n",
  )
  out.write_string("# MoonBit API\n\n")
  if api.package_name != "" {
    out.write_string("Package `")
    out.write_string(api.package_name)
    out.write_string("` exposes ")
    out.write_string(api.symbols.length().to_string())
    out.write_string(" public declarations.\n\n")
  }
  if api.symbols.length() > 0 {
    out.write_string("## API Summary\n\n")
    let kinds = ["function", "struct", "enum", "trait"]
    for kind in kinds {
      let count = api.symbols.filter(symbol => symbol.kind == kind).length()
      if count > 0 {
        out.write_string("- ")
        out.write_string(api_section_title(kind))
        out.write_string(": ")
        out.write_string(count.to_string())
        out.write_string("\n")
      }
    }
    out.write_string("\n")
    out.write_string("## Symbol Index\n\n")
    for kind in kinds {
      let matching = api.symbols.filter(symbol => symbol.kind == kind)
      if matching.length() > 0 {
        out.write_string("### ")
        out.write_string(api_section_title(kind))
        out.write_string("\n\n")
        for symbol in matching {
          out.write_string("- [")
          out.write_string(symbol.name)
          out.write_string("](#")
          out.write_string(slugify(symbol.name))
          out.write_string(")\n")
        }
        out.write_string("\n")
      }
    }
  }
  let kinds = ["function", "struct", "enum", "trait"]
  for kind in kinds {
    let matching = api.symbols.filter(symbol => symbol.kind == kind)
    if matching.length() > 0 {
      out.write_string("## ")
      out.write_string(api_section_title(kind))
      out.write_string("\n\n")
      for symbol in matching {
        out.write_string("### ")
        out.write_string(symbol.name)
        out.write_string("\n\n")
        if symbol.kind == "function" {
          out.write_string("- Parameters: ")
          out.write_string(symbol.arity.to_string())
          if symbol.return_type != "" {
            out.write_string("\n- Returns: `")
            out.write_string(symbol.return_type)
            out.write_string("`")
          }
        }
        out.write_string("\n\n```mbt\n")
        out.write_string(symbol.signature)
        out.write_string("\n```\n\n")
      }
    }
  }
  { title, slug: "api-reference", source: out.to_string() }
}

///|
fn declaration_name(line : String, prefix : String) -> String {
  let rest = line[prefix.length():].to_owned()
  let mut end = rest.length()
  for index, ch in rest {
    if ch == '(' || ch == '[' || ch == ' ' || ch == '{' {
      end = index
      break
    }
  }
  rest[0:end].to_owned()
}

///|
fn function_arity(signature : String) -> Int {
  let start = find_char(signature, '(')
  let finish = find_matching_paren(signature, start)
  if start < 0 || finish <= start + 1 {
    return 0
  }
  let args = signature[start + 1:finish].to_owned().trim().to_owned()
  if args == "" {
    0
  } else {
    count_top_level_commas(args) + 1
  }
}

///|
fn return_type(signature : String) -> String {
  match signature.split_once(" -> ") {
    Some((_, result)) => result.trim().to_owned()
    None => ""
  }
}

///|
fn find_char(input : String, target : Char) -> Int {
  for index, ch in input {
    if ch == target {
      return index
    }
  }
  -1
}

///|
fn find_matching_paren(input : String, start : Int) -> Int {
  if start < 0 {
    return -1
  }
  let mut depth = 0
  for index, ch in input {
    if index < start {
      continue
    }
    if ch == '(' {
      depth = depth + 1
    } else if ch == ')' {
      depth = depth - 1
      if depth == 0 {
        return index
      }
    }
  }
  -1
}

///|
fn count_top_level_commas(input : String) -> Int {
  let mut count = 0
  let mut depth = 0
  for _, ch in input {
    if ch == '(' || ch == '[' || ch == '{' {
      depth = depth + 1
    } else if ch == ')' || ch == ']' || ch == '}' {
      if depth > 0 {
        depth = depth - 1
      }
    } else if ch == ',' && depth == 0 {
      count = count + 1
    }
  }
  count
}

///|
fn capture_interface_block(
  lines : Array[StringView],
  start : Int,
) -> (String, Int) {
  let out = StringBuilder()
  let mut i = start
  while i < lines.length() {
    let line = lines[i].to_owned()
    if i > start {
      out.write_char('\n')
    }
    out.write_string(line)
    if line.trim().to_owned() == "}" {
      return (out.to_string(), i)
    }
    i = i + 1
  }
  (out.to_string(), i - 1)
}

///|
fn api_section_title(kind : String) -> String {
  match kind {
    "function" => "Functions"
    "struct" => "Structs"
    "enum" => "Enums"
    "trait" => "Traits"
    _ => "Declarations"
  }
}

///|
/// Return the default MoonDocKit page theme.
pub fn default_theme() -> SiteTheme {
  {
    background: "#f7f8fb",
    surface: "#ffffff",
    text: "#172033",
    accent: "#2457c5",
    border: "#dde3ee",
    code_background: "#101828",
    code_text: "#eef4ff",
    sidebar_width_px: 240,
    content_width_px: 820,
  }
}

///|
/// Return default generated page metadata and footer options.
pub fn default_site_options() -> SiteOptions {
  {
    language: "en",
    description: "",
    site_url: "",
    footer: "Generated by MoonDocKit",
  }
}

///|
/// Site metadata and pages.
pub(all) struct DocSite {
  title : String
  pages : Array[DocPage]
}

///|
/// Build a stable route table for all pages in a site.
pub fn plan_routes(site : DocSite) -> Array[RouteEntry] {
  let routes : Array[RouteEntry] = []
  for page in site.pages {
    routes.push(route_for_page(page))
  }
  routes.sort_by(compare_routes)
  routes
}

///|
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

///|
fn compare_route_title(left : RouteEntry, right : RouteEntry) -> Int {
  let by_title = left.title.compare(right.title)
  if by_title != 0 {
    by_title
  } else {
    left.slug.compare(right.slug)
  }
}

///|
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

///|
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

///|
/// Extract level-1 and level-2 headings from Markdown source.
pub fn extract_toc(markdown : String) -> Array[TocItem] {
  blocks_to_toc(parse_blocks(markdown))
}

///|
/// Extract heading entries from parsed Markdown blocks.
pub fn blocks_to_toc(blocks : Array[MarkdownBlock]) -> Array[TocItem] {
  extract_headings(blocks).map(heading => {
    level: heading.level,
    title: heading.title,
    anchor: heading.anchor,
  })
}

///|
/// Extract headings and assign page-unique anchors.
pub fn extract_headings(
  blocks : Array[MarkdownBlock],
) -> Array[AnchoredHeading] {
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

///|
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

///|
/// Parse a useful Markdown subset into block-level nodes.
pub fn parse_blocks(markdown : String) -> Array[MarkdownBlock] {
  parse_document(markdown).blocks
}

///|
/// Parse optional front matter and Markdown blocks.
pub fn parse_document(markdown : String) -> ParsedDocument {
  let (front_matter, body) = split_front_matter(markdown)
  { front_matter, blocks: parse_body_blocks(body) }
}

///|
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

///|
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

///|
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

///|
fn strip_brackets(value : String) -> String {
  let trimmed = value.trim().to_owned()
  if trimmed.length() >= 2 && trimmed.has_prefix("[") && trimmed.has_suffix("]") {
    trimmed[1:trimmed.length() - 1].to_owned()
  } else {
    trimmed
  }
}

///|
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

///|
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

///|
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
    } else if trimmed.has_prefix("### ") {
      close_pending_paragraph(blocks, paragraph)
      close_pending_list(blocks, list_items, in_list)
      in_list = false
      blocks.push(Heading(3, trimmed[4:].to_owned()))
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

///|
fn append_paragraph_line(paragraph : StringBuilder, line : String) -> Unit {
  if !paragraph.is_empty() {
    paragraph.write_char(' ')
  }
  paragraph.write_string(line)
}

///|
fn close_pending_paragraph(
  blocks : Array[MarkdownBlock],
  paragraph : StringBuilder,
) -> Unit {
  if !paragraph.is_empty() {
    blocks.push(Paragraph(paragraph.to_string()))
    paragraph.reset()
  }
}

///|
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

///|
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

///|
/// Render a useful subset of Markdown into HTML.
pub fn render_markdown(markdown : String) -> String {
  render_blocks(parse_blocks(markdown))
}

///|
fn render_inline(input : String) -> String {
  let out = StringBuilder(size_hint=input.length())
  let mut i = 0
  while i < input.length() {
    if starts_with_at(input, i, "`") {
      match find_char_from(input, i + 1, '`') {
        Some(close) => {
          out.write_string("<code>")
          out.write_string(html_escape(input[i + 1:close].to_owned()))
          out.write_string("</code>")
          i = close + 1
        }
        None => {
          out.write_string("`")
          i = i + 1
        }
      }
    } else if starts_with_at(input, i, "**") {
      match find_marker_from(input, i + 2, "**") {
        Some(close) => {
          out.write_string("<strong>")
          out.write_string(render_inline(input[i + 2:close].to_owned()))
          out.write_string("</strong>")
          i = close + 2
        }
        None => {
          out.write_string("**")
          i = i + 2
        }
      }
    } else if starts_with_at(input, i, "*") {
      match find_char_from(input, i + 1, '*') {
        Some(close) => {
          out.write_string("<em>")
          out.write_string(render_inline(input[i + 1:close].to_owned()))
          out.write_string("</em>")
          i = close + 1
        }
        None => {
          out.write_string("*")
          i = i + 1
        }
      }
    } else if starts_with_at(input, i, "![") {
      match parse_link(input, i + 1) {
        Some((close, label, src)) => {
          out.write_string("<img src=\"")
          out.write_string(html_escape(safe_href(src)))
          out.write_string("\" alt=\"")
          out.write_string(html_escape(label))
          out.write_string("\">")
          i = close + 1
        }
        None => {
          out.write_string("!")
          i = i + 1
        }
      }
    } else if input[i] == '[' {
      match parse_link(input, i) {
        Some((close, label, href)) => {
          out.write_string("<a href=\"")
          out.write_string(html_escape(safe_href(href)))
          out.write_string("\">")
          out.write_string(render_inline(label))
          out.write_string("</a>")
          i = close + 1
        }
        None => {
          out.write_string(html_escape(input[i:i + 1].to_owned()))
          i = i + 1
        }
      }
    } else {
      out.write_string(html_escape(input[i:i + 1].to_owned()))
      i = i + 1
    }
  }
  out.to_string()
}

///|
fn starts_with_at(input : String, index : Int, marker : String) -> Bool {
  index + marker.length() <= input.length() &&
  input[index:index + marker.length()].to_owned() == marker
}

///|
fn find_char_from(input : String, start : Int, target : UInt16) -> Int? {
  let mut i = start
  while i < input.length() {
    if input[i] == target {
      return Some(i)
    }
    i = i + 1
  }
  None
}

///|
fn find_marker_from(input : String, start : Int, marker : String) -> Int? {
  let mut i = start
  while i + marker.length() <= input.length() {
    if starts_with_at(input, i, marker) {
      return Some(i)
    }
    i = i + 1
  }
  None
}

///|
fn parse_link(input : String, start : Int) -> (Int, String, String)? {
  match find_char_from(input, start + 1, ']') {
    Some(label_end) =>
      if label_end + 1 < input.length() && input[label_end + 1] == '(' {
        match find_char_from(input, label_end + 2, ')') {
          Some(href_end) =>
            Some(
              (
                href_end,
                input[start + 1:label_end].to_owned(),
                input[label_end + 2:href_end].to_owned(),
              ),
            )
          None => None
        }
      } else {
        None
      }
    None => None
  }
}

///|
fn safe_href(href : String) -> String {
  let value = href.trim().to_owned()
  if value.has_prefix("http://") ||
    value.has_prefix("https://") ||
    value.has_prefix("#") ||
    value.has_prefix("./") ||
    value.has_prefix("../") ||
    !value.contains(":") {
    value
  } else {
    "#"
  }
}

///|
/// Render a complete HTML page with navigation.
pub fn render_page(site : DocSite, page : DocPage) -> RenderedPage {
  render_page_with_options(site, page, default_theme(), default_site_options())
}

///|
/// Render a complete HTML page with navigation and a custom theme.
pub fn render_page_with_theme(
  site : DocSite,
  page : DocPage,
  theme : SiteTheme,
) -> RenderedPage {
  render_page_with_options(site, page, theme, default_site_options())
}

///|
/// Render a complete HTML page with custom theme and template options.
pub fn render_page_with_options(
  site : DocSite,
  page : DocPage,
  theme : SiteTheme,
  options : SiteOptions,
) -> RenderedPage {
  let route = route_for_page(page)
  let body = render_markdown(page.source)
  let toc = render_toc(extract_toc(page.source))
  let routes = plan_routes(site)
  let out = StringBuilder(size_hint=body.length() + 1024)
  out.write_string("<!doctype html>\n<html lang=\"")
  out.write_string(html_escape(safe_language(options.language)))
  out.write_string("\"><head><meta charset=\"utf-8\">\n")
  out.write_string(
    "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n",
  )
  if options.description.trim().to_owned() != "" {
    out.write_string("<meta name=\"description\" content=\"")
    out.write_string(html_escape(options.description.trim().to_owned()))
    out.write_string("\">\n")
  }
  out.write_string("<title>")
  out.write_string(html_escape(route.title))
  out.write_string(" - ")
  out.write_string(html_escape(site.title))
  out.write_string("</title>\n")
  write_social_metadata(out, site, route, options)
  out.write_string(render_theme_style(theme))
  out.write_string("</head><body><aside><a class=\"brand\" href=\"")
  if routes.length() > 0 {
    out.write_string(html_escape(routes[0].path))
  } else {
    out.write_string("#")
  }
  out.write_string("\"><span class=\"brand-mark\">M</span><span>")
  out.write_string(html_escape(site.title))
  out.write_string(
    "</span></a><div class=\"search\"><label for=\"site-search\">Search documentation</label><input id=\"site-search\" data-search-input type=\"search\" placeholder=\"Search docs\" autocomplete=\"off\"><div class=\"search-results\" data-search-results aria-live=\"polite\" hidden></div></div><nav aria-label=\"Documentation\">",
  )
  for item in routes {
    out.write_string("<a href=\"")
    out.write_string(html_escape(item.path))
    if item.path == route.path {
      out.write_string("\" class=\"active\" aria-current=\"page\">")
    } else {
      out.write_string("\">")
    }
    out.write_string(html_escape(item.title))
    out.write_string("</a>")
  }
  out.write_string("</nav></aside><main><div class=\"content\">\n")
  out.write_string(toc)
  out.write_string(body)
  if options.footer.trim().to_owned() != "" {
    out.write_string("<footer>")
    out.write_string(render_inline(options.footer.trim().to_owned()))
    out.write_string("</footer>\n")
  }
  out.write_string("</div></main>")
  out.write_string(render_search_script())
  out.write_string("</body></html>\n")
  { path: route.path, html: out.to_string() }
}

///|
fn write_social_metadata(
  out : StringBuilder,
  site : DocSite,
  route : RouteEntry,
  options : SiteOptions,
) -> Unit {
  let title = route.title + " - " + site.title
  out.write_string("<meta property=\"og:title\" content=\"")
  out.write_string(html_escape(title))
  out.write_string("\">\n")
  if options.description.trim().to_owned() != "" {
    out.write_string("<meta property=\"og:description\" content=\"")
    out.write_string(html_escape(options.description.trim().to_owned()))
    out.write_string("\">\n")
  }
  match canonical_url(options.site_url, route.path) {
    Some(url) => {
      out.write_string("<link rel=\"canonical\" href=\"")
      out.write_string(html_escape(url))
      out.write_string("\">\n")
      out.write_string("<meta property=\"og:url\" content=\"")
      out.write_string(html_escape(url))
      out.write_string("\">\n")
    }
    None => ()
  }
}

///|
fn canonical_url(site_url : String, path : String) -> String? {
  let base = site_url.trim().to_owned()
  if base == "" {
    return None
  }
  if !(base.has_prefix("http://") || base.has_prefix("https://")) {
    return None
  }
  let clean_base = if base.has_suffix("/") {
    base[0:base.length() - 1].to_owned()
  } else {
    base
  }
  let clean_path = if path.has_prefix("/") { path[1:].to_owned() } else { path }
  Some(clean_base + "/" + clean_path)
}

///|
fn render_search_script() -> String {
  (
    #|<script>
    #|(() => {
    #|  const input = document.querySelector("[data-search-input]");
    #|  const results = document.querySelector("[data-search-results]");
    #|  let entries = [];
    #|  fetch("search-index.json")
    #|    .then(response => response.json())
    #|    .then(value => { entries = value; })
    #|    .catch(() => {});
    #|  input.addEventListener("input", () => {
    #|    const query = input.value.trim().toLowerCase();
    #|    results.replaceChildren();
    #|    if (query.length < 2) {
    #|      results.hidden = true;
    #|      return;
    #|    }
    #|    const matches = entries.filter(item =>
    #|      `${item.title} ${item.text} ${(item.tags || []).join(" ")}`.toLowerCase().includes(query)
    #|    ).slice(0, 8);
    #|    for (const item of matches) {
    #|      const link = document.createElement("a");
    #|      const title = document.createElement("strong");
    #|      const excerpt = document.createElement("span");
    #|      link.href = item.path;
    #|      title.textContent = item.title;
    #|      excerpt.textContent = item.text.slice(0, 96);
    #|      link.append(title, excerpt);
    #|      results.append(link);
    #|    }
    #|    if (matches.length === 0) {
    #|      const empty = document.createElement("span");
    #|      empty.textContent = "No matching pages";
    #|      results.append(empty);
    #|    }
    #|    results.hidden = false;
    #|  });
    #|})();
    #|</script>
    #|
  )
}

///|
/// Render all pages in a documentation site.
pub fn render_site(site : DocSite) -> Array[RenderedPage] {
  render_site_with_theme(site, default_theme())
}

///|
/// Render all pages in a documentation site with a custom theme.
pub fn render_site_with_theme(
  site : DocSite,
  theme : SiteTheme,
) -> Array[RenderedPage] {
  render_site_with_options(site, theme, default_site_options())
}

///|
/// Render all pages in a documentation site with custom theme and options.
pub fn render_site_with_options(
  site : DocSite,
  theme : SiteTheme,
  options : SiteOptions,
) -> Array[RenderedPage] {
  site.pages.map(page => render_page_with_options(site, page, theme, options))
}

///|
/// Build all static output files for a site without touching the filesystem.
pub fn build_site_manifest(site : DocSite) -> Array[OutputFile] {
  build_site_manifest_with_theme(site, default_theme())
}

///|
/// Build all static output files for a site using a custom theme.
pub fn build_site_manifest_with_theme(
  site : DocSite,
  theme : SiteTheme,
) -> Array[OutputFile] {
  build_site_manifest_with_options(site, theme, default_site_options())
}

///|
/// Build all static output files using custom theme and template options.
pub fn build_site_manifest_with_options(
  site : DocSite,
  theme : SiteTheme,
  options : SiteOptions,
) -> Array[OutputFile] {
  let files : Array[OutputFile] = []
  for page in site.pages {
    let rendered = render_page_with_options(site, page, theme, options)
    files.push({ path: rendered.path, content: rendered.html })
  }
  match build_index_page(site) {
    Some(content) => files.push({ path: "index.html", content })
    None => ()
  }
  files.push({ path: "search-index.json", content: build_search_index(site) })
  files.push({ path: "sitemap.xml", content: build_sitemap(site) })
  files.push({ path: "robots.txt", content: build_robots_txt() })
  files.push({
    path: "site-manifest.json",
    content: build_output_manifest_json(files),
  })
  files.sort_by((left, right) => left.path.compare(right.path))
  files
}

///|
/// Build a lightweight root page that directs visitors to the first route.
pub fn build_index_page(site : DocSite) -> String? {
  let routes = plan_routes(site)
  if routes.length() == 0 {
    return None
  }
  let first = routes[0]
  let title = html_escape(site.title)
  let path = html_escape(first.path)
  Some(
    "<!doctype html>\n<html lang=\"en\"><head><meta charset=\"utf-8\">\n" +
    "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n" +
    "<meta http-equiv=\"refresh\" content=\"0; url=" +
    path +
    "\">\n<title>" +
    title +
    "</title></head><body>\n<p>Open <a href=\"" +
    path +
    "\">" +
    title +
    "</a>.</p>\n</body></html>\n",
  )
}

///|
/// Build a robots.txt file that points crawlers to the generated sitemap.
pub fn build_robots_txt() -> String {
  "User-agent: *\nAllow: /\nSitemap: sitemap.xml\n"
}

///|
/// Build a machine-readable manifest for generated output files.
pub fn build_output_manifest_json(files : Array[OutputFile]) -> String {
  let report = inspect_manifest(files)
  let out = StringBuilder()
  out.write_string("{\n")
  out.write_string("  \"file_count\": ")
  out.write_string(report.file_count.to_string())
  out.write_string(",\n  \"html_count\": ")
  out.write_string(report.html_count.to_string())
  out.write_string(",\n  \"data_count\": ")
  out.write_string(report.data_count.to_string())
  out.write_string(",\n  \"total_bytes\": ")
  out.write_string(report.total_bytes.to_string())
  out.write_string(",\n  \"files\": [\n")
  for i, file in report.files {
    out.write_string("    {\"path\":\"")
    out.write_string(json_escape(file.path))
    out.write_string("\",\"kind\":\"")
    out.write_string(json_escape(file.kind))
    out.write_string("\",\"bytes\":")
    out.write_string(file.byte_count.to_string())
    out.write_string("}")
    if i + 1 < report.files.length() {
      out.write_string(",")
    }
    out.write_string("\n")
  }
  out.write_string("  ]\n}\n")
  out.to_string()
}

///|
/// Build a minimal XML sitemap for generated HTML pages.
pub fn build_sitemap(site : DocSite) -> String {
  let routes = plan_routes(site)
  let out = StringBuilder()
  out.write_string("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
  out.write_string(
    "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n",
  )
  for route in routes {
    out.write_string("  <url><loc>")
    out.write_string(xml_escape(route.path))
    out.write_string("</loc></url>\n")
  }
  out.write_string("</urlset>\n")
  out.to_string()
}

///|
/// Inspect generated output files and return a deterministic build report.
pub fn inspect_manifest(files : Array[OutputFile]) -> BuildReport {
  let infos : Array[OutputFileInfo] = []
  let mut html_count = 0
  let mut data_count = 0
  let mut total_bytes = 0
  for file in files {
    let kind = classify_output(file.path)
    if kind == "html" {
      html_count = html_count + 1
    } else if kind == "data" {
      data_count = data_count + 1
    }
    total_bytes = total_bytes + file.content.length()
    infos.push({ path: file.path, kind, byte_count: file.content.length() })
  }
  infos.sort_by((left, right) => left.path.compare(right.path))
  {
    file_count: infos.length(),
    html_count,
    data_count,
    total_bytes,
    files: infos,
  }
}

///|
/// Build a report for the default generated site manifest.
pub fn build_site_report(site : DocSite) -> BuildReport {
  inspect_manifest(build_site_manifest(site))
}

///|
/// Evaluate a documentation site against basic publish-readiness checks.
pub fn evaluate_quality(site : DocSite) -> QualityGate {
  let checks : Array[QualityCheck] = []
  let validation = validate_site(site)
  let metrics = measure_site(site)
  let build = build_site_report(site)
  let max_page_reading_minutes = max_page_reading_minutes(site)
  checks.push({
    name: "validation",
    passed: !has_validation_errors(validation),
    message: if has_validation_errors(validation) {
      "site has validation errors"
    } else {
      "site validation passed"
    },
  })
  checks.push({
    name: "content",
    passed: metrics.word_count > 0 && metrics.heading_count > 0,
    message: if metrics.word_count > 0 && metrics.heading_count > 0 {
      "site has measurable documentation content"
    } else {
      "site needs headings and body content"
    },
  })
  checks.push({
    name: "outputs",
    passed: build.html_count == metrics.page_count + 1 && build.data_count >= 2,
    message: if build.html_count == metrics.page_count + 1 &&
      build.data_count >= 2 {
      "manifest includes html pages and data outputs"
    } else {
      "manifest output mix is incomplete"
    },
  })
  checks.push({
    name: "readability",
    passed: max_page_reading_minutes <= 30,
    message: if max_page_reading_minutes <= 30 {
      "every page is within the baseline reading threshold"
    } else {
      "one or more pages may need splitting into smaller pages"
    },
  })
  let mut passed_count = 0
  for check in checks {
    if check.passed {
      passed_count = passed_count + 1
    }
  }
  {
    passed: passed_count == checks.length(),
    score: if checks.length() == 0 {
      0
    } else {
      passed_count * 100 / checks.length()
    },
    checks,
  }
}

///|
fn max_page_reading_minutes(site : DocSite) -> Int {
  let mut maximum = 0
  for page in site.pages {
    let minutes = measure_document(page.source).reading_minutes
    if minutes > maximum {
      maximum = minutes
    }
  }
  maximum
}

///|
/// Build a small JSON search index for the rendered site.
pub fn build_search_index(site : DocSite) -> String {
  let entries = collect_search_entries(site)
  let out = StringBuilder()
  out.write_string("[")
  for i, entry in entries {
    if i > 0 {
      out.write_string(",")
    }
    out.write_string("{\"title\":\"")
    out.write_string(json_escape(entry.title))
    out.write_string("\",\"path\":\"")
    out.write_string(json_escape(entry.path))
    out.write_string("\",\"text\":\"")
    out.write_string(json_escape(entry.text))
    out.write_string("\",\"tags\":[")
    for j, tag in entry.tags {
      if j > 0 {
        out.write_string(",")
      }
      out.write_string("\"")
      out.write_string(json_escape(tag))
      out.write_string("\"")
    }
    out.write_string("]}")
  }
  out.write_string("]")
  out.to_string()
}

///|
/// Collect structured search entries before JSON serialization.
pub fn collect_search_entries(site : DocSite) -> Array[SearchEntry] {
  let entries : Array[SearchEntry] = []
  for page in site.pages {
    let route = route_for_page(page)
    let doc = parse_document(page.source)
    entries.push({
      title: route.title,
      path: route.path,
      text: blocks_to_plain_text(doc.blocks),
      tags: route.tags,
    })
  }
  entries.sort_by((left, right) => left.path.compare(right.path))
  entries
}

///|
/// Summarize the generated site for demos, logs and validation.
pub fn summarize_site(site : DocSite) -> SiteSummary {
  let routes = plan_routes(site)
  let manifest = build_site_manifest(site)
  let search_entries = collect_search_entries(site)
  let tags : Array[String] = []
  for route in routes {
    for tag in route.tags {
      if !tags.contains(tag) {
        tags.push(tag)
      }
    }
  }
  {
    page_count: routes.length(),
    output_count: manifest.length(),
    search_entry_count: search_entries.length(),
    tag_count: tags.length(),
  }
}

///|
/// Measure content size and structure for one Markdown document.
pub fn measure_document(markdown : String) -> DocumentMetrics {
  measure_blocks(parse_blocks(markdown))
}

///|
/// Measure content size and structure for parsed Markdown blocks.
pub fn measure_blocks(blocks : Array[MarkdownBlock]) -> DocumentMetrics {
  let mut heading_count = 0
  let mut paragraph_count = 0
  let mut list_item_count = 0
  let mut code_block_count = 0
  let mut word_count = 0
  for block in blocks {
    match block {
      Heading(_, title) => {
        heading_count = heading_count + 1
        word_count = word_count + count_words(title)
      }
      Paragraph(text) | BlockQuote(text) => {
        paragraph_count = paragraph_count + 1
        word_count = word_count + count_words(text)
      }
      UnorderedList(items) =>
        for item in items {
          list_item_count = list_item_count + 1
          word_count = word_count + count_words(item)
        }
      CodeBlock(_, _) => code_block_count = code_block_count + 1
    }
  }
  {
    heading_count,
    paragraph_count,
    list_item_count,
    code_block_count,
    word_count,
    reading_minutes: reading_minutes_for_words(word_count),
  }
}

///|
/// Measure aggregate content size and structure for all site pages.
pub fn measure_site(site : DocSite) -> SiteMetrics {
  let mut heading_count = 0
  let mut code_block_count = 0
  let mut word_count = 0
  for page in site.pages {
    let metrics = measure_document(page.source)
    heading_count = heading_count + metrics.heading_count
    code_block_count = code_block_count + metrics.code_block_count
    word_count = word_count + metrics.word_count
  }
  {
    page_count: site.pages.length(),
    heading_count,
    code_block_count,
    word_count,
    reading_minutes: reading_minutes_for_words(word_count),
  }
}

///|
/// Validate a site before rendering or publishing.
pub fn validate_site(site : DocSite) -> ValidationReport {
  let diagnostics : Array[SiteDiagnostic] = []
  if site.title.trim().to_owned() == "" {
    diagnostics.push({
      level: DiagWarning,
      code: "empty-site-title",
      message: "site title is empty",
      page: None,
    })
  }
  if site.pages.length() == 0 {
    diagnostics.push({
      level: DiagError,
      code: "empty-site",
      message: "site has no pages",
      page: None,
    })
  }
  let paths : Array[String] = []
  for page in site.pages {
    validate_page(page, paths, diagnostics)
  }
  { diagnostics, }
}

///|
fn validate_page(
  page : DocPage,
  paths : Array[String],
  diagnostics : Array[SiteDiagnostic],
) -> Unit {
  let route = route_for_page(page)
  let page_name = if page.title.trim().to_owned() == "" {
    page.slug
  } else {
    page.title
  }
  if route.title.trim().to_owned() == "" {
    diagnostics.push({
      level: DiagError,
      code: "empty-page-title",
      message: "page title is empty",
      page: Some(page_name),
    })
  }
  if route.slug.trim().to_owned() == "" {
    diagnostics.push({
      level: DiagError,
      code: "empty-route",
      message: "page route slug is empty",
      page: Some(page_name),
    })
  } else if paths.contains(route.path) {
    diagnostics.push({
      level: DiagError,
      code: "duplicate-route",
      message: "more than one page renders to " + route.path,
      page: Some(page_name),
    })
  } else {
    paths.push(route.path)
  }
  if page.source.trim().to_owned() == "" {
    diagnostics.push({
      level: DiagWarning,
      code: "empty-source",
      message: "page source is empty",
      page: Some(page_name),
    })
  }
}

///|
/// Return true when a validation report contains at least one error.
pub fn has_validation_errors(report : ValidationReport) -> Bool {
  for diagnostic in report.diagnostics {
    match diagnostic.level {
      DiagError => return true
      DiagWarning => ()
    }
  }
  false
}

///|
/// Render diagnostics as stable text for CLI output and logs.
pub fn diagnostics_to_text(report : ValidationReport) -> String {
  if report.diagnostics.length() == 0 {
    return "ok"
  }
  let out = StringBuilder()
  for diagnostic in report.diagnostics {
    match diagnostic.level {
      DiagError => out.write_string("error")
      DiagWarning => out.write_string("warning")
    }
    out.write_string(" ")
    out.write_string(diagnostic.code)
    match diagnostic.page {
      Some(page) => {
        out.write_string(" [")
        out.write_string(page)
        out.write_string("]")
      }
      None => ()
    }
    out.write_string(": ")
    out.write_string(diagnostic.message)
    out.write_char('\n')
  }
  out.to_string()
}

///|
fn blocks_to_plain_text(blocks : Array[MarkdownBlock]) -> String {
  let out = StringBuilder()
  for block in blocks {
    match block {
      Heading(_, text) | Paragraph(text) | BlockQuote(text) =>
        append_search_text(out, text)
      UnorderedList(items) =>
        for item in items {
          append_search_text(out, item)
        }
      CodeBlock(_, code) => append_search_text(out, code)
    }
  }
  out.to_string()
}

///|
fn append_search_text(out : StringBuilder, text : String) -> Unit {
  if !out.is_empty() {
    out.write_char(' ')
  }
  out.write_string(text.trim().to_owned())
}

///|
fn count_words(text : String) -> Int {
  let mut count = 0
  let mut in_word = false
  for _, ch in text {
    let lower = ch.to_ascii_lowercase()
    let is_word = lower is ('a'..='z') || lower is ('0'..='9')
    if is_word && !in_word {
      count = count + 1
    }
    in_word = is_word
  }
  count
}

///|
fn reading_minutes_for_words(word_count : Int) -> Int {
  if word_count == 0 {
    0
  } else {
    (word_count + 199) / 200
  }
}

///|
fn json_escape(input : String) -> String {
  let out = StringBuilder(size_hint=input.length())
  for _, ch in input {
    match ch {
      '"' => out.write_string("\\\"")
      '\\' => out.write_string("\\\\")
      '\n' => out.write_string("\\n")
      '\r' => out.write_string("\\r")
      '\t' => out.write_string("\\t")
      _ => out.write_char(ch)
    }
  }
  out.to_string()
}

///|
fn xml_escape(input : String) -> String {
  let out = StringBuilder(size_hint=input.length())
  for _, ch in input {
    match ch {
      '&' => out.write_string("&amp;")
      '<' => out.write_string("&lt;")
      '>' => out.write_string("&gt;")
      '"' => out.write_string("&quot;")
      '\'' => out.write_string("&apos;")
      _ => out.write_char(ch)
    }
  }
  out.to_string()
}

///|
fn classify_output(path : String) -> String {
  if path.has_suffix(".html") || path.has_suffix(".htm") {
    "html"
  } else if path.has_suffix(".json") || path.has_suffix(".xml") {
    "data"
  } else {
    "asset"
  }
}

///|
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

///|
fn render_theme_style(theme : SiteTheme) -> String {
  let sidebar_width = positive_or_default(theme.sidebar_width_px, 240)
  let content_width = positive_or_default(theme.content_width_px, 820)
  let main_margin = sidebar_width + 60
  let out = StringBuilder()
  out.write_string(
    "<style>:root{color-scheme:light}*{box-sizing:border-box}html{scroll-behavior:smooth}body{margin:0;font:16px/1.7 system-ui,-apple-system,\"Segoe UI\",sans-serif;color:",
  )
  out.write_string(theme.text)
  out.write_string(";background:")
  out.write_string(theme.background)
  out.write_string("}aside{position:fixed;z-index:2;inset:0 auto 0 0;width:")
  out.write_string(sidebar_width.to_string())
  out.write_string("px;padding:28px 20px;overflow-y:auto;background:")
  out.write_string(theme.surface)
  out.write_string(";border-right:1px solid ")
  out.write_string(theme.border)
  out.write_string(
    "}.brand{display:flex;align-items:center;gap:10px;padding:0 10px;color:",
  )
  out.write_string(theme.text)
  out.write_string(
    ";font-weight:750;font-size:17px}.brand-mark{display:grid;place-items:center;width:30px;height:30px;border-radius:7px;background:",
  )
  out.write_string(theme.accent)
  out.write_string(";color:")
  out.write_string(theme.surface)
  out.write_string(
    "}.search{position:relative;margin:24px 0 12px}.search label{position:absolute;width:1px;height:1px;overflow:hidden;clip:rect(0 0 0 0)}.search input{width:100%;padding:9px 10px;border:1px solid ",
  )
  out.write_string(theme.border)
  out.write_string(";border-radius:6px;background:")
  out.write_string(theme.background)
  out.write_string(";color:")
  out.write_string(theme.text)
  out.write_string("}.search input:focus{outline:2px solid ")
  out.write_string(theme.accent)
  out.write_string(
    ";outline-offset:1px}.search-results{display:grid;position:absolute;z-index:3;top:44px;left:0;right:0;max-height:320px;overflow:auto;padding:6px;border:1px solid ",
  )
  out.write_string(theme.border)
  out.write_string(";border-radius:7px;background:")
  out.write_string(theme.surface)
  out.write_string(
    ";box-shadow:0 12px 30px rgba(23,32,51,.14)}.search-results[hidden]{display:none}.search-results a{display:grid;gap:2px;padding:8px;border-radius:5px;color:",
  )
  out.write_string(theme.text)
  out.write_string("}.search-results a:hover{background:")
  out.write_string(theme.background)
  out.write_string(
    ";text-decoration:none}.search-results span{padding:8px;font-size:13px;line-height:1.35;opacity:.72}.search-results a span{padding:0}nav{display:grid;gap:4px;margin-top:16px}nav a{padding:8px 10px;border-radius:6px;color:",
  )
  out.write_string(theme.text)
  out.write_string("}nav a:hover{background:")
  out.write_string(theme.background)
  out.write_string("}nav a.active{background:")
  out.write_string(theme.background)
  out.write_string(";color:")
  out.write_string(theme.accent)
  out.write_string(";font-weight:650}a{color:")
  out.write_string(theme.accent)
  out.write_string(
    ";text-decoration:none}a:hover{text-decoration:underline}main{min-height:100vh;margin-left:",
  )
  out.write_string(sidebar_width.to_string())
  out.write_string("px}.content{max-width:")
  out.write_string(content_width.to_string())
  out.write_string(
    "px;margin:0 auto;padding:52px 36px 72px}h1,h2{line-height:1.25;letter-spacing:0}h1{font-size:36px;margin:0 0 22px}h2{font-size:24px;margin:42px 0 14px;padding-top:10px;border-top:1px solid ",
  )
  out.write_string(theme.border)
  out.write_string(
    "}p,ul,blockquote{margin:0 0 18px}blockquote{padding:10px 18px;border-left:3px solid ",
  )
  out.write_string(theme.accent)
  out.write_string(";background:")
  out.write_string(theme.surface)
  out.write_string("}.toc{padding:16px 18px;margin:0 0 34px;border:1px solid ")
  out.write_string(theme.border)
  out.write_string(";background:")
  out.write_string(theme.surface)
  out.write_string(
    ";border-radius:7px}.toc-title{font-weight:700;margin-bottom:8px}.toc a{display:block;padding:2px 0}.toc .level-2{padding-left:16px}pre{padding:18px 20px;border-radius:7px;background:",
  )
  out.write_string(theme.code_background)
  out.write_string(";color:")
  out.write_string(theme.code_text)
  out.write_string(
    ";overflow:auto}code{font-family:ui-monospace,\"Cascadia Code\",monospace}p code,li code,footer code{padding:2px 5px;border:1px solid ",
  )
  out.write_string(theme.border)
  out.write_string(";border-radius:4px;background:")
  out.write_string(theme.surface)
  out.write_string(
    "}footer{margin-top:52px;padding-top:20px;border-top:1px solid ",
  )
  out.write_string(theme.border)
  out.write_string(";font-size:14px;opacity:.75}@media(max-width:")
  out.write_string((main_margin + content_width).to_string())
  out.write_string(
    "px){.content{margin:0;padding-left:32px;padding-right:32px}}@media(max-width:760px){aside{position:relative;width:auto;padding:18px 20px;border-right:0;border-bottom:1px solid ",
  )
  out.write_string(theme.border)
  out.write_string(
    "}.brand{padding:0}.search{margin:16px 0 10px}.search-results{position:relative;top:6px}nav{display:flex;gap:6px;margin-top:14px;overflow-x:auto}nav a{white-space:nowrap}main{margin-left:0}.content{padding:32px 20px 56px}h1{font-size:30px}h2{font-size:22px}.toc{margin-bottom:28px}}@media(prefers-reduced-motion:reduce){html{scroll-behavior:auto}}</style>\n",
  )
  out.to_string()
}

///|
fn positive_or_default(value : Int, fallback : Int) -> Int {
  if value > 0 {
    value
  } else {
    fallback
  }
}

///|
fn safe_language(language : String) -> String {
  let value = language.trim().to_owned()
  if value == "" {
    return "en"
  }
  for _, ch in value {
    let lower = ch.to_ascii_lowercase()
    if !(lower is ('a'..='z')) && !(lower is ('0'..='9')) && ch != '-' {
      return "en"
    }
  }
  value
}

///|
fn render_toc(items : Array[TocItem]) -> String {
  if items.length() == 0 {
    return ""
  }
  let out = StringBuilder()
  out.write_string(
    "<section class=\"toc\"><div class=\"toc-title\">On this page</div>\n",
  )
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
