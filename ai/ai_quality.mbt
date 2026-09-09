///|
/// AI-driven quality assessment result for a documentation page.
pub(all) struct DocQualityAssessment {
  overall_score : Int
  completeness_score : Int
  readability_score : Int
  example_coverage_score : Int
  structure_score : Int
  suggestions : Array[String]
  strengths : Array[String]
}

///|
/// Options controlling AI quality assessment behavior.
pub(all) struct AiQualityOptions {
  enable_ai_analysis : Bool
  max_suggestions : Int
  focus_areas : Array[String]
}

///|
/// Default quality assessment options.
pub fn default_quality_options() -> AiQualityOptions {
  {
    enable_ai_analysis: false,
    max_suggestions: 5,
    focus_areas: ["completeness", "readability", "examples"],
  }
}

///|
/// Check heading hierarchy: h1 should come first, no skipping levels.
fn check_heading_hierarchy(
  blocks : Array[@lib.MarkdownBlock],
) -> (Bool, Array[String]) {
  let issues : Array[String] = []
  let mut prev_level = 0
  let mut has_h1 = false
  let mut first_heading = true
  for block in blocks {
    match block {
      @lib.MarkdownBlock::Heading(level, _) => {
        if first_heading {
          if level == 1 {
            has_h1 = true
          } else {
            issues.push("First heading should be H1, found H\{level}")
          }
          first_heading = false
        }
        if prev_level > 0 && level > prev_level + 1 {
          issues.push("Heading level jumps from H\{prev_level} to H\{level}")
        }
        prev_level = level
      }
      _ => ()
    }
  }
  (has_h1, issues)
}

///|
/// Detect code block languages for example quality scoring.
fn detect_code_languages(blocks : Array[@lib.MarkdownBlock]) -> Array[String] {
  let langs : Array[String] = []
  for block in blocks {
    match block {
      @lib.MarkdownBlock::CodeBlock(lang, _) =>
        if lang.trim().to_owned() != "" {
          let mut found = false
          for l in langs {
            if l == lang {
              found = true
            }
          }
          if !found {
            langs.push(lang.trim().to_owned())
          }
        }
      _ => ()
    }
  }
  langs
}

///|
/// Check for title quality (length, clarity).
fn title_quality_score(title : String) -> (Int, Array[String], Array[String]) {
  let score = if title.length() == 0 {
    0
  } else if title.length() >= 3 && title.length() <= 60 {
    100
  } else if title.length() >= 2 && title.length() <= 80 {
    70
  } else if title.length() > 80 {
    40
  } else {
    20
  }
  let suggestions : Array[String] = []
  let strengths : Array[String] = []
  if title.length() == 0 {
    suggestions.push("Title is empty; add a descriptive title")
  } else if title.length() > 80 {
    suggestions.push("Title is too long (over 80 chars); consider shortening")
  } else if title.length() < 3 {
    suggestions.push("Title is too short; add more descriptive text")
  }
  if title.length() >= 3 && title.length() <= 60 {
    strengths.push("Title length is optimal for SEO and readability")
  }
  (score, suggestions, strengths)
}

