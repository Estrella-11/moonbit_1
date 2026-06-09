from html import escape
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "examples" / "site"
OUT = ROOT / "dist-example"


def split_front_matter(text: str) -> tuple[dict[str, str], str]:
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return {}, text
    meta: dict[str, str] = {}
    body_start = None
    for i, line in enumerate(lines[1:], start=1):
        if line.strip() == "---":
            body_start = i + 1
            break
        if ":" in line:
            key, value = line.split(":", 1)
            meta[key.strip()] = value.strip().strip("\"'")
    if body_start is None:
        return {}, text
    return meta, "\n".join(lines[body_start:])


def slugify(text: str) -> str:
    chars = []
    dash = False
    for ch in text.lower():
        if ch.isalnum():
            if dash and chars:
                chars.append("-")
            chars.append(ch)
            dash = False
        else:
            dash = bool(chars)
    return "".join(chars) or "section"


def safe_href(href: str) -> str:
    value = href.strip()
    if (
        value.startswith(("http://", "https://", "#", "./", "../"))
        or ":" not in value
    ):
        return value
    return "#"


def render_inline(text: str) -> str:
    parts: list[str] = []
    i = 0
    while i < len(text):
        if text.startswith("`", i):
            close = text.find("`", i + 1)
            if close != -1:
                parts.append(f"<code>{escape(text[i + 1:close])}</code>")
                i = close + 1
                continue
        if text.startswith("**", i):
            close = text.find("**", i + 2)
            if close != -1:
                parts.append(f"<strong>{render_inline(text[i + 2:close])}</strong>")
                i = close + 2
                continue
        if text[i] == "[":
            label_end = text.find("]", i + 1)
            if label_end != -1 and label_end + 1 < len(text) and text[label_end + 1] == "(":
                href_end = text.find(")", label_end + 2)
                if href_end != -1:
                    label = render_inline(text[i + 1:label_end])
                    href = escape(safe_href(text[label_end + 2:href_end]), quote=True)
                    parts.append(f'<a href="{href}">{label}</a>')
                    i = href_end + 1
                    continue
        parts.append(escape(text[i]))
        i += 1
    return "".join(parts)


def render_markdown(markdown: str) -> str:
    html = []
    in_list = False
    in_code = False
    code_lines: list[str] = []
    for raw in markdown.splitlines():
        line = raw.strip()
        if line.startswith("```"):
            if in_code:
                html.append("<pre><code>" + escape("\n".join(code_lines)) + "</code></pre>")
                code_lines = []
            in_code = not in_code
            continue
        if in_code:
            code_lines.append(raw)
            continue
        if not line:
            if in_list:
                html.append("</ul>")
                in_list = False
            continue
        if line.startswith("# "):
            if in_list:
                html.append("</ul>")
                in_list = False
            text = line[2:].strip()
            html.append(f'<h1 id="{slugify(text)}">{escape(text)}</h1>')
        elif line.startswith("## "):
            if in_list:
                html.append("</ul>")
                in_list = False
            text = line[3:].strip()
            html.append(f'<h2 id="{slugify(text)}">{escape(text)}</h2>')
        elif line.startswith("- "):
            if not in_list:
                html.append("<ul>")
                in_list = True
            html.append(f"<li>{render_inline(line[2:].strip())}</li>")
        else:
            if in_list:
                html.append("</ul>")
                in_list = False
            html.append(f"<p>{render_inline(line)}</p>")
    if in_list:
        html.append("</ul>")
    return "\n".join(html)


def page_shell(title: str, nav: str, body: str) -> str:
    return f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="MoonDocKit example documentation site">
  <title>{escape(title)} - MoonDocKit Example</title>
  <style>
    body {{ margin: 0; font: 16px/1.6 system-ui, sans-serif; color: #172033; }}
    aside {{ position: fixed; inset: 0 auto 0 0; width: 240px; padding: 28px; background: #f6f8fc; border-right: 1px solid #dde3ee; }}
    nav {{ display: grid; gap: 8px; margin-top: 18px; }}
    main {{ max-width: 820px; margin-left: 300px; padding: 42px 32px; }}
    a {{ color: #2457c5; text-decoration: none; }}
    pre {{ padding: 16px; background: #101828; color: #eef4ff; overflow: auto; }}
    footer {{ margin-top: 40px; padding-top: 18px; border-top: 1px solid #dde3ee; color: #5b667a; }}
  </style>
</head>
<body>
  <aside><strong>MoonDocKit Example</strong><nav>{nav}</nav></aside>
  <main>{body}<footer>Generated by <code>MoonDocKit</code></footer></main>
</body>
</html>
"""


def main() -> None:
    pages = []
    for path in SRC.glob("*.md"):
        meta, body = split_front_matter(path.read_text(encoding="utf-8"))
        title = meta.get("title", path.stem.replace("-", " ").title())
        order = int(meta.get("order", "999"))
        slug = path.stem
        pages.append((order, title, slug, body))
    pages.sort()
    OUT.mkdir(exist_ok=True)
    nav = "\n".join(f'<a href="{slug}.html">{escape(title)}</a>' for _, title, slug, _ in pages)
    search_entries = []
    for _, title, slug, body in pages:
        html = page_shell(title, nav, render_markdown(body))
        (OUT / f"{slug}.html").write_text(html, encoding="utf-8")
        search_entries.append({"title": title, "path": f"{slug}.html", "text": body.replace("\n", " ")})
    index = "[\n" + ",\n".join(
        f'  {{"title":"{escape(item["title"])}","path":"{item["path"]}","text":"{escape(item["text"])}"}}'
        for item in search_entries
    ) + "\n]\n"
    (OUT / "search-index.json").write_text(index, encoding="utf-8")
    print(f"Wrote {len(pages) + 1} files to {OUT}")


if __name__ == "__main__":
    main()
