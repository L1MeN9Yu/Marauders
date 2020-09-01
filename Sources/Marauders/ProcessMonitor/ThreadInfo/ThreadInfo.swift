//
// Created by Mengyu Li on 2020/3/6.
// Copyright (c) 2020 Mengyu Li. All rights reserved.
//

import Foundation

public struct ThreadInfo: Codable {
    public let name: String
    public let threadName: String
    public let id: UInt64
    public let state: String
    public let dispatchQueueName: String

    init(name: String, threadName: String, id: UInt64, state: String, dispatchQueueName: String) {
        self.name = name
        self.threadName = threadName
        self.id = id
        self.state = state
        self.dispatchQueueName = dispatchQueueName
    }
}