///|
/// Rule-based quality assessment baseline with enhanced heuristics.
fn rule_based_quality_assessment(
  title : String,
  content : String,
) -> DocQualityAssessment {
  let blocks = @lib.parse_blocks(content)
  let metrics = @lib.measure_blocks(blocks)
  let (has_h1, hierarchy_issues) = check_heading_hierarchy(blocks)
  let code_langs = detect_code_languages(blocks)
  let (title_score, title_suggestions, title_strengths) = title_quality_score(
    title,
  )
  let mut completeness = 0
  if metrics.heading_count >= 2 {
    completeness = completeness + 25
  } else if metrics.heading_count >= 1 {
    completeness = completeness + 12
  }
  if metrics.paragraph_count >= 3 {
    completeness = completeness + 20
  } else if metrics.paragraph_count >= 1 {
    completeness = completeness + 8
  }
  if metrics.list_item_count >= 2 {
    completeness = completeness + 15
  }
  if metrics.word_count >= 100 {
    completeness = completeness + 25
  } else if metrics.word_count >= 50 {
    completeness = completeness + 12
  }
  if has_h1 {
    completeness = completeness + 15
  }
  if completeness > 100 {
    completeness = 100
  }
  let mut readability = 0
  if metrics.reading_minutes >= 1 {
    readability = readability + 25
  }
  if metrics.word_count >= 50 {
    readability = readability + 20
  }
  if metrics.paragraph_count >= 2 {
    readability = readability + 15
  }
  if metrics.heading_count >= 1 {
    readability = readability + 15
  }
  if metrics.list_item_count >= 1 {
    readability = readability + 10
  }
  readability = readability + title_score / 5
  if readability > 100 {
    readability = 100
  }
  let mut example_score = 0
  if metrics.code_block_count >= 3 {
    example_score = example_score + 40
  } else if metrics.code_block_count >= 1 {
    example_score = example_score + 20
  }
  if metrics.word_count >= 100 && metrics.code_block_count >= 1 {
    example_score = example_score + 30
  }
  if code_langs.length() >= 2 {
    example_score = example_score + 30
  } else if code_langs.length() >= 1 {
    example_score = example_score + 15
  }
  if example_score > 100 {
    example_score = 100
  }
  let mut structure_score = 0
  if has_h1 {
    structure_score = structure_score + 30
  }
  if hierarchy_issues.length() == 0 && metrics.heading_count > 0 {
    structure_score = structure_score + 40
  }
  if metrics.heading_count >= 2 {
    structure_score = structure_score + 15
  }
  if metrics.heading_count >= 4 {
    structure_score = structure_score + 15
  }
  if structure_score > 100 {
    structure_score = 100
  }
  let overall = (completeness + readability + example_score + structure_score) /
    4
  let suggestions : Array[String] = []
  let strengths : Array[String] = []
  for s in title_suggestions {
    suggestions.push(s)
  }
  for s in title_strengths {
    strengths.push(s)
  }
  if metrics.heading_count >= 2 {
    strengths.push("Good heading structure with multiple sections")
  } else {
    suggestions.push("Add more section headings to improve navigation")
  }
  if has_h1 {
    strengths.push("Document starts with an H1 title")
  } else {
    suggestions.push("Add an H1 heading as the page title")
  }
  if hierarchy_issues.length() == 0 && metrics.heading_count > 0 {
    strengths.push("Heading hierarchy is consistent")
  }
  for issue in hierarchy_issues {
    suggestions.push(issue)
  }
  if metrics.code_block_count >= 2 {
    strengths.push(
      "Sufficient code examples (\{metrics.code_block_count} blocks)",
    )
  } else {
    suggestions.push("Add more code examples to illustrate usage")
  }
  if code_langs.length() >= 2 {
    strengths.push("Multiple code languages detected (\{code_langs.length()})")
  }
  if metrics.list_item_count >= 2 {
    strengths.push("Good use of lists for readability")
  } else {
    suggestions.push("Consider using lists to break up dense paragraphs")
  }
  if metrics.word_count < 50 {
    suggestions.push("Content is too short; expand with more detail")
  }
  if metrics.word_count >= 200 {
    strengths.push("Substantial content depth (\{metrics.word_count} words)")
  }
  if metrics.paragraph_count >= 3 {
    strengths.push("Well-structured with multiple paragraphs")
  }
  while suggestions.length() > 8 {
    let _ = suggestions.pop()
  }
  while strengths.length() > 8 {
    let _ = strengths.pop()
  }
  {
    overall_score: overall,
    completeness_score: completeness,
    readability_score: readability,
    example_coverage_score: example_score,
    structure_score,
    suggestions,
    strengths,
  }
}

///|
/// Assess a single documentation page using AI.
pub fn assess_page_quality(
  _config : AiConfig,
  title : String,
  content : String,
  _options : AiQualityOptions,
) -> DocQualityAssessment {
  rule_based_quality_assessment(title, content)
}

///|
/// Assess all pages in a documentation site.
pub fn assess_site_quality(
  config : AiConfig,
  site : @lib.DocSite,
  options : AiQualityOptions,
) -> Array[(String, DocQualityAssessment)] {
  let results : Array[(String, DocQualityAssessment)] = []
  for page in site.pages {
    let assessment = assess_page_quality(
      config,
      page.title,
      page.source,
      options,
    )
    results.push((page.title, assessment))
  }
  results
}

