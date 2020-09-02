//
// Created by Mengyu Li on 2020/9/2.
//

import ArgumentParser
import Foundation
import Marauders

struct FileDescriptions: ParsableCommand {
    @Argument(help: "pid")
    var pid: pid_t

    func run() throws {
        let fds = ProcessMonitor.fileDescriptions(pid: pid)
        let outs = fds
            .map { "\($0.name)\t\($0.type)\t\($0.node)\t\($0.openFlags)" }
        outs.forEach { logger.info("\($0)") }
    }
}
