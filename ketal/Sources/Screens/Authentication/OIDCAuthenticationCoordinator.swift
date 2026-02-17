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
        let redirectURL = parameters.oidcData.redirectURL

        let session = ASWebAuthenticationSession(
            url: parameters.oidcData.url,
            callback: .oidcRedirectURL(redirectURL)
        ) { [weak self] callbackURL, error in
            guard let self else { return }
            Task { await self.handleAuthResult(callbackURL: callbackURL, error: error) }
        }

        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = false

        session.additionalHeaderFields = [
            "X-Element-User-Agent": UserAgentBuilder.makeASCIIUserAgent()
        ]

        activeSession = session
        session.start()
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

// MARK: - Callback Helper

private extension ASWebAuthenticationSession.Callback {
    static func oidcRedirectURL(_ url: URL) -> Self {
        if url.scheme == "https", let host = url.host() {
            return .https(host: host, path: url.path())
        } else if let scheme = url.scheme {
            return .customScheme(scheme)
        } else {
            fatalError("Invalid OIDC redirect URL: \(url)")
        }
    }
}

// MARK: - Error Helper

private extension Error {
    var isOIDCUserCancellation: Bool {
        let nsError = self as NSError

        if nsError.domain == ASWebAuthenticationSessionErrorDomain,
           nsError.code == ASWebAuthenticationSessionError.canceledLogin.rawValue,
           nsError.localizedFailureReason == nil {
            return true
        }

        return false
    }
}
