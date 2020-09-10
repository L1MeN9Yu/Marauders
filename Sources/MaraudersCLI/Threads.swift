//
// Created by Mengyu Li on 2020/9/9.
//

import ArgumentParser
import Foundation
import Marauders

struct Threads: ParsableCommand {
    @Argument(help: "pid")
    var pid: pid_t

    func run() throws {
        let threadInfos = ProcessMonitor.threadInfos(pid: pid)
        logger.info("\(threadInfos.reduce("") { $0 + "\n" + "\($1)" })\n")
    }
}
