//
//  SSLogManager.swift
//  SmartCurrency
//
//  Created by zhtg on 2021/8/17.
//

import Foundation
import SSNetwork

public func log(_ log: String) {
    SSLogManager.shared.log(log)
}

public func currDateDesc() -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(identifier:"Asia/Hong_Kong")!
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let str = formatter.string(from: date)
    return str
}

open class SSLogManager: NSObject {
    public static let shared = SSLogManager()
    
    var queue: DispatchQueue = DispatchQueue(label: "com.zzz.SSCommon(s)")
    var rootPath = "\(NSHomeDirectory())/Log"
    var currentFileName: String = ""
    
    public override init() {
        super.init()
        let fm = FileManager.default
        if fm.fileExists(atPath: rootPath) == false {
            try? fm.createDirectory(atPath: rootPath, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func currentFilePath() -> String {
        if currentFileName.count == 0 {
            currentFileName = "\(currDateDesc()).txt"
        }
        let path = "\(rootPath)/\(currentFileName)"
        do {
            if FileManager.default.fileExists(atPath: path) {
                let att = try FileManager.default.attributesOfItem(atPath: path)
                let size = att[FileAttributeKey.size] as! Int
                if size > 1024 * 1024 { // 大于1m就换文件
                    currentFileName = ""
                    return currentFilePath()
                }
            }
        } catch {
            
        }
        return path
    }
    
    open func log(_ message: String) {
        queue.async {
            let path = self.currentFilePath()
            var newText: String
            let current = "\(currDateDesc()):\(message)"
            print("\(current)")
            if let text = try? String(contentsOfFile: path) {
                newText = "\(text)\n\(current)"
            } else {
                newText = message
            }
            try? newText.write(toFile: path, atomically: true, encoding: .utf8)
        }
    }
}

var didSendPushMessage = [String]()

public func sendPushNotication(message: String) {
    if didSendPushMessage.contains(message) {
        return
    }
    didSendPushMessage.append(message)
    log(message)
    let dic: [String: Any] = [
        "text": [
            "content": "通知->\(currDateDesc())：\(message)"
        ],
        "msgtype": "text",
        "at": [
            "atMobiles": [ "18566699715" ],
            "isAtAll": false
        ]
    ]
    let _ = SSNetworkHelper.sendRequest(urlStr: "https://oapi.dingtalk.com/robot/send?access_token=002f7efb8f478ebdf5ac5102f153d3a651ace52c89b924c93fbb3d62abfc41e6", params: dic, header: ["Content-Type": "application/json"], method: .POST, timeOut: 10) { response in
        
    }
}

public func sendPushLog(_ log: String) {
    let dic: [String: Any] = [
        "text": [
            "content": "Log->\(Date().timeIntervalSince1970.dateDesc!):\(log)"
        ],
        "msgtype": "text"
    ]
    let _ = SSNetworkHelper.sendRequest(urlStr: "https://oapi.dingtalk.com/robot/send?access_token=d4b8cbeb211614f13b32f20e5b7bcd58849b3c75a1b5ef6cddcf77202cc8b876", params: dic, header: ["Content-Type": "application/json"], method: .POST, timeOut: 10) { response in

    }
}
