//
// Created by Mengyu Li on 2020/9/9.
//

import ArgumentParser
import Foundation
import Marauders

struct Regions: ParsableCommand {
    @Argument(help: "pid")
    var pid: pid_t

    func run() throws {
        let regions = ProcessMonitor.regions(pid: pid)
        logger.info("\(regions.reduce("") { $0 + "\n" + "\($1)" })\n")
    }
}
