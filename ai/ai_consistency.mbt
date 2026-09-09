///|
/// A single consistency issue found across documentation pages.
pub(all) struct ConsistencyIssue {
  issue_type : String
  pages : Array[String]
  description : String
  severity : String
  suggestion : String
}

///|
/// Site-level consistency report.
pub(all) struct ConsistencyReport {
  total_issues : Int
  errors : Int
  warnings : Int
  info : Int
  issues : Array[ConsistencyIssue]
  style_score : Int
}

///|
/// Detect heading style inconsistencies across pages.
fn check_heading_styles(site : @lib.DocSite) -> Array[ConsistencyIssue] {
  let issues : Array[ConsistencyIssue] = []
  let pages_without_h1 : Array[String] = []
  let pages_with_skipped_levels : Array[String] = []
  for page in site.pages {
    let blocks = @lib.parse_blocks(page.source)
    let mut has_h1 = false
    let mut prev_level = 0
    let mut first_heading = true
    for block in blocks {
      match block {
        @lib.MarkdownBlock::Heading(level, _) => {
          if first_heading {
            if level == 1 {
              has_h1 = true
            }
            first_heading = false
          }
          if prev_level > 0 && level > prev_level + 1 {
            pages_with_skipped_levels.push(page.title)
          }
          prev_level = level
        }
        _ => ()
      }
    }
    if !has_h1 {
      pages_without_h1.push(page.title)
    }
  }
  if pages_without_h1.length() > 0 {
    issues.push({
      issue_type: "heading_style",
      pages: pages_without_h1,
      description: if pages_without_h1.length() == site.pages.length() {
        "No pages start with an H1 heading"
      } else {
        "Some pages start with H1, others do not"
      },
      severity: "warning",
      suggestion: "Ensure all pages start with an H1 heading for consistency",
    })
  }
  if pages_with_skipped_levels.length() > 0 {
    issues.push({
      issue_type: "heading_hierarchy",
      pages: pages_with_skipped_levels,
      description: "Heading level skips detected (e.g., H2 to H4)",
      severity: "warning",
      suggestion: "Don't skip heading levels; use sequential H1-H2-H3",
    })
  }
  issues
}

///|
/// Detect code block language inconsistencies.
fn check_code_languages(site : @lib.DocSite) -> Array[ConsistencyIssue] {
  let issues : Array[ConsistencyIssue] = []
  let unlabeled_pages : Array[String] = []
  let lang_counts : Array[(String, Int)] = []
  for page in site.pages {
    let blocks = @lib.parse_blocks(page.source)
    let mut has_unlabeled = false
    for block in blocks {
      match block {
        @lib.MarkdownBlock::CodeBlock(lang, _) => {
          let trimmed = lang.trim().to_owned()
          if trimmed == "" {
            has_unlabeled = true
          } else {
            increment_count(lang_counts, trimmed)
          }
        }
        _ => ()
      }
    }
    if has_unlabeled {
      unlabeled_pages.push(page.title)
    }
  }
  if unlabeled_pages.length() > 0 {
    issues.push({
      issue_type: "code_language",
      pages: unlabeled_pages,
      description: "Some code blocks lack language labels",
      severity: "info",
      suggestion: "Add language labels to all code blocks (e.g., ```moonbit)",
    })
  }
  if lang_counts.length() > 2 {
    let mut dominant_lang = ""
    let mut dominant_count = 0
    for pair in lang_counts {
      if pair.1 > dominant_count {
        dominant_lang = pair.0
        dominant_count = pair.1
      }
    }
    let minor_langs : Array[String] = []
    for pair in lang_counts {
      if pair.0 != dominant_lang && pair.1 == 1 {
        minor_langs.push(pair.0)
      }
    }
    if minor_langs.length() > 0 {
      issues.push({
        issue_type: "language_mix",
        pages: [],
        description: "Multiple code languages used; primary is \{dominant_lang}, but \{minor_langs.length()} minor language(s) appear only once",
        severity: "info",
        suggestion: "Consider standardizing on the primary code language",
      })
    }
  }
  issues
}

///|
/// Detect content length outliers.
fn check_content_length(site : @lib.DocSite) -> Array[ConsistencyIssue] {
  let issues : Array[ConsistencyIssue] = []
  if site.pages.length() < 3 {
    return issues
  }
  let page_metrics : Array[(String, Int)] = []
  let mut total_words = 0
  for page in site.pages {
    let metrics = @lib.measure_document(page.source)
    total_words = total_words + metrics.word_count
    page_metrics.push((page.title, metrics.word_count))
  }
  let avg = total_words / site.pages.length()
  let short_pages : Array[String] = []
  let long_pages : Array[String] = []
  for pair in page_metrics {
    if avg > 10 && pair.1 < avg / 3 {
      short_pages.push(pair.0)
    }
    if pair.1 > avg * 3 && avg > 5 {
      long_pages.push(pair.0)
    }
  }
  if short_pages.length() > 0 {
    issues.push({
      issue_type: "content_length",
      pages: short_pages,
      description: "Page(s) significantly shorter than site average (\{avg} words)",
      severity: "warning",
      suggestion: "Expand thin pages or merge them with related content",
    })
  }
  if long_pages.length() > 0 {
    issues.push({
      issue_type: "content_length",
      pages: long_pages,
      description: "Page(s) significantly longer than site average (\{avg} words)",
      severity: "info",
      suggestion: "Consider splitting long pages into focused topics",
    })
  }
  issues
}

