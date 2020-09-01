//
// Created by Mengyu Li on 2020/3/19.
// Copyright (c) 2020 Mengyu Li. All rights reserved.
//

@_implementationOnly import CMarauders
import CoreFoundation
import Darwin.POSIX.fcntl
import Foundation

public struct NetworkMonitor { private init() {} }

public extension NetworkMonitor {
    typealias Callback = (NetFlowInfo) -> Void
    static var callback: Callback?

    static func start(fileDescriptorPath: String, dispatchQueue: DispatchQueue = .main, callback: @escaping Callback) throws {
        try setup()

        self.callback = callback

        guard let manager = nStatManagerCreateFunc?(kCFAllocatorDefault, dispatchQueue, managerCallback) else {
            throw Error.functionFailed("NStatManagerCreate")
        }

        _ = nStatManagerSetFlags?(manager, 0)

        let fd = open(fileDescriptorPath, O_RDWR | O_CREAT | O_TRUNC)
        guard fd > 0 else { throw Error.fdFailed(String(cString: strerror(errno))) }

        _ = nStatManagerSetInterfaceTraceFD?(manager, fd)
        _ = nStatManagerAddAllUDPWithFilter?(manager, 0, 0)
        _ = nStatManagerAddAllTCPWithFilter?(manager, 0, 0)
    }
}

private func managerCallback(source: NStatSourceRef?, info: UnsafeMutableRawPointer?) {
    //    NStatSourceSetRemovedBlock(source, managerSourceRemovedCallback)
    //    NStatSourceSetEventsBlock(source, managerSourceEventsCallback)
    guard let source = source else { return }
    NetworkMonitor.nStatSourceSetDescriptionBlock?(source, managerSourceDescriptionCallback)
    _ = NetworkMonitor.nStatSourceQueryDescription?(source)
}

private func managerSourceRemovedCallback() {}

private func managerSourceEventsCallback(source: NStatSourceRef?) {}

private func managerSourceDescriptionCallback(dict: CFDictionary?) {
    guard let dict = dict as? [String: Any] else { return }

    guard let pid = dict[NetworkMonitor.kNStatSrcKeyPIDKey] as? pid_t else { return }
    guard let processName = dict[NetworkMonitor.kNStatSrcKeyProcessNameKey] as? String else { return }
    guard let rxBytes = dict[NetworkMonitor.kNStatSrcKeyRxBytesKey] as? UInt64 else { return }
    guard let txBytes = dict[NetworkMonitor.kNStatSrcKeyTxBytesKey] as? UInt64 else { return }
    guard let provider = dict[NetworkMonitor.kNStatSrcKeyProviderKey] as? String else { return }

    let tcpState = dict[NetworkMonitor.kNStatSrcKeyTCPStateKey] as? String ?? ""

    guard let localAddressData = dict[NetworkMonitor.kNStatSrcKeyLocalKey] as? Data else { return }
    guard let remoteAddressData = dict[NetworkMonitor.kNStatSrcKeyRemoteKey] as? Data else { return }

    func sockaddrDataToIP(data: Data) -> String {
        data.withUnsafeBytes { (rawBufferPointer: UnsafeRawBufferPointer) -> String in
            let unsafeBufferPointer = rawBufferPointer.bindMemory(to: sockaddr.self)
            guard let sockaddr_p = unsafeBufferPointer.baseAddress else { return "" }
            guard sockaddr_p.pointee.sa_family == AF_INET || sockaddr_p.pointee.sa_family == AF_INET6 else { return "" }
            return sockaddr_p.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { (sockaddr_in_p: UnsafePointer<sockaddr_in>) -> String in
                guard let address_c = inet_ntoa(sockaddr_in_p.pointee.sin_addr) else { return "" }
                let address = String(cString: address_c)
                return address + ":\(sockaddr_in_p.pointee.sin_port)"
            }
        }
    }

    let localAddress = sockaddrDataToIP(data: localAddressData)
    let remoteAddress = sockaddrDataToIP(data: remoteAddressData)

    let info = NetFlowInfo(
        pid: pid, processName: processName, provider: provider, tcpState: tcpState,
        rxBytes: rxBytes, txBytes: txBytes, localAddress: localAddress,
        remoteAddress: remoteAddress
    )
    NetworkMonitor.callback?(info)
}

extension NetworkMonitor {
    static let frameworkPath = "/System/Library/PrivateFrameworks/NetworkStatistics.framework/NetworkStatistics"

