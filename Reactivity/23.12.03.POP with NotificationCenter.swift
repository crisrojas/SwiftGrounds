//
//  Notifications.swift
//  Effin
//
//  Created by Cristian Felipe Patiño Rojas on 03/12/2023.
//
import Foundation

/*
Simplify working with the `NotificationCenter` by leveraging
protocols extensions
*/
extension Notification.Name {
    static let login: Self  = .init(rawValue: "com.myapp.login ")
    static let logout: Self = .init(rawValue: "com.myapp.logout")
}

protocol RadioProtocol: Emitter, Observer {}
protocol Emitter {}
protocol Observer {}

extension Emitter {
    func post(_ notification: Notification.Name) {
        NotificationCenter.default.post(
            name: notification, 
            object: nil
        )
    }
}

extension Observer {
    func observe(_ notification: Notification.Name, _ selector: Selector) {
        NotificationCenter
        .default
        .addObserver(
            self,
            selector: selector,
            name: Notification.Name.logout,
            object: nil
        )
    }
}

final class ObserverItem: Observer {
    
    func startObserving() {observeAuthEvents()}
    
    func observeAuthEvents() {
        observe(.login , #selector(login ))
        observe(.logout, #selector(logout))
    }
    
    @objc func logout() {print("login out")}
    @objc func login () {print("login in ")}
}

final class EmitterItem: Emitter {}


    let observer = ObserverItem()
    observer.startObserving()
    
    let emitter  = EmitterItem()
    emitter.post(.logout)
    emitter.post(.login )
    
final class Radio: RadioProtocol {
    var loginSelector : Selector {#selector(login )}
    var logoutSelector: Selector {#selector(logout)}
    
    func observe(_ notification: Notification.Name) {
        switch notification {
        case .login : observe(notification, #selector(login))
        case .logout: observe(notification, #selector(logout))
        default: return
        }
    }
    
    @objc private func login () {print("login from radio" )}
    @objc private func logout() {print("logout from radio")}
}

let radio = Radio()
radio.observe(.login , radio.loginSelector)
radio.observe(.logout, radio.logoutSelector)
radio.observe(.login)
radio.observe(.logout)
radio.post(.login )
radio.post(.logout)