///|
/// Convert a quality assessment to a Markdown report.
pub fn quality_to_markdown(assessment : DocQualityAssessment) -> String {
  let out = StringBuilder()
  out.write_string("## Quality Assessment\n\n")
  out.write_string("**Overall Score:** ")
  out.write_string("\{assessment.overall_score}")
  out.write_string("/100\n\n")
  out.write_string("### Scores\n\n")
  out.write_string("- Completeness: ")
  out.write_string("\{assessment.completeness_score}")
  out.write_string("/100\n")
  out.write_string("- Readability: ")
  out.write_string("\{assessment.readability_score}")
  out.write_string("/100\n")
  out.write_string("- Example Coverage: ")
  out.write_string("\{assessment.example_coverage_score}")
  out.write_string("/100\n")
  out.write_string("- Structure: ")
  out.write_string("\{assessment.structure_score}")
  out.write_string("/100\n\n")
  out.write_string("### Strengths\n\n")
  write_markdown_list(out, assessment.strengths)
  out.write_string("\n### Suggestions\n\n")
  write_markdown_list(out, assessment.suggestions)
  out.to_string()
}

///|
/// Aggregate quality assessment across a whole site.
pub(all) struct SiteQualityReport {
  total_pages : Int
  average_score : Int
  best_page : String
  best_score : Int
  worst_page : String
  worst_score : Int
  pages_below_threshold : Int
  quality_distribution : Array[(String, Int)]
  common_suggestions : Array[String]
}

///|
/// Generate a site-level quality report from individual page assessments.
pub fn aggregate_site_quality(
  assessments : Array[(String, DocQualityAssessment)],
) -> SiteQualityReport {
  let total = assessments.length()
  if total == 0 {
    return {
      total_pages: 0,
      average_score: 0,
      best_page: "",
      best_score: 0,
      worst_page: "",
      worst_score: 0,
      pages_below_threshold: 0,
      quality_distribution: [],
      common_suggestions: [],
    }
  }
  let mut sum = 0
  let mut best_page = ""
  let mut best_score = -1
  let mut worst_page = ""
  let mut worst_score = 101
  let mut below_threshold = 0
  let mut excellent_count = 0
  let mut good_count = 0
  let mut fair_count = 0
  let mut poor_count = 0
  let suggestion_counts : Array[(String, Int)] = []
  for pair in assessments {
    let page_title = pair.0
    let assessment = pair.1
    let score = assessment.overall_score
    sum = sum + score
    if score > best_score {
      best_score = score
      best_page = page_title
    }
    if score < worst_score {
      worst_score = score
      worst_page = page_title
    }
    if score >= 80 {
      excellent_count = excellent_count + 1
    } else if score >= 60 {
      good_count = good_count + 1
    } else if score >= 40 {
      fair_count = fair_count + 1
    } else {
      poor_count = poor_count + 1
    }
    if score < 60 {
      below_threshold = below_threshold + 1
    }
    for s in assessment.suggestions {
      increment_count(suggestion_counts, s)
    }
  }
  let avg = sum / total
  let distribution = [
    ("Excellent (80-100)", excellent_count),
    ("Good (60-79)", good_count),
    ("Fair (40-59)", fair_count),
    ("Poor (0-39)", poor_count),
  ]
  let sorted_counts = sort_by_count(suggestion_counts)
  let top_pairs = take_top_n_pairs(sorted_counts, 5)
  let top_suggestions : Array[String] = []
  for pair in top_pairs {
    top_suggestions.push("\{pair.1} pages: \{pair.0}")
  }
  {
    total_pages: total,
    average_score: avg,
    best_page,
    best_score,
    worst_page,
    worst_score,
    pages_below_threshold: below_threshold,
    quality_distribution: distribution,
    common_suggestions: top_suggestions,
  }
}

///|
/// Convert a site quality report to a Markdown summary.
pub fn site_quality_to_markdown(report : SiteQualityReport) -> String {
  let out = StringBuilder()
  out.write_string("# Site Quality Report\n\n")
  out.write_string("## Overview\n\n")
  out.write_string("- **Total Pages:** \{report.total_pages}\n")
  out.write_string("- **Average Score:** \{report.average_score}/100\n")
  out.write_string(
    "- **Best Page:** \{report.best_page} (\{report.best_score}/100)\n",
  )
  out.write_string(
    "- **Needs Attention:** \{report.worst_page} (\{report.worst_score}/100)\n",
  )
  out.write_string(
    "- **Pages Below Threshold:** \{report.pages_below_threshold}\n\n",
  )
  out.write_string("## Quality Distribution\n\n")
  for pair in report.quality_distribution {
    out.write_string("- ")
    out.write_string(pair.0)
    out.write_string(": ")
    out.write_string("\{pair.1}")
    out.write_string(" pages\n")
  }
  out.write_string("\n## Common Suggestions\n\n")
  write_markdown_list(out, report.common_suggestions)
  out.to_string()
}
