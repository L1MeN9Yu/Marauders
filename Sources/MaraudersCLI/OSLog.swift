//
// Created by Mengyu Li on 2020/9/10.
//

import ArgumentParser
import Foundation
import Logging
import Marauders
import os.log

@available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
struct OSLog: ParsableCommand {
    @Option(help: "process name")
    var processName: String?

    func run() throws {
        try OSLogMonitor.start { message in
            if message.processName == self.processName {
                return logger.log(level: message.type.level, "\(message.content)")
            }
            logger.log(level: message.type.level, "\(message.content)")
        }
        dispatchMain()
    }
}

@available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
extension OSLogType {
    var level: Logging.Logger.Level {
        switch self {
        case .default: return .trace
        case .info: return .info
        case .debug: return .debug
        case .error: return .error
        case .fault: return .critical
        default: return .notice
        }
    }
}
