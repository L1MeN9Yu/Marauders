//
// Created by Mengyu Li on 2020/3/16.
// Copyright (c) 2020 Mengyu Li. All rights reserved.
//

@_implementationOnly import CMarauders
import Darwin.Mach.port
import Darwin.POSIX
import Foundation

public extension ProcessMonitor {
    static func machPorts(pid: pid_t) -> [MachPortInfo] {
        let knowPosts = launchdPorts()

        let _machPorts = mach_port(pid: pid)

        let other_pids = ProcessMonitor.all_pids()
        other_pids.forEach { other_pid in
            if other_pid == pid { return }
            let other_mach_ports = mach_port(pid: other_pid)
            other_mach_ports.forEach { other_mach_port in
                if let matched_mach_port = (_machPorts.first { self_mach_port in self_mach_port.object == other_mach_port.object }) {
                    //                    let proc_name = Self.pid_name(pid: other_pid)
                    //                    print(proc_name)
                    let self_type = matched_mach_port.type
                    let other_type = other_mach_port.type
                    if (self_type & MACH_PORT_TYPE_RECEIVE != 0) && (other_type & MACH_PORT_TYPE_SEND_RIGHTS != 0) {
                        let other_proc_name = Self.pid_name(pid: other_pid)
                        let other_proc_port_name = "0x\(String(other_mach_port.port, radix: 16))"
                        let other_proc_port_object = "0x\(String(other_mach_port.object, radix: 16))"
                        var know_port_name: String = ""
                        if let matched_launch_ports_name = knowPosts[other_mach_port.object] {
                            know_port_name = "(\(matched_launch_ports_name))"
                        }
                        matched_mach_port.add(connect: "<-\(know_port_name)\(other_proc_name):\(other_pid):\(other_proc_port_name):\(other_proc_port_object)")
                    } else if (self_type & MACH_PORT_TYPE_SEND_RIGHTS != 0) && (other_type & MACH_PORT_TYPE_RECEIVE != 0) {
                        let other_proc_name = Self.pid_name(pid: other_pid)
                        let other_proc_port_name = "0x\(String(other_mach_port.port, radix: 16))"
                        let other_proc_port_object = "0x\(String(other_mach_port.object, radix: 16))"
                        var know_port_name: String = ""
                        if let matched_launch_ports_name = knowPosts[other_mach_port.object] {
                            know_port_name = "(\(matched_launch_ports_name))"
                        }
                        matched_mach_port.add(connect: "->\(know_port_name)\(other_proc_name):\(other_pid):\(other_proc_port_name):\(other_proc_port_object)")
                    }
                }
            }
        }

        let machPorts = _machPorts.map { info -> MachPortInfo in MachPortInfo(info: info) }
        return machPorts
    }
}

private extension ProcessMonitor {
    static func mach_port(pid: pid_t) -> [_MachPortInfo] {
        var infos = [_MachPortInfo]()

        let mach_port_name_t_size = MemoryLayout<mach_port_name_t>.size
        let mach_port_name_t_p = UnsafeMutablePointer<mach_port_name_t>.allocate(capacity: mach_port_name_t_size)
        defer { mach_port_name_t_p.deallocate() }
        let task_for_pid_rc = task_for_pid(mach_task_self_, pid, mach_port_name_t_p)
        guard task_for_pid_rc == KERN_SUCCESS else {
            print("task for pid error :\(task_for_pid_rc)")
            return infos
        }
        let mach_port_name = mach_port_name_t_p.pointee
        let ipc_info_space_t_p = UnsafeMutablePointer<ipc_info_space_t>.allocate(capacity: MemoryLayout<ipc_info_space_t>.size)
        defer { ipc_info_space_t_p.deallocate() }
        var ipc_info_name_array: ipc_info_name_array_t?
        var ipc_info_name_array_count: mach_msg_type_number_t = 0
        var ipc_info_tree_name_array: ipc_info_tree_name_array_t?
        var ipc_info_tree_name_array_count: mach_msg_type_number_t = 0
        let mach_port_space_info_rc = mach_port_space_info(mach_port_name, ipc_info_space_t_p, &ipc_info_name_array, &ipc_info_name_array_count, &ipc_info_tree_name_array, &ipc_info_tree_name_array_count)
        guard mach_port_space_info_rc == KERN_SUCCESS else {
            print("mach_port_space_info error :\(mach_port_space_info_rc)")
            return infos
        }
        if let tree = ipc_info_tree_name_array {
            tree.deallocate()
        }

        guard let name_array = ipc_info_name_array else {
            print("ipc_info_name_array is nil")
            return infos
        }

        for index in 0..<ipc_info_name_array_count {
            let ipc_info_name_inner = name_array[Int(index)] as ipc_info_name_t
            if ipc_info_name_inner.iin_name == 0 { continue }
            let object_type_p = UnsafeMutablePointer<UInt32>.allocate(capacity: MemoryLayout<UInt32>.size)
            defer { object_type_p.deallocate() }
            let object_addr_p = UnsafeMutablePointer<UInt32>.allocate(capacity: MemoryLayout<UInt32>.size)
            defer { object_addr_p.deallocate() }
            mach_port_kernel_object(mach_port_name, ipc_info_name_inner.iin_name, object_type_p, object_addr_p)
            //            let name = String(ipc_info_name.iin_name, radix: 16)
            //            let type = object_type_p.pointee < portTypes.count ? portTypes[Int(object_type_p.pointee)] : "(unknown)"
            //            var members = [mach_port_name_t]()
//
            //            var members_name_array_optional: mach_port_name_array_t?
            //            var members_count: mach_msg_type_number_t = 0
            //            let mach_port_get_set_status_rc = mach_port_get_set_status(mach_port_name, ipc_info_name.iin_name, &members_name_array_optional, &members_count)
            //            if mach_port_get_set_status_rc == KERN_SUCCESS,
            //               let members_name_array = members_name_array_optional {
            //                if ipc_info_name.iin_type & MACH_PORT_TYPE_PORT_SET != 0 {
            //                    for member_index in 0..<members_count {
            //                        let member_name = members_name_array[Int(member_index)]
            //                        members.append(member_name)
            //                    }
            //                }
            //            }
            //            infos.append(_MachPortInfo(port: ipc_info_name.iin_name, type: ipc_info_name.iin_type, object: ipc_info_name.iin_object, objectType: object_type_p.pointee, members: members))
            infos.append(_MachPortInfo(port: ipc_info_name_inner.iin_name, type: ipc_info_name_inner.iin_type, object: ipc_info_name_inner.iin_object, objectType: object_type_p.pointee))
            //            infos.append((ipc_info_name.iin_name, ipc_info_name.iin_type, object_type_p.pointee, members))
            //            print("\(name) | \(type) | \(members.map { name_t -> String in String(name_t, radix: 16) })")
        }

        return infos
    }
}

