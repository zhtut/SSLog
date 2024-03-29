//
//  SSLogManager.swift
//  SmartCurrency
//
//  Created by zhtg on 2021/8/17.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public func log(_ log: String) {
    SSLogManager.shared.log(log)
}

public func logErr(_ log: String) {
    let manager = SSLogManager.error
    manager.rootName = "Error"
    manager.log(log)
}

open class SSLogManager: NSObject {
    public static let shared = SSLogManager()
    public static let error = SSLogManager()
    
    var queue: DispatchQueue = DispatchQueue(label: "com.zzz.SSCommon(s)")
    var rootName = "Log"
    var rootPath: String {
        "\(NSHomeDirectory())/\(rootName)"
    }
    var currentFileName: String = ""
    
    public override init() {
        super.init()
    }
    
    open class var currDateDesc: String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier:"Asia/Hong_Kong")!
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let str = formatter.string(from: date)
        return str
    }
    
    func currentFilePath() -> String {
        let fm = FileManager.default
        if fm.fileExists(atPath: rootPath) == false {
            try? fm.createDirectory(atPath: rootPath, withIntermediateDirectories: true, attributes: nil)
            print("初始化日志根目录：\(rootPath)")
        }
        if currentFileName.count == 0 {
            currentFileName = "\(SSLogManager.currDateDesc).txt"
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
            let current = "\(SSLogManager.currDateDesc):\(message)"
            print("\(current)")
            if let text = try? String(contentsOfFile: path) {
                newText = "\(text)\n\(current)"
            } else {
                newText = current
            }
            try? newText.write(toFile: path, atomically: true, encoding: .utf8)
        }
    }
}

public func sendPushNotication(_ noti: String, atSelf: Bool = false) {
    log(noti)
    var dic: [String: Any] = [
        "text": [
            "content": "通知->\(SSLogManager.currDateDesc)：\(noti)"
        ],
        "msgtype": "text",
    ]
    if atSelf {
        dic["at"] = [
            "isAtAll": true
        ]
    }
    let url = URL(string: "https://oapi.dingtalk.com/robot/send?access_token=002f7efb8f478ebdf5ac5102f153d3a651ace52c89b924c93fbb3d62abfc41e6")
    if let url = url {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        if let data = try? JSONSerialization.data(withJSONObject: dic) {
            request.httpBody = data
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//
//            }
        }
        task.resume()
    }
}
