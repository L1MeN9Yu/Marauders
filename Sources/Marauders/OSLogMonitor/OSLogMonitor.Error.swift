//
// Created by Mengyu Li on 2020/8/21.
//

import Foundation

@available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
extension OSLogMonitor {
    public enum Error: Swift.Error {
        case frameworkOpenFailed(String)
        case symbolNotFound(String)
    }
}
