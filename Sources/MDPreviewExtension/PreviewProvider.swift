import Cocoa
import JavaScriptCore
import QuickLookUI
import UniformTypeIdentifiers

@objc(PreviewProvider)
class PreviewProvider: QLPreviewProvider, QLPreviewingController {
  func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
    let markdown = try String(contentsOf: request.fileURL, encoding: .utf8)
    let bundle = Bundle(for: PreviewProvider.self)
    func resource(_ name: String, _ ext: String) throws -> String {
      try String(contentsOf: bundle.url(forResource: name, withExtension: ext)!, encoding: .utf8)
    }

    // Quick Look does not run JS in HTML replies, so render + highlight here
    let js = JSContext()!
    js.evaluateScript(try resource("marked.min", "js"))
    js.evaluateScript(try resource("highlight.min", "js"))
    js.setObject(markdown, forKeyedSubscript: "src" as NSString)
    let body = js.evaluateScript("""
      marked.use({ renderer: { code({ text, lang }) {
        const language = lang && hljs.getLanguage(lang) ? lang : null
        const html = language ? hljs.highlight(text, { language }).value : hljs.highlightAuto(text).value
        return '<pre><code class="hljs">' + html + '</code></pre>'
      } } })
      marked.parse(src, { gfm: true })
      """)?.toString() ?? ""

    let html = """
    <!doctype html><html><head><meta charset="utf-8"><style>
    \(try resource("hl-light", "css"))
    @media (prefers-color-scheme: dark) { \(try resource("hl-dark", "css")) }
    :root { color-scheme: light dark; }
    body { font: 15px/1.65 -apple-system, sans-serif; max-width: 900px; margin: 0 auto; padding: 32px 40px; }
    pre, code { font-family: ui-monospace, Menlo, monospace; font-size: 13px; }
    pre { border-radius: 8px; overflow-x: auto; }
    pre code.hljs { padding: 14px 16px; border-radius: 8px; }
    :not(pre) > code { background: rgba(127,127,127,.18); padding: 2px 5px; border-radius: 4px; }
    blockquote { margin: 0; padding-left: 14px; border-left: 3px solid rgba(127,127,127,.4); opacity: .85; }
    table { border-collapse: collapse; display: block; overflow-x: auto; }
    th, td { border: 1px solid rgba(127,127,127,.35); padding: 6px 12px; text-align: left; vertical-align: top; }
    tr:nth-child(even) td { background: rgba(127,127,127,.06); }
    img { max-width: 100%; }
    h1, h2 { border-bottom: 1px solid rgba(127,127,127,.25); padding-bottom: 6px; }
    a { color: #2f81f7; }
    hr { border: 0; border-top: 1px solid rgba(127,127,127,.3); }
    </style></head><body>\(body)</body></html>
    """
    return QLPreviewReply(dataOfContentType: .html, contentSize: CGSize(width: 1200, height: 1600)) { _ in
      Data(html.utf8)
    }
  }
}
