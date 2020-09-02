//
// Created by Mengyu Li on 2020/9/2.
//

import Foundation
import Logging
import Senna

let logger = Logger(label: "MaraudersCLI") { _ in
    Handler(sink: Standard.out, formatter: Formatter.default, logLevel: .trace)
}
