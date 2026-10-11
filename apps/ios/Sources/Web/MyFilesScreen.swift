import OpenClawChatUI
import OpenClawKit
import OpenClawProtocol
import SwiftUI
import WebKit

/// My Files — embedded browser for Cat's P42 deliverables folder
/// (W:\P42-files), served by the recall/files endpoint.
///
/// The endpoint URL (including its access token) is injected at build time
/// via `Resources/P42Config.plist` — never committed to the repository.
struct MyFilesScreen: View {
    let headerSidebarAction: OpenClawSidebarHeaderAction?

    private var filesURL: URL? {
        guard let configURL = Bundle.main.url(forResource: "P42Config", withExtension: "plist"),
              let config = NSDictionary(contentsOf: configURL) as? [String: Any],
              let raw = config["filesURL"] as? String,
              !raw.isEmpty
        else {
            return nil
        }
        return URL(string: raw)
    }

    var body: some View {
        ZStack {
            OpenClawProBackground()
            VStack(alignment: .leading, spacing: 0) {
                if let headerSidebarAction {
                    OpenClawAdaptiveHeaderRow(
                        title: "My Files",
                        subtitle: .verbatim("P42 Files"),
                        titleFont: OpenClawType.title3SemiBold,
                        subtitleFont: OpenClawType.subheadMedium)
                    {
                        OpenClawSidebarControlButton(action: headerSidebarAction)
                    } accessory: {
                        EmptyView()
                    }
                    .padding(.horizontal, OpenClawProMetric.pagePadding)
                }
                if let filesURL = self.filesURL {
                    MyFilesWebView(url: filesURL)
                } else {
                    Text("My Files is not configured in this build.")
                        .font(OpenClawType.body)
                        .padding(OpenClawProMetric.pagePadding)
                }
            }
        }
        .navigationTitle("My Files")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct MyFilesWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context _: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: self.url))
        return webView
    }

    func updateUIView(_: WKWebView, context _: Context) {}
}
