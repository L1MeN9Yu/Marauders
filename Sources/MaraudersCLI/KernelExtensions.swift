//
// Created by Mengyu Li on 2020/9/11.
//

import ArgumentParser
import Foundation
import Marauders

struct KernelExtensions: ParsableCommand {
    @Flag(help: "Show All values")
    var all: Bool = false

    @Argument(help: "keys")
    var keys: [String] = SystemKernelExtensions.infoKeys

    func run() throws {
        let infoKeys = all ? nil : keys
        let kexts = try SystemKernelExtensions.retrieve(infoKeys: infoKeys)
        logger.info("\(kexts ?? [:])")
    }
}
