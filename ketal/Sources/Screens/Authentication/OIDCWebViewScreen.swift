
//
// Copyright 2026 Ketal Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
//

import SwiftUI
import WebKit

struct OIDCWebViewScreen: View {
    @StateObject private var viewModel: OIDCWebViewViewModel
    @State private var delayedError: String?
    let onSuccess: (URL) -> Void
    let onCancel: () -> Void

    init(authorizationURL: URL,
         redirectURI: String,
         onSuccess: @escaping (URL) -> Void,
         onCancel: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: OIDCWebViewViewModel(authorizationURL: authorizationURL,
                                                                    redirectURI: redirectURI))
        self.onSuccess = onSuccess
        self.onCancel = onCancel
    }

    var body: some View {
        ZStack {
            WebView(viewModel: viewModel)
                .opacity(viewModel.isLoading ? 0 : 1)
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            }
            if let error = delayedError {
                errorView(error)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary.opacity(0.6))
                        .padding(8)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
        }
        .onChange(of: viewModel.error) { _, newError in
            if let error = newError {
                Task {
                    try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                    delayedError = error
                }
            } else {
                delayedError = nil
            }
        }
        .onChange(of: viewModel.callbackURL) { _, newValue in
            if let callbackURL = newValue {
                onSuccess(callbackURL)
            }
        }
        .onAppear {
            viewModel.loadAuthorizationPage()
        }
    }

    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.compound.textCriticalPrimary)

            Text("Authentication Error")
                .font(.compound.headingMDBold)
                .foregroundColor(.compound.textPrimary)

            Text(error)
                .font(.compound.bodyMD)
                .foregroundColor(.compound.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Try Again") {
                viewModel.retry()
            }
            .buttonStyle(.compound(.primary))
            .padding(.top, 8)
        }
        .padding()
        .background(.regularMaterial) // Add material background for error view readability over webview
        .cornerRadius(12)
        .padding()
    }
}

// MARK: - WebView

private struct WebView: UIViewRepresentable {
    @ObservedObject var viewModel: OIDCWebViewViewModel

    func makeUIView(context: Context) -> WKWebView {
        viewModel.webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed
    }
}

#Preview {
    OIDCWebViewScreen(authorizationURL: URL(string: "https://www.google.com")!,
                      redirectURI: "http://localhost",
                      onSuccess: { _ in },
                      onCancel: { })
}
	
