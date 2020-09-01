//
// Created by Mengyu Li on 2020/8/21.
//

import Foundation

extension NetworkMonitor {
    public enum Error: Swift.Error {
        case frameworkOpenFailed(String)
        case symbolNotFound(String)
        case functionFailed(String)
        case fdFailed(String)
    }
}
