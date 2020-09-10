//
// Created by Mengyu Li on 2020/9/10.
//

import ArgumentParser
import Foundation
import Logging
import Marauders

struct Network: ParsableCommand {
    func run() throws {
        try NetworkMonitor.start(fileDescriptorPath: "/tmp/MaraudersCLI.Network", dispatchQueue: .global()) { info in
            logger.info("\(info)")
        }
        dispatchMain()
    }
}
