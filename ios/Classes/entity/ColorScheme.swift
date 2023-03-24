//
//  FlutterColor.swift
//  monetization_kit
//
//  Created by LondonX using ChatGPT on 2023/3/22.
//

import UIKit

enum Brightness {
    case light, dark
}

struct FlutterColor {
    let a: Int
    let r: Int
    let g: Int
    let b: Int
    
    init(a: Int, r: Int, g: Int, b: Int) {
        self.a = a
        self.r = r
        self.g = g
        self.b = b
    }
    
    init(from v: Int) {
        self.init(from: UInt32(v))
    }
    
    init(from v: UInt32) {
        let a = Int(v >> 24 & 0xFF)
        let r = Int(v >> 16 & 0xFF)
        let g = Int(v >> 8 & 0xFF)
        let b = Int(v >> 0 & 0xFF)
        self.init(a: a, r: r, g: g, b: b)
    }
    
    var v: UIColor {
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(a)/255.0)
    }
    
    func copy(a: Int? = nil, r: Int? = nil, g: Int? = nil, b: Int? = nil) -> FlutterColor {
        return FlutterColor(a: a ?? self.a, r: r ?? self.r, g: g ?? self.g, b: b ?? self.b)
    }
}

struct ColorScheme {
    let brightness: Brightness
    let primary: FlutterColor
    let onPrimary: FlutterColor
    let secondary: FlutterColor
    let onSecondary: FlutterColor
    let error: FlutterColor
    let onError: FlutterColor
    let background: FlutterColor
    let onBackground: FlutterColor
    let surface: FlutterColor
    let onSurface: FlutterColor
    
    static func fromRaw(raw: [String:Any]) -> ColorScheme {
        let brightness = (raw["brightness"] as? String == "dark") ? Brightness.dark : Brightness.light
        let primary = FlutterColor(from: raw["primary"] as! Int)
        let onPrimary = FlutterColor(from: raw["onPrimary"] as! Int)
        let secondary = FlutterColor(from: raw["secondary"] as! Int)
        let onSecondary = FlutterColor(from: raw["onSecondary"] as! Int)
        let error = FlutterColor(from: raw["error"] as! Int)
        let onError = FlutterColor(from: raw["onError"] as! Int)
        let background = FlutterColor(from: raw["background"] as! Int)
        let onBackground = FlutterColor(from: raw["onBackground"] as! Int)
        let surface = FlutterColor(from: raw["surface"] as! Int)
        let onSurface = FlutterColor(from: raw["onSurface"] as! Int)
        
        return ColorScheme(
            brightness: brightness,
            primary: primary,
            onPrimary: onPrimary,
            secondary: secondary,
            onSecondary: onSecondary,
            error: error,
            onError: onError,
            background: background,
            onBackground: onBackground,
            surface: surface,
            onSurface: onSurface
        )
    }
}
