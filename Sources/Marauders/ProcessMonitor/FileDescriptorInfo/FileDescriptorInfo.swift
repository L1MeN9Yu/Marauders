//
// Created by Mengyu Li on 2020/3/4.
// Copyright (c) 2020 Mengyu Li. All rights reserved.
//

import Foundation

public struct FileDescriptorInfo: Codable {
    public let name: String
    public let type: String
    public let openFlags: UInt32
    public let node: UInt64

    init(name: String, type: String, openFlags: UInt32, node: UInt64) {
        self.name = name
        self.type = type
        self.openFlags = openFlags
        self.node = node
    }
}
