//
//  main.swift
//  strings2storyboard
//
//  Created by Wayne Yeh on 2017/9/29.
//  Copyright © 2017年 Wayne Yeh. All rights reserved.
//

import Foundation

guard
    let SCRIPT_INPUT_FILE_0 = ProcessInfo.processInfo.environment["SCRIPT_INPUT_FILE_0"],
    let SCRIPT_INPUT_FILE_1 = ProcessInfo.processInfo.environment["SCRIPT_INPUT_FILE_1"]
    else {
        exit(-1)
}
let localizableURL = URL(fileURLWithPath: SCRIPT_INPUT_FILE_0)
let localizableName = "Localizable.strings"

func subFolder(dir: URL) -> [URL] {
    let list = try? FileManager.default.contentsOfDirectory(
        at: dir,
        includingPropertiesForKeys: nil,
        options: [])
    
    return list ?? []
}

var localizableList = subFolder(dir:localizableURL).filter{
    $0.pathExtension == "lproj"
    }.map {
        $0.lastPathComponent
    }.filter {
        $0 != "Base.lproj"
    }

func shell(_ args: [String]) -> (output: String, error: String, exitCode: Int32) {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    
    let outpipe = Pipe()
    task.standardOutput = outpipe
    let errpipe = Pipe()
    task.standardError = errpipe
    
    task.launch()
    
    let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: outdata, encoding:  String.Encoding.utf8)
    
    let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
    let error_output = String(data: errdata, encoding: String.Encoding.utf8)
    
    task.waitUntilExit()
    
    let status = task.terminationStatus
    
    return (output!, error_output!, status)
}

func processDir(dir: URL) {
    var UIs = [URL]()
    
    for subfolder in subFolder(dir: dir) {
        if subfolder.lastPathComponent == "Base.lproj" {
            let list = subFolder(dir:subfolder)
            UIs = list.filter{
                $0.pathExtension == "storyboard" || $0.pathExtension == "xib"
            }
        } else if localizableList.contains(subfolder.lastPathComponent) {
        } else {
            processDir(dir: subfolder)
        }
    }
    
    for ui in UIs {
		let txt = ui.deletingPathExtension().appendingPathExtension("strings")
        let (_,_,result) = shell(["ibtool","--generate-strings-file",txt.path,ui.path])
        
        if result == 0,
            let labels = try? String(contentsOf: txt, encoding: .unicode) {
            let uiName = "\(ui.deletingPathExtension().lastPathComponent).strings"
            for localizable in  localizableList {
                guard
                    let strings = NSDictionary(contentsOf: localizableURL.appendingPathComponent(localizable, isDirectory: true).appendingPathComponent(localizableName)) as? [String: String]
                    else {
                        continue
                }
                var language = labels
                for (key, value) in strings {
                    language = language.replacingOccurrences(of: "\" = \"\(key)\";", with: "\" = \"\(value)\";")
                }
                
                try? language.write(to: dir.appendingPathComponent(localizable, isDirectory: true).appendingPathComponent(uiName), atomically: false, encoding: .unicode)
            }
        }
        
        _ = try? FileManager.default.removeItem(at: txt)
    }
}

processDir(dir: URL(fileURLWithPath: SCRIPT_INPUT_FILE_1))
