//
// Created by Mengyu Li on 2020/3/4.
// Copyright (c) 2020 Mengyu Li. All rights reserved.
//

import Foundation

public struct FileDescriptorInfo: Codable {
    public let fd: Int32
    public let name: String
    public let type: String
    public let openFlags: UInt32
    public let node: UInt64

    init(fd: Int32, name: String, type: String, openFlags: UInt32, node: UInt64) {
        self.fd = fd
        self.name = name
        self.type = type
        self.openFlags = openFlags
        self.node = node
    }
}
