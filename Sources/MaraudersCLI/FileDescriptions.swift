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
        logger.info("\(fds.reduce("") { $0 + "\n" + "\($1)" })\n")
    }
}
