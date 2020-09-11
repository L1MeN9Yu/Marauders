//
// Created by Mengyu Li on 2020/9/2.
//

import ArgumentParser
import Foundation

struct CLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "MaraudersCLI",
        abstract: "The Demo CLI for Marauders",
        subcommands: subCommands
    )

    static let subCommands: [ParsableCommand.Type] = {
        var commands: [ParsableCommand.Type] = [
            ResourceUsage.self,
            Threads.self,
            FileDescriptions.self,
            MachPorts.self,
            Regions.self,
            Network.self,
            KernelExtensions.self,
        ]
        if #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            commands.append(OSLog.self)
        }
        return commands
    }()
}
