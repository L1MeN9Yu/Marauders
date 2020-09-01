//
// Created by Mengyu Li on 2020/8/21.
//

import Darwin.POSIX.dlfcn
import Foundation

public struct SystemKernelExtensions { private init() {} }

private extension SystemKernelExtensions {
    typealias OSKextCopyLoadedKextInfoFunc = @convention(c) (_ kextIdentifiers: CFArray?, _ infoKeys: CFArray?) -> Unmanaged<CFDictionary>?
    static let IOKitFrameworkPath = "/System/Library/Frameworks/IOKit.framework/IOKit"
}

public extension SystemKernelExtensions {
    static let infoKeys = [
        "CFBundleIdentifier",
        "OSBundleExecutablePath",
        "OSBundleLoadAddress",
        "OSBundleLoadSize",
        "OSBundleLoadTag",
        "OSBundleRetainCount",
    ]

    static func retrieve(infoKeys: [String]? = infoKeys) throws -> [String: [String: Any]]? {
        guard let framework = dlopen(IOKitFrameworkPath, RTLD_NOW) else {
            throw Error.frameworkOpenFailed(String(cString: dlerror()))
        }
        defer { dlclose(framework) }

        guard let OSKextCopyLoadedKextInfoFuncPointer = dlsym(framework, "OSKextCopyLoadedKextInfo") else {
            throw Error.symbolNotFound("OSKextCopyLoadedKextInfo")
        }
        let function = unsafeBitCast(OSKextCopyLoadedKextInfoFuncPointer, to: OSKextCopyLoadedKextInfoFunc.self)
        guard let kext = function(nil, infoKeys as CFArray?)?.takeUnretainedValue() as? [String: [String: Any]] else {
            return nil
        }

        return kext
    }
}
