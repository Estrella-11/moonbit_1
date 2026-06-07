from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "MoonDocKit-项目申报书-附录二模板版.pdf"
FONT = Path(r"C:\Windows\Fonts\simsun.ttc")


def register_font() -> str:
    try:
        pdfmetrics.registerFont(TTFont("SimSun", str(FONT), subfontIndex=0))
    except TypeError:
        pdfmetrics.registerFont(TTFont("SimSun", str(FONT)))
    return "SimSun"


def p(text: str, style: ParagraphStyle) -> Paragraph:
    return Paragraph(text.replace("\n", "<br/>"), style)


def bullet(items: list[str]) -> str:
    return "<br/>".join("• " + item for item in items)


def main() -> None:
    font = register_font()
    styles = getSampleStyleSheet()
    title = ParagraphStyle(
        "TitleCN",
        parent=styles["Title"],
        fontName=font,
        fontSize=16,
        leading=20,
        textColor=colors.HexColor("#172033"),
        spaceAfter=4,
    )
    h = ParagraphStyle(
        "HeadingCN",
        parent=styles["Heading2"],
        fontName=font,
        fontSize=9.4,
        leading=11.2,
        textColor=colors.HexColor("#2457C5"),
        spaceBefore=4,
        spaceAfter=2,
    )
    body = ParagraphStyle(
        "BodyCN",
        parent=styles["BodyText"],
        fontName=font,
        fontSize=7.7,
        leading=10.2,
        textColor=colors.HexColor("#1F2937"),
        spaceAfter=2,
    )
    small = ParagraphStyle(
        "SmallCN",
        parent=body,
        fontSize=7.2,
        leading=9.4,
        textColor=colors.HexColor("#4B5563"),
    )

    doc = SimpleDocTemplate(
        str(OUT),
        pagesize=A4,
        leftMargin=13 * mm,
        rightMargin=13 * mm,
        topMargin=10 * mm,
        bottomMargin=10 * mm,
    )

    story = [
        p("MoonDocKit 项目申报书", title),
        p("2026 MoonBit 国产基础软件开源大赛 | 应用生态 / 工程基础设施 / Markdown to HTML 工具", small),
        Spacer(1, 3),
    ]

    meta = [
        ["项目名称", "MoonDocKit：MoonBit 文档站生成工具链"],
        ["参赛者", "Estrella"],
        ["联系方式", "以赛事报名表填写信息为准"],
        ["GitHub", "https://github.com/Estrella-11/moonbit_1"],
        ["Gitlink", "https://gitlink.org.cn/Estrella/moonbit"],
        ["项目方向", "MoonBit 应用生态 / 工程基础设施 / Markdown to HTML 工具"],
        ["是否为移植项目", "否，原创项目"],
    ]
    table = Table(
        [[p(a, small), p(b, small)] for a, b in meta],
        colWidths=[29 * mm, 140 * mm],
    )
    table.setStyle(
        TableStyle(
            [
                ("FONTNAME", (0, 0), (-1, -1), font),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("BACKGROUND", (0, 0), (0, -1), colors.HexColor("#EEF4FF")),
                ("GRID", (0, 0), (-1, -1), 0.35, colors.HexColor("#D8DEE9")),
                ("LEFTPADDING", (0, 0), (-1, -1), 4),
                ("RIGHTPADDING", (0, 0), (-1, -1), 4),
                ("TOPPADDING", (0, 0), (-1, -1), 2.5),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 2.5),
            ]
        )
    )
    story += [p("基本信息", h), table, Spacer(1, 3)]

    sections = [
        (
            "项目简介",
            "MoonDocKit 计划为 MoonBit 生态提供一个轻量、可测试、可发布的文档站生成工具链。项目面向 MoonBit 包作者、示例工程维护者、教程作者和生态项目开发者，帮助他们将 README、教程、API 文档、示例说明和更新日志生成可浏览的静态 HTML 文档站。本项目不是单纯重复实现通用 Markdown parser，而是围绕 MoonBit 包文档发布场景，提供页面模型、Front Matter 元数据、路由规划、侧边栏导航、页面目录、搜索索引、站点校验、主题配置、示例站点和验收脚本。",
        ),
        (
            "核心功能范围",
            bullet(
                [
                    "提供 DocPage、DocSite、RenderedPage、OutputFile 等文档站核心数据模型；",
                    "支持安全 HTML 转义、稳定 slug、块级 Markdown AST、Front Matter、路由规划和侧边栏导航；",
                    "支持页面目录、重复标题 anchor 去重、静态输出 manifest 和 JSON 搜索索引；",
                    "支持站点摘要、站点校验诊断和主题配置，发现空站点、空标题、重复路由等问题；",
                    "提供可运行 demo、示例文档站、CI、测试、验收脚本、开发日志和发布说明。",
                ]
            ),
        ),
        (
            "原创及参考说明",
            bullet(
                [
                    "本项目为原创项目，不是对某个已有开源仓库的直接移植；",
                    "产品形态参考成熟静态文档站工具的常见能力，但核心模型、API、解析逻辑、渲染逻辑和测试均使用 MoonBit 重新设计实现；",
                    "项目采用 Apache-2.0 许可证，不包含未经授权的私有代码、闭源代码或商业代码。",
                ]
            ),
        ),
        (
            "实施计划",
            bullet(
                [
                    "立项阶段：完成 MoonBit 模块初始化、许可证、README、CI、基础模型、demo、申报书和双仓库同步；",
                    "开发阶段：完善 Markdown AST、Front Matter、路由、TOC、搜索索引、校验诊断、主题配置、示例站点和测试；",
                    "验收阶段：确保 moon check、moon test、moon run cmd/main、python tools/verify_project.py 可复现，并补充 mooncakes.io 发布；",
                    "展示阶段：展示从 Markdown 源文件到静态文档站、搜索索引、校验诊断和主题配置的完整流程。",
                ]
            ),
        ),
        (
            "最终交付",
            bullet(
                [
                    "以 MoonBit 为主要实现语言的可复用文档站生成工具包；",
                    "GitHub 与 Gitlink 双公开仓库，保留连续、清晰、可追踪的提交历史；",
                    "README、开发日志、验收指南、最终提交说明、release notes 和 mooncakes.io 发布计划；",
                    "可运行 demo、示例文档站、生成结果、一键验证脚本和覆盖核心路径的 MoonBit 测试。",
                ]
            ),
        ),
    ]

    for heading, text in sections:
        story.append(p(heading, h))
        story.append(p(text, body))

    doc.build(story)
    print(OUT)


if __name__ == "__main__":
    main()
