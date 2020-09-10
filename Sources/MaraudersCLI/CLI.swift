//
// Created by Mengyu Li on 2020/9/2.
//

import ArgumentParser
import Foundation

struct CLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "MaraudersCLI",
        abstract: "The Demo CLI for Marauders",
        subcommands: [
            ResourceUsage.self,
            Threads.self,
            FileDescriptions.self,
            MachPorts.self,
            Regions.self,
        ]
    )
}
