//
// Created by Mengyu Li on 2020/8/21.
//

import Foundation

extension SystemKernelExtensions {
    public enum Error: Swift.Error {
        case frameworkOpenFailed(String)
        case symbolNotFound(String)
    }
}
