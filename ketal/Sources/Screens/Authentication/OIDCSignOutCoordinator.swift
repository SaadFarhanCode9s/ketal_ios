//
// Copyright 2023-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import AuthenticationServices

@MainActor
class OIDCSignOutCoordinator: NSObject {
    private let homeserver: String
    private let presentationAnchor: UIWindow
    private var activeSession: ASWebAuthenticationSession?

    init(homeserver: String, presentationAnchor: UIWindow) {
        self.homeserver = homeserver
        self.presentationAnchor = presentationAnchor
        super.init()
    }

    /// Invokes the ASWebAuthenticationSession for the Keycloak logout endpoint.
    /// - Returns: A boolean indicating success (true) or failure/cancellation (false).
    func start() async -> Bool {
        let domain = extractDomain(from: homeserver)
        
        guard let issuer = await fetchIssuer(domain: domain) else {
            MXLog.error("[OIDCSignOutCoordinator] Failed to discover OIDC issuer from .well-known.")
            return false
        }
        
        guard let logoutURL = await fetchEndSessionEndpoint(issuer: issuer) else {
            MXLog.error("[OIDCSignOutCoordinator] Failed to discover end_session_endpoint from OIDC configuration.")
            return false
        }
        
        MXLog.info("[OIDCSignOutCoordinator] Found end_session_endpoint: \\(logoutURL.absoluteString)")

        return await withCheckedContinuation { continuation in
            let session = ASWebAuthenticationSession(url: logoutURL, callback: .customScheme("app.ketal.ios")) { _, error in
                if let error = error {
                    if let asError = error as? ASWebAuthenticationSessionError, asError.code == .canceledLogin {
                        MXLog.info("[OIDCSignOutCoordinator] User cancelled the logout session.")
                        continuation.resume(returning: false)
                        return
                    }
                    MXLog.error("[OIDCSignOutCoordinator] Logout session failed with error: \\(error)")
                    continuation.resume(returning: false)
                    return
                }

                MXLog.info("[OIDCSignOutCoordinator] Logout session completed successfully.")
                continuation.resume(returning: true)
            }

            // Critical: false to use the shared persistent cookie jar.
            session.prefersEphemeralWebBrowserSession = false
            session.presentationContextProvider = self
            session.additionalHeaderFields = [
                "X-Element-User-Agent": UserAgentBuilder.makeASCIIUserAgent()
            ]

            activeSession = session
            if !session.start() {
                MXLog.error("[OIDCSignOutCoordinator] Failed to start ASWebAuthenticationSession")
                activeSession = nil
                continuation.resume(returning: false)
            }
        }
    }
    
    // MARK: - Discovery
    
    private func extractDomain(from address: String) -> String {
        var domain = address
        if let url = URL(string: address), let host = url.host {
            return host
        }
        if domain.contains("://") {
            domain = String(domain.split(separator: "/")[2])
        }
        if let colonIndex = domain.firstIndex(of: ":") {
            domain = String(domain[..<colonIndex])
        }
        if let slashIndex = domain.firstIndex(of: "/") {
            domain = String(domain[..<slashIndex])
        }
        return domain
    }

    private func fetchIssuer(domain: String) async -> String? {
        let urlString = "https://\\(domain)/.well-known/matrix/client"
        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let authKey = json["m.authentication"] as? [String: Any],
                   let issuer = authKey["issuer"] as? String {
                    return issuer
                }
                if let authKey = json["org.matrix.msc2965.authentication"] as? [String: Any],
                   let issuer = authKey["issuer"] as? String {
                    return issuer
                }
            }
        } catch {
            MXLog.error("[OIDCSignOutCoordinator] Discovery failed for \\(domain): \\(error)")
        }
        return nil
    }

    private func fetchEndSessionEndpoint(issuer: String) async -> URL? {
        let cleanIssuer = issuer.hasSuffix("/") ? String(issuer.dropLast()) : issuer
        let configURLString = "\\(cleanIssuer)/.well-known/openid-configuration"
        guard let url = URL(string: configURLString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let endSessionEndpoint = json["end_session_endpoint"] as? String {
                return URL(string: endSessionEndpoint)
            }
        } catch {
            MXLog.error("[OIDCSignOutCoordinator] OIDC config discovery failed: \\(error)")
        }
        return nil
    }
}

// MARK: ASWebAuthenticationPresentationContextProviding

extension OIDCSignOutCoordinator: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        presentationAnchor
    }
}
