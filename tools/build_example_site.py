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
            html.append(f"<li>{escape(line[2:].strip())}</li>")
        else:
            if in_list:
                html.append("</ul>")
                in_list = False
            html.append(f"<p>{escape(line)}</p>")
    if in_list:
        html.append("</ul>")
    return "\n".join(html)


def page_shell(title: str, nav: str, body: str) -> str:
    return f"""<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{escape(title)} - MoonDocKit Example</title>
  <style>
    body {{ margin: 0; font: 16px/1.6 system-ui, sans-serif; color: #172033; }}
    aside {{ position: fixed; inset: 0 auto 0 0; width: 240px; padding: 28px; background: #f6f8fc; border-right: 1px solid #dde3ee; }}
    nav {{ display: grid; gap: 8px; margin-top: 18px; }}
    main {{ max-width: 820px; margin-left: 300px; padding: 42px 32px; }}
    a {{ color: #2457c5; text-decoration: none; }}
    pre {{ padding: 16px; background: #101828; color: #eef4ff; overflow: auto; }}
  </style>
</head>
<body>
  <aside><strong>MoonDocKit Example</strong><nav>{nav}</nav></aside>
  <main>{body}</main>
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
