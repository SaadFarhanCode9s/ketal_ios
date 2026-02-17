//
//  OIDCAuthenticationCoordinator.swift
//
//  Replaces custom WKWebView authentication flow
//  Uses ASWebAuthenticationSession (system-native OIDC flow)
//

import AuthenticationServices
import SwiftUI

// MARK: - Parameters

struct OIDCAuthenticationCoordinatorParameters {
    let oidcData: OIDCAuthorizationDataProxy
    let authenticationService: AuthenticationServiceProtocol
    let userIndicatorController: UserIndicatorControllerProtocol
    let presentationAnchor: UIWindow
}

// MARK: - Result

enum OIDCAuthenticationCoordinatorResult {
    case success(UserSessionProtocol)
    case cancel
}

// MARK: - Coordinator

@MainActor
final class OIDCAuthenticationCoordinator: NSObject, CoordinatorProtocol {

    private let parameters: OIDCAuthenticationCoordinatorParameters
    private var callbackClosure: ((OIDCAuthenticationCoordinatorResult) -> Void)?
    private var activeSession: ASWebAuthenticationSession?

    init(parameters: OIDCAuthenticationCoordinatorParameters) {
        self.parameters = parameters
    }

    // MARK: - Public

    func start() {
        print("[OIDC DEBUG] Coordinator starting...")
        NSLog("[OIDC DEBUG] Coordinator starting...")
        MXLog.info("[OIDC Authentication Coordinator] Starting...")
        startAuthentication()
    }

    func stop() {
        activeSession?.cancel()
        activeSession = nil
        callbackClosure = nil
    }

    func toPresentable() -> AnyView {
        // Nothing to present.
        // ASWebAuthenticationSession presents itself.
        AnyView(EmptyView())
    }

    func callback(_ callback: @escaping (OIDCAuthenticationCoordinatorResult) -> Void) {
        callbackClosure = callback
    }

    // MARK: - Authentication

    private func startAuthentication() {
        print("[OIDC DEBUG] startAuthentication called")
        NSLog("[OIDC DEBUG] startAuthentication called")
        MXLog.info("[OIDC Authentication Coordinator] Extracting redirect URL...")
        let components = URLComponents(url: parameters.oidcData.url, resolvingAgainstBaseURL: false)
        let redirectURLString = components?.queryItems?.first(where: { $0.name == "redirect_uri" })?.value ?? "ketal://oidc"
        
        guard let redirectURL = URL(string: redirectURLString) else {
            print("[OIDC DEBUG] Failed to extract redirect URL")
            MXLog.error("[OIDC Authentication Coordinator] Failed to extract redirect URL")
            fatalError("Invalid redirect URL extracted: \(redirectURLString)")
        }

        print("[OIDC DEBUG] Creating session with URL: \(parameters.oidcData.url)")
        MXLog.info("[OIDC Authentication Coordinator] Creating ASWebAuthenticationSession with URL: \(parameters.oidcData.url)")
        let session = ASWebAuthenticationSession(
            url: parameters.oidcData.url,
            callback: .oidcRedirectURL(redirectURL)
        ) { [weak self] callbackURL, error in
            print("[OIDC DEBUG] Completion handler hit. Callback: \(String(describing: callbackURL)), Error: \(String(describing: error))")
            guard let self else { return }
            MXLog.info("[OIDC Authentication Coordinator] Session finished. Callback URL: \(String(describing: callbackURL)), Error: \(String(describing: error))")
            Task { await self.handleAuthResult(callbackURL: callbackURL, error: error) }
        }

        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = false

        session.additionalHeaderFields = [
            "X-Element-User-Agent": UserAgentBuilder.makeASCIIUserAgent()
        ]

        activeSession = session
        let started = session.start()
        print("[OIDC DEBUG] session.start() returned \(started)")
        MXLog.info("[OIDC Authentication Coordinator] Session started: \(started)")
        
        if !started {
            MXLog.error("[OIDC Authentication Coordinator] Failed to start ASWebAuthenticationSession")
            callbackClosure?(.cancel)
        }
    }

    private func handleAuthResult(callbackURL: URL?, error: Error?) async {
        defer { activeSession = nil }

        // User cancelled
        if let error, error.isOIDCUserCancellation {
            await parameters.authenticationService.abortOIDCLogin(data: parameters.oidcData)
            callbackClosure?(.cancel)
            return
        }

        guard let callbackURL else {
            await parameters.authenticationService.abortOIDCLogin(data: parameters.oidcData)
            callbackClosure?(.cancel)
            return
        }

        startLoading()
        defer { stopLoading() }

        switch await parameters.authenticationService.loginWithOIDCCallback(callbackURL) {
        case .success(let userSession):
            callbackClosure?(.success(userSession))

        case .failure(.oidcError(.userCancellation)):
            callbackClosure?(.cancel)

        case .failure:
            callbackClosure?(.cancel)
        }
    }
}

// MARK: - Presentation Context

extension OIDCAuthenticationCoordinator: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        parameters.presentationAnchor
    }
}

// MARK: - Loading Indicator

private extension OIDCAuthenticationCoordinator {
    static let loadingIndicatorID = "OIDCAuthenticationCoordinator-Loading"

    func startLoading() {
        parameters.userIndicatorController.submitIndicator(
            UserIndicator(
                id: Self.loadingIndicatorID,
                type: .modal,
                title: L10n.commonLoading,
                persistent: true
            )
        )
    }

    func stopLoading() {
        parameters.userIndicatorController
            .retractIndicatorWithId(Self.loadingIndicatorID)
    }
}

