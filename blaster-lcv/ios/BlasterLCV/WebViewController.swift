import UIKit
import WebKit
import UniformTypeIdentifiers

/// Contenedor de blaster.lcv: muestra la app web incluida (funciona sin internet) y agrega
/// guardar archivos (hoja para compartir: Guardar en Archivos, AirDrop, correo…) e imprimir.
final class WebViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {
    private var web: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let config = WKWebViewConfiguration()
        // Origen propio «app://local» para los archivos de la app: el almacenamiento local funciona como en un sitio web.
        config.setURLSchemeHandler(BundleSchemeHandler(), forURLScheme: "app")
        config.userContentController.add(self, name: "blaster")
        config.websiteDataStore = .default()

        web = WKWebView(frame: .zero, configuration: config)
        web.navigationDelegate = self
        web.uiDelegate = self
        web.scrollView.contentInsetAdjustmentBehavior = .never
        web.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(web)
        NSLayoutConstraint.activate([
            web.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            web.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            web.topAnchor.constraint(equalTo: view.topAnchor),
            web.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        web.load(URLRequest(url: URL(string: "app://local/index.html")!))
    }

    // MARK: - Mensajes de la app web (window.webkit.messageHandlers.blaster)

    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any], let action = body["action"] as? String else { return }
        let name = (body["name"] as? String) ?? "blaster.lcv"
        let data = (body["data"] as? String).flatMap { Data(base64Encoded: $0) }
        switch action {
        case "save":
            guard let data = data else { return }
            share(data: data, fileName: name)
        case "print":
            guard let data = data else { return }
            let info = UIPrintInfo(dictionary: nil)
            info.jobName = name
            info.outputType = .general
            let pc = UIPrintInteractionController.shared
            pc.printInfo = info
            pc.printingItem = data
            pc.present(animated: true)
        default:
            break
        }
    }

    /// Guarda el archivo en una carpeta temporal y abre la hoja para compartir (incluye «Guardar en Archivos» e «Imprimir»).
    private func share(data: Data, fileName: String) {
        let safe = fileName.replacingOccurrences(of: "/", with: "_")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(safe)
        do { try data.write(to: url, options: .atomic) } catch { return }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let pop = vc.popoverPresentationController { // iPad
            pop.sourceView = view
            pop.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
            pop.permittedArrowDirections = []
        }
        present(vc, animated: true)
    }

    // Enlaces externos: se abren en Safari.
    func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = action.request.url, url.scheme == "http" || url.scheme == "https", action.targetFrame?.isMainFrame ?? true {
            if action.navigationType == .linkActivated { UIApplication.shared.open(url); decisionHandler(.cancel); return }
        }
        decisionHandler(.allow)
    }
}

/// Sirve los archivos de la carpeta «www» incluida en la app bajo app://local/…
final class BundleSchemeHandler: NSObject, WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start task: WKURLSchemeTask) {
        guard let url = task.request.url else { return }
        var path = url.path.isEmpty || url.path == "/" ? "/index.html" : url.path
        if path.hasPrefix("/") { path.removeFirst() }
        guard let base = Bundle.main.resourceURL?.appendingPathComponent("www"),
              let data = try? Data(contentsOf: base.appendingPathComponent(path)) else {
            task.didFailWithError(NSError(domain: NSURLErrorDomain, code: NSURLErrorFileDoesNotExist))
            return
        }
        let ext = (path as NSString).pathExtension.lowercased()
        let mime: String
        switch ext {
        case "html": mime = "text/html"
        case "js": mime = "application/javascript"
        case "svg": mime = "image/svg+xml"
        case "json", "webmanifest": mime = "application/json"
        case "css": mime = "text/css"
        case "png": mime = "image/png"
        default: mime = UTType(filenameExtension: ext)?.preferredMIMEType ?? "application/octet-stream"
        }
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1",
                                       headerFields: ["Content-Type": mime, "Content-Length": "\(data.count)"])!
        task.didReceive(response)
        task.didReceive(data)
        task.didFinish()
    }

    func webView(_ webView: WKWebView, stop task: WKURLSchemeTask) {}
}
