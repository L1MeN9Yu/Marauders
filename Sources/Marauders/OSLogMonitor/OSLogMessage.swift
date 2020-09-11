//
// Created by Mengyu Li on 2020/3/20.
// Copyright (c) 2020 Mengyu Li. All rights reserved.
//

import Foundation
import os.log

public struct OSLogMessage {
    public let pid: pid_t
    public let processName: String
    public let category: String
    public let subsystem: String
    public let type: OSLogType
    public let content: String

    public init(pid: pid_t, processName: String, category: String, subsystem: String, type: OSLogType, message: String) {
        self.pid = pid
        self.processName = processName
        self.category = category
        self.subsystem = subsystem
        self.type = type
        content = message
    }
}