private extension ProcessMonitor {
    static let MACH_PORT_TYPE_PORT_SET = {
        mach_port_type_t(1 << (MACH_PORT_RIGHT_PORT_SET + mach_port_right_t(16)))
    }()

    static let MACH_PORT_TYPE_RECEIVE = {
        mach_port_type_t(1 << (MACH_PORT_RIGHT_RECEIVE + mach_port_right_t(16)))
    }()

    static let MACH_PORT_TYPE_SEND = {
        mach_port_type_t(1 << (MACH_PORT_RIGHT_SEND + mach_port_right_t(16)))
    }()

    static let MACH_PORT_TYPE_SEND_ONCE = {
        mach_port_type_t(1 << (MACH_PORT_RIGHT_SEND_ONCE + mach_port_right_t(16)))
    }()

    static let MACH_PORT_TYPE_SEND_RIGHTS = {
        MACH_PORT_TYPE_SEND | MACH_PORT_TYPE_SEND_ONCE
    }()
}

public extension ProcessMonitor {
    static let launchdPortsFile = "/tmp/Nemesis.ports.xpc.launchd.domain"

    static func launchdPorts() -> [UInt32: String] {
        var knowPorts = [UInt32: String]()

        let flag = O_CREAT | O_TRUNC | FWRITE
        let fd = open(launchdPortsFile, flag)
        defer { close(fd) }
        guard fd > 0 else {
            print("fd open error")
            return knowPorts
        }
        let f_chmod_rc = fchmod(fd, 0x1A4)
        guard f_chmod_rc == 0 else {
            print("fchmod error")
            return knowPorts
        }

        let xpc_dictionary = xpc_dictionary_create(nil, nil, 0)
        xpc_dictionary_set_uint64(xpc_dictionary, "handle", 0)
        xpc_dictionary_set_uint64(xpc_dictionary, "handle", 0)
        xpc_dictionary_set_uint64(xpc_dictionary, "routine", 828)
        xpc_dictionary_set_uint64(xpc_dictionary, "subsystem", 3)
        xpc_dictionary_set_uint64(xpc_dictionary, "type", 1)
        xpc_dictionary_set_fd(xpc_dictionary, "fd", fd)
        let xpc_pipe = xpc_pipe_create_from_port(bootstrap_port, 0)
        var xpc_result_optional: xpc_object_t?
        xpc_pipe_routine(xpc_pipe, xpc_dictionary, &xpc_result_optional)
        guard let xpc_result = xpc_result_optional else {
            print("xpc result nil")
            return knowPorts
        }
        let xpc_pipe_error = xpc_dictionary_get_int64(xpc_result, "error")
        guard xpc_pipe_error == 0 else {
            print("xpc pipe error :\(xpc_pipe_error)")
            return knowPorts
        }
        do {
            let fileContent = try String(contentsOf: URL(fileURLWithPath: launchdPortsFile))
            guard let endpointRange = fileContent.range(of: "\tendpoints = {") else {
                print("endpoint not found")
                return knowPorts
            }
            let endpointStartContent = fileContent[endpointRange.upperBound..<fileContent.endIndex]
            guard let endpointEndRange = endpointStartContent.firstIndex(of: Character("}")) else {
                print("endpoint not found")
                return knowPorts
            }
            let endpointContent = endpointStartContent[endpointStartContent.startIndex..<endpointEndRange]
            let contents = endpointContent.components(separatedBy: "\n\t").filter { s in !s.isEmpty }
            var tuples = [(UInt32, String)]()
            contents.forEach { s in
                let array = (s.components(separatedBy: " ").filter { s in !s.isEmpty }).filter { s in !s.contains("\t") }
                guard var portString = array.first,
                    let bundleID = array.last else { return }
                if portString.hasPrefix("0x") {
                    portString = String(portString.dropFirst(2))
                }
                guard let port = UInt32(portString, radix: 16) else { return }
                tuples.append((port, bundleID))
            }
            let launchdMachPorts = mach_port(pid: 1)
            launchdMachPorts.forEach { info in
                if let matched = (tuples.first { tuple in tuple.0 == info.port }) {
                    knowPorts[info.object] = matched.1
                }
            }
            return knowPorts
        } catch {
            print("\(error)")
            return knowPorts
        }
    }
}
