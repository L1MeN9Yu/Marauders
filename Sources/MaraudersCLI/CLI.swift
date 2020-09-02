//
// Created by Mengyu Li on 2020/9/2.
//

import ArgumentParser
import Foundation

struct CLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "The Demo CLI for Marauders",
        subcommands: [ResourceUsage.self, FileDescriptions.self]
    )
}
