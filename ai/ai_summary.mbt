///|
/// AI-generated content summary for a documentation page.
pub(all) struct PageSummary {
  title : String
  summary : String
  keywords : Array[String]
  key_sections : Array[String]
  estimated_audience : String
  content_type : String
}

///|
/// Determine the content type from parsed blocks.
fn detect_content_type(blocks : Array[@lib.MarkdownBlock]) -> String {
  let mut has_code = false
  let mut has_headings = false
  let mut has_lists = false
  let mut has_paragraphs = false
  for block in blocks {
    match block {
      @lib.MarkdownBlock::CodeBlock(_, _) => has_code = true
      @lib.MarkdownBlock::Heading(_, _) => has_headings = true
      @lib.MarkdownBlock::UnorderedList(_) => has_lists = true
      @lib.MarkdownBlock::Paragraph(_) => has_paragraphs = true
      _ => ()
    }
  }
  if has_code && has_headings {
    "tutorial"
  } else if has_code && !has_headings {
    "code-snippet"
  } else if has_lists && has_headings {
    "reference"
  } else if has_paragraphs && !has_code {
    "guide"
  } else {
    "document"
  }
}

///|
/// Extract the first sentence from text content as a summary fragment.
fn first_sentence(text : String) -> String {
  let mut end = 0
  while end < text.length() {
    let ch = text[end:end + 1]
    if ch == "." || ch == "!" || ch == "?" {
      if end + 1 < text.length() && text[end + 1:end + 2] == "\n" {
        return text[0:end + 1].to_owned()
      }
      if end + 1 >= text.length() {
        return text[0:end + 1].to_owned()
      }
    }
    end = end + 1
  }
  if text.length() > 120 {
    text[0:120].to_owned() + "..."
  } else {
    text
  }
}

///|
/// Count word frequency and return the top keywords.
fn extract_keywords(content : String, max_count : Int) -> Array[String] {
  let words = content.split(" ").collect()
  let unique_words : Array[String] = []
  let counts : Array[Int] = []
  for word in words {
    let w = word.trim().to_owned().to_lower()
    if w.length() < 4 {
      continue
    }
    let mut found = false
    let mut j = 0
    while j < unique_words.length() {
      if unique_words[j] == w {
        counts[j] = counts[j] + 1
        found = true
        j = unique_words.length()
      }
      j = j + 1
    }
    if !found {
      unique_words.push(w)
      counts.push(1)
    }
  }
  let mut idx = 0
  while idx < unique_words.length() {
    let mut max_idx = idx
    let mut k = idx + 1
    while k < unique_words.length() {
      if counts[k] > counts[max_idx] {
        max_idx = k
      }
      k = k + 1
    }
    if max_idx != idx {
      let tmp_word = unique_words[idx]
      unique_words[idx] = unique_words[max_idx]
      unique_words[max_idx] = tmp_word
      let tmp_count = counts[idx]
      counts[idx] = counts[max_idx]
      counts[max_idx] = tmp_count
    }
    idx = idx + 1
  }
  let result : Array[String] = []
  let limit = if unique_words.length() < max_count {
    unique_words.length()
  } else {
    max_count
  }
  let mut i = 0
  while i < limit {
    result.push(unique_words[i])
    i = i + 1
  }
  result
}

///|
/// Estimate the target audience from content complexity.
fn estimate_audience(
  metrics : @lib.DocumentMetrics,
  content_type : String,
) -> String {
  if metrics.word_count < 10 {
    "beginner"
  } else if metrics.code_block_count >= 3 && metrics.word_count >= 15 {
    "developer"
  } else if content_type == "tutorial" {
    "intermediate"
  } else if content_type == "reference" {
    "advanced"
  } else {
    "general"
  }
}

///|
/// Generate a summary for a documentation page.
pub fn summarize_page(title : String, content : String) -> PageSummary {
  let blocks = @lib.parse_blocks(content)
  let metrics = @lib.measure_blocks(blocks)
  let content_type = detect_content_type(blocks)
  let headings = @lib.extract_headings(blocks)
  let key_sections : Array[String] = []
  for h in headings {
    if h.level <= 2 {
      key_sections.push(h.title)
    }
  }
  let mut first_para = ""
  for block in blocks {
    match block {
      @lib.MarkdownBlock::Paragraph(text) =>
        if first_para == "" {
          first_para = first_sentence(text)
        }
      _ => ()
    }
  }
  let summary = if first_para != "" {
    first_para
  } else {
    "This page covers \{title} with \{metrics.word_count} words across \{metrics.heading_count} sections."
  }
  let keywords = extract_keywords(content, 5)
  let audience = estimate_audience(metrics, content_type)
  {
    title,
    summary,
    keywords,
    key_sections,
    estimated_audience: audience,
    content_type,
  }
}

///|
/// Generate summaries for all pages in a documentation site.
pub fn summarize_site(site : @lib.DocSite) -> Array[PageSummary] {
  let summaries : Array[PageSummary] = []
  for page in site.pages {
    summaries.push(summarize_page(page.title, page.source))
  }
  summaries
}

///|
/// Convert a page summary to a Markdown snippet.
pub fn summary_to_markdown(summary : PageSummary) -> String {
  let out = StringBuilder()
  out.write_string("### ")
  out.write_string(summary.title)
  out.write_string("\n\n")
  out.write_string("**Summary:** ")
  out.write_string(summary.summary)
  out.write_string("\n\n")
  out.write_string("**Type:** ")
  out.write_string(summary.content_type)
  out.write_string(" | **Audience:** ")
  out.write_string(summary.estimated_audience)
  out.write_string("\n\n")
  out.write_string("**Keywords:** ")
  let mut i = 0
  while i < summary.keywords.length() {
    if i > 0 {
      out.write_string(", ")
    }
    out.write_string("`")
    out.write_string(summary.keywords[i])
    out.write_string("`")
    i = i + 1
  }
  out.write_string("\n\n")
  if summary.key_sections.length() > 0 {
    out.write_string("**Key Sections:**\n")
    for s in summary.key_sections {
      out.write_string("- ")
      out.write_string(s)
      out.write_string("\n")
    }
  }
  out.to_string()
}

///|
/// Generate a site-level summary index page in Markdown.
pub fn site_summary_to_markdown(
  site_title : String,
  summaries : Array[PageSummary],
) -> String {
  let out = StringBuilder()
  out.write_string(
    "---\ntitle: AI Site Summary\norder: 800\ntags: [summary, ai-generated]\n---\n",
  )
  out.write_string("# ")
  out.write_string(site_title)
  out.write_string(" - AI Summary\n\n")
  out.write_string(
    "> Auto-generated summaries for all documentation pages.\n\n",
  )
  for s in summaries {
    out.write_string(summary_to_markdown(s))
    out.write_string("---\n\n")
  }
  out.to_string()
}
