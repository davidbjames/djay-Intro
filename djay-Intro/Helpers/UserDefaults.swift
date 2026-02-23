//
//  UserDefaults.swift
//  djay-Intro
//
//  Created by David James on 16/02/2026.
//

import UIKit

// this was used for storing the onboarding state

/// A Codable type that can be stored in UserDefaults
protocol CodableDefaultsStorable: Codable, Equatable {
    static var storageKey: String { get }
}

extension CodableDefaultsStorable {
    
    static func load() -> Self? {
        UserDefaults.standard.codable(Self.self, forKey: Self.storageKey)
    }
    
    func save() {
        UserDefaults.standard.setCodable(self, forKey: Self.storageKey)
    }
    
    static func clear() {
        UserDefaults.standard.removeObject(forKey: Self.storageKey)
    }
}

private extension UserDefaults {
    
    /// Given a Codable type, decode and retreive it from user defaults.
    func codable<T:Codable>(_:T.Type, forKey key:String, debug:Bool = false) -> T? {
        guard let data = object(forKey:key) as? Data else {
            return nil
        }
        do {
            return try JSONDecoder().decode(T.self, from:data)
        } catch {
            if debug {
                print(error)
            }
            return nil
        }
    }
    /// Given a Codable type, encode and store it in user defaults.
    func setCodable<T:Codable>(_ object:T, forKey key:String, debug:Bool = false) {
        do {
            let data = try JSONEncoder().encode(object)
            set(data, forKey:key)
        } catch {
            if debug {
                print(error)
            }
        }
    }
}