///|
/// Check for duplicate content across pages.
fn check_duplicates(site : @lib.DocSite) -> Array[ConsistencyIssue] {
  let issues : Array[ConsistencyIssue] = []
  let page_blocks : Array[(String, Array[@lib.MarkdownBlock])] = []
  for page in site.pages {
    page_blocks.push((page.title, @lib.parse_blocks(page.source)))
  }
  let mut i = 0
  while i < page_blocks.length() {
    let mut j = i + 1
    while j < page_blocks.length() {
      let (title_a, blocks_a) = page_blocks[i]
      let (title_b, blocks_b) = page_blocks[j]
      let mut shared_paragraphs = 0
      for block_a in blocks_a {
        match block_a {
          @lib.MarkdownBlock::Paragraph(text_a) =>
            if text_a.trim().to_owned().length() > 20 {
              for block_b in blocks_b {
                match block_b {
                  @lib.MarkdownBlock::Paragraph(text_b) =>
                    if text_a == text_b {
                      shared_paragraphs = shared_paragraphs + 1
                    }
                  _ => ()
                }
              }
            }
          _ => ()
        }
      }
      if shared_paragraphs > 0 {
        issues.push({
          issue_type: "duplicate_content",
          pages: [title_a, title_b],
          description: "\{shared_paragraphs} identical paragraph(s) shared between pages",
          severity: "warning",
          suggestion: "Deduplicate content; link between pages instead of repeating",
        })
      }
      j = j + 1
    }
    i = i + 1
  }
  issues
}

///|
/// Run full consistency analysis on a documentation site.
pub fn check_consistency(site : @lib.DocSite) -> ConsistencyReport {
  let all_issues : Array[ConsistencyIssue] = []
  for issue in check_heading_styles(site) {
    all_issues.push(issue)
  }
  for issue in check_code_languages(site) {
    all_issues.push(issue)
  }
  for issue in check_content_length(site) {
    all_issues.push(issue)
  }
  for issue in check_duplicates(site) {
    all_issues.push(issue)
  }
  let mut error_count = 0
  let mut warning_count = 0
  let mut info_count = 0
  for issue in all_issues {
    match issue.severity {
      "error" => error_count = error_count + 1
      "warning" => warning_count = warning_count + 1
      _ => info_count = info_count + 1
    }
  }
  let style_score = if all_issues.length() == 0 {
    100
  } else {
    let penalty = error_count * 20 + warning_count * 10 + info_count * 3
    let score = 100 - penalty
    if score < 0 {
      0
    } else {
      score
    }
  }
  {
    total_issues: all_issues.length(),
    errors: error_count,
    warnings: warning_count,
    info: info_count,
    issues: all_issues,
    style_score,
  }
}

///|
/// Convert a consistency report to a Markdown page.
pub fn consistency_to_markdown(report : ConsistencyReport) -> String {
  let out = StringBuilder()
  out.write_string(
    "---\ntitle: AI Consistency Report\norder: 860\ntags: [consistency, ai-generated]\n---\n",
  )
  out.write_string("# AI Consistency Report\n\n")
  out.write_string(
    "> Documentation style and content consistency analysis.\n\n",
  )
  out.write_string("## Summary\n\n")
  out.write_string("- **Total Issues:** \{report.total_issues}\n")
  out.write_string("- **Errors:** \{report.errors}\n")
  out.write_string("- **Warnings:** \{report.warnings}\n")
  out.write_string("- **Info:** \{report.info}\n")
  out.write_string("- **Style Score:** \{report.style_score}/100\n\n")
  if report.issues.length() > 0 {
    out.write_string("## Issues\n\n")
    for issue in report.issues {
      out.write_string("### ")
      out.write_string(issue.issue_type)
      out.write_string(" (")
      out.write_string(issue.severity)
      out.write_string(")\n\n")
      out.write_string(issue.description)
      out.write_string("\n\n")
      if issue.pages.length() > 0 {
        out.write_string("**Affected pages:** ")
        let mut i = 0
        while i < issue.pages.length() {
          if i > 0 {
            out.write_string(", ")
          }
          out.write_string("`")
          out.write_string(issue.pages[i])
          out.write_string("`")
          i = i + 1
        }
        out.write_string("\n\n")
      }
      out.write_string("**Suggestion:** ")
      out.write_string(issue.suggestion)
      out.write_string("\n\n---\n\n")
    }
  } else {
    out.write_string(
      "No consistency issues detected. Documentation is uniform.\n",
    )
  }
  out.to_string()
}
