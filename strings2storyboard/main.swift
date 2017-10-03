//
//  main.swift
//  strings2storyboard
//
//  Created by Wayne Yeh on 2017/9/29.
//  Copyright © 2017年 Wayne Yeh. All rights reserved.
//

import Foundation

guard
    let SCRIPT_INPUT_FILE_0 = ProcessInfo.processInfo.environment["SCRIPT_INPUT_FILE_0"]
    else {
        exit(-1)
}
let localizableURL = URL(fileURLWithPath: SCRIPT_INPUT_FILE_0)
let localizableName = localizableURL.lastPathComponent

let localizablePath = localizableURL.deletingLastPathComponent().deletingLastPathComponent()
var localizableList = [String]()
if let list = try? FileManager.default.contentsOfDirectory(
    at: localizablePath,
    includingPropertiesForKeys: nil,
    options: []){
    localizableList = list.filter{
        $0.pathExtension == "lproj"
    }.map {
        $0.lastPathComponent
    }.filter {
        $0 != "Base.lproj" && $0 != "en.lproj"
    }
}

var i = 1
while ProcessInfo.processInfo.environment["SCRIPT_INPUT_FILE_\(i)"] != nil {
    guard
        let SCRIPT_INPUT_FILE = ProcessInfo.processInfo.environment["SCRIPT_INPUT_FILE_\(i)"]
        else {
            i += 1
            continue
    }
    let ui = URL(fileURLWithPath: SCRIPT_INPUT_FILE)
    let uiName = "\(ui.deletingPathExtension().lastPathComponent).strings"
    
    let folder = ui.deletingLastPathComponent().deletingLastPathComponent()
    
    guard
        let en = try? String(contentsOf: folder.appendingPathComponent("en.lproj", isDirectory: true).appendingPathComponent(uiName), encoding: .utf8)
        else {
            i += 1
            continue
    }
    for localizable in  localizableList {
        guard
            let strings = NSDictionary(contentsOf: localizablePath.appendingPathComponent(localizable, isDirectory: true).appendingPathComponent(localizableName)) as? [String: String]
            else {
                continue
        }
        
        var language = en
        for (key, value) in strings {
            language = language.replacingOccurrences(of: "\" = \"\(key)\";", with: "\" = \"\(value)\";")
        }
        
        try? language.write(to: folder.appendingPathComponent(localizable, isDirectory: true).appendingPathComponent(uiName), atomically: false, encoding: .utf8)
    }
    
    i += 1
}

