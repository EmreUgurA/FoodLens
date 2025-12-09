//
//  AuthViewModel.swift
//  FoodLens
//
//  Created by Emre Uğur on 9.12.2025.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import AuthenticationServices
import GoogleSignIn
import CryptoKit // Apple girişi için şifreleme kütüphanesi

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User? // İleride User modelini tanımlayacağız
    
    // Apple Girişi için gerekli değişken
    fileprivate var currentNonce: String?

    init() {
        self.userSession = Auth.auth().currentUser
    }
    
    // MARK: - Email/Password Login
    func login(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        self.userSession = result.user
    }
    
    func register(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        self.userSession = result.user
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        self.userSession = nil
    }
    
    // MARK: - Google Login Logic
    func signInWithGoogle() {
        // 1. Root ViewController'ı bul
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else { return }
        
        // 2. Google Giriş Ekranını Aç
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                print("Google Giriş Hatası: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else { return }
            
            let accessToken = user.accessToken.tokenString
            
            // 3. Firebase'e Bilgileri Gönder
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: accessToken)
            
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("Firebase Google Auth Hatası: \(error.localizedDescription)")
                    return
                }
                // Başarılı giriş
                self.userSession = result?.user
                print("Google ile giriş başarılı!")
            }
        }
    }
    
    // MARK: - Apple Login Logic (Biraz Karışıktır)
    func handleAppleLoginRequest(request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }
    
    func handleAppleLoginCompletion(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            guard let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential else { return }
            guard let nonce = currentNonce else {
                print("Invalid state: A login callback was received, but no login request was sent.")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )

            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("Apple Sign In Error: \(error.localizedDescription)")
                    return
                }

                self.userSession = authResult?.user
                print("Apple ile giriş başarılı!")
            }

            
        case .failure(let error):
            print("Authorisation failed: \(error.localizedDescription)")
        }
    }
    
    // --- Apple Yardımcı Fonksiyonları (Crypto) ---
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { charset[Int($0) % charset.count] }
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
}