    typealias NStatManagerCreateFunc = @convention(c) (_: CFAllocator?, _: DispatchQueue, _: @escaping (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Void) -> NStatManagerRef?
    static var nStatManagerCreateFunc: NStatManagerCreateFunc?

    typealias NStatManagerSetInterfaceTraceFDFunc = @convention(c) (_: NStatManagerRef, _ fd: Int32) -> Int32
    static var nStatManagerSetInterfaceTraceFD: NStatManagerSetInterfaceTraceFDFunc?

    typealias NStatManagerSetFlagsFunc = @convention(c) (_: NStatManagerRef, _ Flags: Int32) -> Int32
    static var nStatManagerSetFlags: NStatManagerSetFlagsFunc?

    typealias NStatManagerAddAllTCPWithFilterFunc = @convention(c) (_: NStatManagerRef, _ something: Int32, _ somethingElse: Int32) -> Int32
    static var nStatManagerAddAllTCPWithFilter: NStatManagerAddAllTCPWithFilterFunc?

    typealias NStatManagerAddAllUDPWithFilterFunc = @convention(c) (_: NStatManagerRef, _ something: Int32, _ somethingElse: Int32) -> Int32
    static var nStatManagerAddAllUDPWithFilter: NStatManagerAddAllUDPWithFilterFunc?

    typealias NStatSourceSetDescriptionBlockFunc = @convention(c) (_: NStatSourceRef, _: @escaping (CFDictionary?) -> Void) -> Void
    static var nStatSourceSetDescriptionBlock: NStatSourceSetDescriptionBlockFunc?

    typealias NStatSourceQueryDescriptionFunc = @convention(c) (_: NStatSourceRef) -> UnsafeMutableRawPointer?
    static var nStatSourceQueryDescription: NStatSourceQueryDescriptionFunc?

    typealias DictKeyType = String
    static var kNStatSrcKeyPIDKey: DictKeyType = "processID"
    static var kNStatSrcKeyProcessNameKey: DictKeyType = "processName"
    static var kNStatSrcKeyRxBytesKey: DictKeyType = "rxBytes"
    static var kNStatSrcKeyTxBytesKey: DictKeyType = "txBytes"
    static var kNStatSrcKeyProviderKey: DictKeyType = "provider"
    static var kNStatSrcKeyTCPStateKey: DictKeyType = "TCPState"
    static var kNStatSrcKeyLocalKey: DictKeyType = "localAddress"
    static var kNStatSrcKeyRemoteKey: DictKeyType = "remoteAddress"

    static func setup() throws {
        guard let framework = dlopen(frameworkPath, RTLD_NOW) else {
            throw Error.frameworkOpenFailed(String(cString: dlerror()))
        }
        defer { dlclose(framework) }

        guard let NStatManagerCreate_p = dlsym(framework, "NStatManagerCreate") else {
            throw Error.symbolNotFound("NStatManagerCreate")
        }
        nStatManagerCreateFunc = unsafeBitCast(NStatManagerCreate_p, to: NStatManagerCreateFunc.self)

        guard let NStatManagerSetInterfaceTraceFD_p = dlsym(framework, "NStatManagerSetInterfaceTraceFD") else {
            throw Error.symbolNotFound("NStatManagerSetInterfaceTraceFD")
        }
        nStatManagerSetInterfaceTraceFD = unsafeBitCast(NStatManagerSetInterfaceTraceFD_p, to: NStatManagerSetInterfaceTraceFDFunc.self)

        guard let NStatManagerSetFlags_p = dlsym(framework, "NStatManagerSetFlags") else {
            throw Error.symbolNotFound("NStatManagerSetFlags")
        }
        nStatManagerSetFlags = unsafeBitCast(NStatManagerSetFlags_p, to: NStatManagerSetFlagsFunc.self)

        guard let NStatManagerAddAllTCPWithFilter_p = dlsym(framework, "NStatManagerAddAllTCPWithFilter") else {
            throw Error.symbolNotFound("NStatManagerAddAllTCPWithFilter")
        }
        nStatManagerAddAllTCPWithFilter = unsafeBitCast(NStatManagerAddAllTCPWithFilter_p, to: NStatManagerAddAllTCPWithFilterFunc.self)

        guard let NStatManagerAddAllUDPWithFilter_p = dlsym(framework, "NStatManagerAddAllUDPWithFilter") else {
            throw Error.symbolNotFound("NStatManagerAddAllUDPWithFilter")
        }
        nStatManagerAddAllUDPWithFilter = unsafeBitCast(NStatManagerAddAllUDPWithFilter_p, to: NStatManagerAddAllUDPWithFilterFunc.self)

        guard let NStatSourceSetDescriptionBlock_p = dlsym(framework, "NStatSourceSetDescriptionBlock") else {
            throw Error.symbolNotFound("NStatSourceSetDescriptionBlock")
        }
        nStatSourceSetDescriptionBlock = unsafeBitCast(NStatSourceSetDescriptionBlock_p, to: NStatSourceSetDescriptionBlockFunc.self)

        guard let NStatSourceQueryDescription_p = dlsym(framework, "NStatSourceQueryDescription") else {
            throw Error.symbolNotFound("NStatSourceQueryDescription")
        }
        nStatSourceQueryDescription = unsafeBitCast(NStatSourceQueryDescription_p, to: NStatSourceQueryDescriptionFunc.self)
    }
}

typealias NStatManagerRef = UnsafeMutableRawPointer
typealias NStatSourceRef = UnsafeMutableRawPointer
