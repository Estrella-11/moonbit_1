///|
/// Browser bridge for the MoonDocKit playground.
///
/// The playground compiles this package to JavaScript and calls it from the
/// page, so reviewers can run the real MoonBit renderer without installing the
/// toolchain. Only plain strings cross the boundary: no JSON encoding, no
/// escaping rules that could silently disagree between MoonBit and JavaScript.

///|
/// Publish a three-argument render entry point on the host global object.
extern "js" fn host_expose_render(
  name : String,
  f : (String, String, String) -> String,
) -> Unit =
  #| function(name, f) {
  #|   globalThis[name] = function(markdown, title, themeName) {
  #|     return f(markdown, title, themeName);
  #|   };
  #| }

///|
/// Publish a two-argument statistics entry point on the host global object.
extern "js" fn host_expose_stats(
  name : String,
  f : (String, String) -> String,
) -> Unit =
  #| function(name, f) {
  #|   globalThis[name] = function(markdown, title) {
  #|     return f(markdown, title);
  #|   };
  #| }

///|
fn playground_site(title : String, markdown : String) -> @lib.DocSite {
  let pages : Array[@lib.DocPage] = [
    { title: title, slug: "playground", source: markdown },
  ]
  { title: title, pages: pages }
}

///|
fn select_theme(theme_name : String) -> @lib.SiteTheme {
  if theme_name == "package" {
    @lib.package_theme()
  } else {
    @lib.default_theme()
  }
}

///|
/// Render one Markdown document into a complete HTML document.
fn render_impl(
  markdown : String,
  title : String,
  theme_name : String,
) -> String {
  let site = playground_site(title, markdown)
  let page : @lib.DocPage = {
    title: title,
    slug: "playground",
    source: markdown,
  }
  let rendered = @lib.render_page_with_options(
    site,
    page,
    select_theme(theme_name),
    @lib.default_site_options(),
  )
  rendered.html
}

///|
/// Return newline-separated `key=value` metrics for one Markdown document.
fn stats_impl(markdown : String, title : String) -> String {
  let site = playground_site(title, markdown)
  let metrics = @lib.measure_site(site)
  let gate = @lib.evaluate_quality(site)
  let passed = if gate.passed { "1" } else { "0" }
  let out = StringBuilder(size_hint=256)
  out.write_string("score=\{gate.score}\n")
  out.write_string("passed=\{passed}\n")
  out.write_string("words=\{metrics.word_count}\n")
  out.write_string("headings=\{metrics.heading_count}\n")
  out.write_string("code_blocks=\{metrics.code_block_count}\n")
  out.write_string("reading_minutes=\{metrics.reading_minutes}\n")
  for check in gate.checks {
    let ok = if check.passed { "1" } else { "0" }
    out.write_string("check_\{check.name}=\{ok}\n")
  }
  out.to_string()
}

///|
fn main {
  host_expose_render("moonDocKitRenderPage", render_impl)
  host_expose_stats("moonDocKitPageStats", stats_impl)
}
