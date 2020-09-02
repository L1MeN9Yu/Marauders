//
// Created by Mengyu Li on 2020/9/2.
//

import ArgumentParser
import Foundation
import Marauders

struct ResourceUsage: ParsableCommand {
    @Argument(help: "pid")
    var pid: pid_t

    func run() throws {
        let resourceInfo = ProcessMonitor.resourceUsage(pid: pid)
        let physFootprint = resourceInfo.physFootprint
        let diskioBytesRead = resourceInfo.diskioBytesRead
        let diskioBytesWritten = resourceInfo.diskioBytesWritten
    }
}
