//
// Created by Mengyu Li on 2020/3/19.
// Copyright (c) 2020 Mengyu Li. All rights reserved.
//

import Foundation

public struct NetFlowInfo {
    public let pid: pid_t
    public let processName: String
    public let provider: String
    public let tcpState: String
    public let rxBytes: UInt64
    public let txBytes: UInt64
    public let localAddress: String
    public let remoteAddress: String

    public init(pid: pid_t, processName: String, provider: String, tcpState: String, rxBytes: UInt64, txBytes: UInt64,
                localAddress: String, remoteAddress: String)
    {
        self.pid = pid
        self.processName = processName
        self.provider = provider
        self.tcpState = tcpState
        self.rxBytes = rxBytes
        self.txBytes = txBytes
        self.localAddress = localAddress
        self.remoteAddress = remoteAddress
    }
}
