//
// Created by Mengyu Li on 2020/3/16.
// Copyright (c) 2020 Mengyu Li. All rights reserved.
//

@_implementationOnly import CMarauders
import Foundation

class _MachPortInfo {
    let port: mach_port_name_t
    let type: mach_port_type_t
    let object: natural_t
    let objectType: UInt32
    //    let members: [mach_port_name_t]
    private(set) var connect = [String]()

    //    public init(port: mach_port_name_t, type: mach_port_type_t, object: natural_t, objectType: UInt32, members: [mach_port_name_t]) {
    public init(port: mach_port_name_t, type: mach_port_type_t, object: natural_t, objectType: UInt32) {
        self.port = port
        self.type = type
        self.object = object
        self.objectType = objectType
        //        self.members = members
    }

    public func add(connect: String) {
        self.connect.append(connect)
    }
}

public struct MachPortInfo: Codable {
    public let port: String
    public let type: String
    //    public let members: [String]
    let object: String
    public let connect: [String]

    init(info: _MachPortInfo) {
        port = "0x\(String(info.port, radix: 16))"
        type = info.objectType.portType
        //        self.members = info.members.map { name_t -> String in "0x\(String(name_t, radix: 16))" }
        object = "0x\(String(info.object, radix: 16))"
        connect = info.connect
    }
}

private extension UInt32 {
    var portType: String {
        switch Int32(self) {
        case IKOT_NONE: return "NONE"
        case IKOT_THREAD: return "THREAD"
        case IKOT_TASK: return "TASK"
        case IKOT_HOST: return "HOST"
        case IKOT_HOST_PRIV: return "HOST_PRIV"
        case IKOT_PROCESSOR: return "PROCESSOR"
        case IKOT_PSET: return "PSET"
        case IKOT_PSET_NAME: return "PSET_NAME"
        case IKOT_TIMER: return "TIMER"
        case IKOT_PAGING_REQUEST: return "PAGING_REQUEST"
        case IKOT_MIG: return "MIG"
        case IKOT_MEMORY_OBJECT: return "MEMORY_OBJECT"
        case IKOT_XMM_PAGER: return "XMM_PAGER"
        case IKOT_XMM_KERNEL: return "XMM_KERNEL"
        case IKOT_XMM_REPLY: return "XMM_REPLY"
        case IKOT_UND_REPLY: return "UND_REPLY"
        case IKOT_HOST_NOTIFY: return "HOST_NOTIFY"
        case IKOT_HOST_SECURITY: return "HOST_SECURITY"
        case IKOT_LEDGER: return "LEDGER"
        case IKOT_MASTER_DEVICE: return "MASTER_DEVICE"
        case IKOT_TASK_NAME: return "TASK_NAME"
        case IKOT_SUBSYSTEM: return "SUBSYSTEM"
        case IKOT_IO_DONE_QUEUE: return "IO_DONE_QUEUE"
        case IKOT_SEMAPHORE: return "SEMAPHORE"
        case IKOT_LOCK_SET: return "LOCK_SET"
        case IKOT_CLOCK: return "CLOCK"
        case IKOT_CLOCK_CTRL: return "CLOCK_CTRL"
        case IKOT_IOKIT_IDENT: return "IOKIT_IDENT"
        case IKOT_NAMED_ENTRY: return "NAMED_ENTRY"
        case IKOT_IOKIT_CONNECT: return "IOKIT_CONNECT"
        case IKOT_IOKIT_OBJECT: return "IOKIT_OBJECT"
        case IKOT_UPL: return "UPL"
        case IKOT_MEM_OBJ_CONTROL: return "MEM_OBJ_CONTROL"
        case IKOT_AU_SESSIONPORT: return "AU_SESSIONPORT"
        case IKOT_FILEPORT: return "FILEPORT"
        case IKOT_LABELH: return "LABELH"
        case IKOT_TASK_RESUME: return "TASK_RESUME"
        case IKOT_VOUCHER: return "VOUCHER"
        case IKOT_VOUCHER_ATTR_CONTROL: return "VOUCHER_ATTR_CONTROL"
        case IKOT_WORK_INTERVAL: return "WORK_INTERVAL"
        case IKOT_UX_HANDLER: return "UX_HANDLER"
        case IKOT_UEXT_OBJECT: return "UEXT_OBJECT"
        case IKOT_ARCADE_REG: return "ARCADE_REG"
        case IKOT_UNKNOWN: return "UNKNOWN"
        default:
            return "UNKNOWN"
        }
    }
}
