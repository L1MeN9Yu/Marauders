//
// Created by Mengyu Li on 2020/9/9.
//

import ArgumentParser
import Foundation
import Marauders

struct MachPorts: ParsableCommand {
    @Argument(help: "pid")
    var pid: pid_t

    func run() throws {
        let machPorts = ProcessMonitor.machPorts(pid: pid)
        logger.info("\(machPorts.reduce("") { $0 + "\n" + "\($1)" })\n")
    }
}
