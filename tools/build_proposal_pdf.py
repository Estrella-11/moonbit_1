from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "MoonDocKit-项目申报书.pdf"
FONT = Path(r"C:\Windows\Fonts\simsun.ttc")


def register_font() -> str:
    try:
        pdfmetrics.registerFont(TTFont("SimSun", str(FONT), subfontIndex=0))
        return "SimSun"
    except TypeError:
        pdfmetrics.registerFont(TTFont("SimSun", str(FONT)))
        return "SimSun"


def p(text: str, style: ParagraphStyle) -> Paragraph:
    return Paragraph(text.replace("\n", "<br/>"), style)


def main() -> None:
    font_name = register_font()
    styles = getSampleStyleSheet()
    title = ParagraphStyle(
        "TitleCN",
        parent=styles["Title"],
        fontName=font_name,
        fontSize=18,
        leading=23,
        textColor=colors.HexColor("#172033"),
        spaceAfter=6,
    )
    h = ParagraphStyle(
        "HeadingCN",
        parent=styles["Heading2"],
        fontName=font_name,
        fontSize=10.5,
        leading=13,
        textColor=colors.HexColor("#2457C5"),
        spaceBefore=5,
        spaceAfter=3,
    )
    body = ParagraphStyle(
        "BodyCN",
        parent=styles["BodyText"],
        fontName=font_name,
        fontSize=8.7,
        leading=12,
        textColor=colors.HexColor("#1F2937"),
        spaceAfter=3,
    )
    small = ParagraphStyle(
        "SmallCN",
        parent=body,
        fontSize=7.8,
        leading=10.5,
        textColor=colors.HexColor("#4B5563"),
    )

    doc = SimpleDocTemplate(
        str(OUT),
        pagesize=A4,
        leftMargin=15 * mm,
        rightMargin=15 * mm,
        topMargin=12 * mm,
        bottomMargin=12 * mm,
    )

    story = [
        p("MoonDocKit 项目申报书", title),
        p("2026 MoonBit 国产基础软件开源大赛 | 应用生态 / 工程基础设施", small),
        Spacer(1, 4),
    ]

    meta = [
        ["项目名称", "MoonDocKit：MoonBit 文档站生成工具链"],
        ["参赛者", "Estrella"],
        ["GitHub", "https://github.com/Estrella-11/moonbit_1"],
        ["Gitlink", "https://gitlink.org.cn/Estrella/moonbit"],
        ["项目性质", "原创项目；参考成熟静态文档站工具的产品形态，核心实现使用 MoonBit 重新设计。"],
    ]
    table = Table(
        [[p(a, small), p(b, small)] for a, b in meta],
        colWidths=[26 * mm, 144 * mm],
    )
    table.setStyle(
        TableStyle(
            [
                ("FONTNAME", (0, 0), (-1, -1), font_name),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("BACKGROUND", (0, 0), (0, -1), colors.HexColor("#EEF4FF")),
                ("TEXTCOLOR", (0, 0), (0, -1), colors.HexColor("#172033")),
                ("GRID", (0, 0), (-1, -1), 0.4, colors.HexColor("#D8DEE9")),
                ("LEFTPADDING", (0, 0), (-1, -1), 5),
                ("RIGHTPADDING", (0, 0), (-1, -1), 5),
                ("TOPPADDING", (0, 0), (-1, -1), 4),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
            ]
        )
    )
    story += [table, Spacer(1, 6)]

    sections = [
        (
            "项目简介",
            "MoonDocKit 面向 MoonBit 包作者、示例工程维护者和生态教程作者，提供轻量、可测试、可发布的文档站生成工具链。项目帮助开发者把 Markdown 风格的项目说明、教程、API 指南、示例和更新日志生成可浏览的静态 HTML 文档站。",
        ),
        (
            "生态价值",
            "MoonBit 生态正在快速发展，许多包需要清晰的文档、示例和发布页面。MoonDocKit 不定位为单纯 Markdown parser，而是围绕 MoonBit 包文档发布场景提供页面模型、路由、导航、目录、模板、搜索索引和可运行示例，降低生态项目维护文档的门槛。",
        ),
        (
            "已完成基础能力",
            "已完成 MoonBit 模块初始化、Apache-2.0 许可证、README、CI、开发日志和验收清单；实现 DocPage、DocSite、RenderedPage、TocItem 等核心模型；支持 HTML 安全转义、slug 生成、Markdown 子集渲染、标题提取、页面 TOC、侧边栏导航和整站渲染；提供 cmd/main 可运行示例和 5 个核心行为测试。",
        ),
        (
            "拟实现核心功能",
            "1. 块级 Markdown AST 与 front matter 解析；2. 多页面静态站点输出和资源规划；3. 标题目录、重复 anchor 处理和站内导航；4. 搜索索引生成；5. 面向 MoonBit 包文档、教程和 changelog 的默认模板；6. benchmark、测试覆盖和 mooncakes.io 发布。",
        ),
        (
            "实施计划",
            "第一阶段完成可申报基线和公开仓库同步；第二阶段将行级渲染升级为块级 AST，补充 front matter、路由规划、模板渲染；第三阶段实现静态输出、搜索索引、示例站点、发布说明和 mooncakes.io 发布；最终准备验收材料、展示脚本和技术文章。",
        ),
        (
            "最终交付",
            "公开 GitHub 与 Gitlink 仓库；以 MoonBit 为主要实现语言的可复用文档站工具包；README、开发日志、CI、测试、可运行示例；发布到 mooncakes.io 的生态包；面向评审展示的示例文档站和技术说明。",
        ),
    ]

    for heading, text in sections:
        story.append(p(heading, h))
        story.append(p(text, body))

    doc.build(story)
    print(OUT)


if __name__ == "__main__":
    main()
