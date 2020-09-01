//
// Created by Mengyu Li on 2020/3/25.
// Copyright (c) 2020 Mengyu Li. All rights reserved.
//

import Foundation

public struct ProcessInfo: Codable {
    public let pid: pid_t
    public let name: String
    public let path: String
}
