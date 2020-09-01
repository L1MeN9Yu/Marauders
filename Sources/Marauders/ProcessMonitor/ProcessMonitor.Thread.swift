//
// Created by Mengyu Li on 2020/3/5.
// Copyright (c) 2020 Mengyu Li. All rights reserved.
//

@_implementationOnly import CMarauders
import Darwin.Mach.thread_act
import Darwin.Mach.thread_info
import Dispatch

public extension ProcessMonitor {
    static func threadInfos(pid: pid_t) -> [ThreadInfo] {
        thread_info_list(pid: pid)
    }
}

private let THREAD_BASIC_INFO_COUNT = mach_msg_type_number_t(MemoryLayout<thread_basic_info_data_t>.size / MemoryLayout<UInt32>.size)
private let THREAD_IDENTIFIER_INFO_COUNT = mach_msg_type_number_t(MemoryLayout<thread_identifier_info_data_t>.size / MemoryLayout<UInt32>.size)

private extension ProcessMonitor {
    static func thread_info_list(pid: pid_t) -> [ThreadInfo] {
        var threadInfos = [ThreadInfo]()

        let mach_port_name_t_size = MemoryLayout<mach_port_name_t>.size
        let mach_port_name_t_p = UnsafeMutablePointer<mach_port_name_t>.allocate(capacity: mach_port_name_t_size)
        defer { mach_port_name_t_p.deallocate() }
        guard task_for_pid(mach_task_self_, pid, mach_port_name_t_p) == KERN_SUCCESS else { return threadInfos }
        let mach_port_name = mach_port_name_t_p.pointee

        var thread_act_array_t_p: thread_act_array_t?
        var thread_act_array_count: mach_msg_type_number_t = 0
        guard task_threads(mach_port_name, &thread_act_array_t_p, &thread_act_array_count) == KERN_SUCCESS else { return threadInfos }
        guard let thread_act_array_t = thread_act_array_t_p else { return threadInfos }

        for thread_act_array_index in 0..<thread_act_array_count {
            let target = thread_act_array_t[Int(thread_act_array_index)]

            var _thread_identifier_info = thread_identifier_info()
            var _thread_identifier_info_size = THREAD_IDENTIFIER_INFO_COUNT
            let _thread_identifier_info_kern_ret = withUnsafeMutablePointer(to: &_thread_identifier_info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    thread_info(target, thread_flavor_t(THREAD_IDENTIFIER_INFO), $0, &_thread_identifier_info_size)
                }
            }
            guard _thread_identifier_info_kern_ret == KERN_SUCCESS else {
                print("thread target : \(target) error kern_ret = \(_thread_identifier_info_kern_ret)")
                continue
            }

            let name = String(format: "%llx", arguments: [_thread_identifier_info.thread_id])
            let threadID = _thread_identifier_info.thread_id

            var _thread_basic_info = thread_basic_info()
            var _thread_basic_info_size = THREAD_BASIC_INFO_COUNT
            let _thread_basic_info_kern_ret = withUnsafeMutablePointer(to: &_thread_basic_info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    thread_info(target, thread_flavor_t(THREAD_BASIC_INFO), $0, &_thread_basic_info_size)
                }
            }
            guard _thread_basic_info_kern_ret == KERN_SUCCESS else {
                print("thread target : \(target) error kern_ret = \(_thread_basic_info_kern_ret)")
                continue
            }

            let state: String
            switch _thread_basic_info.run_state {
            case TH_STATE_RUNNING:
                state = "Running"
            case TH_STATE_STOPPED:
                state = "Stopped"
            case TH_STATE_WAITING:
                state = "Waiting"
            case TH_STATE_UNINTERRUPTIBLE:
                state = "Uninterruptible"
            case TH_STATE_HALTED:
                state = "Halted"
            default:
                state = "Unknown"
            }

            let proc_thread_info_p_size = MemoryLayout<proc_threadinfo>.size
            let proc_thread_info_p = UnsafeMutablePointer<proc_threadinfo>.allocate(capacity: proc_thread_info_p_size)
            defer { proc_thread_info_p.deallocate() }
            proc_pidinfo(pid, PROC_PIDTHREADINFO, _thread_identifier_info.thread_handle, proc_thread_info_p, Int32(proc_thread_info_p_size))

            var proc_thread_info_pth_name = proc_thread_info_p.pointee.pth_name
            let threadName = String(cString: &proc_thread_info_pth_name.0)

            let queue_address = _thread_identifier_info.dispatch_qaddr
            let queue_bit = MemoryLayout.size(ofValue: queue_address)
            var queueName: String = "-"
            var queue_size: mach_vm_size_t = 0
            let kr = mach_vm_read_overwrite(mach_task_self_, queue_address, mach_vm_size_t(queue_bit), queue_address, &queue_size)
            if kr == KERN_SUCCESS {
                // ToDo [L1MeN9Yu] 有点奇怪
                let dispatch_queue_p = UnsafeMutablePointer<DispatchQueue>.allocate(capacity: MemoryLayout<DispatchQueue>.size)
                defer { dispatch_queue_p.deallocate() }
                queueName = String(cString: __dispatch_queue_get_label(dispatch_queue_p.pointee))
            }

            let threadInfo = ThreadInfo(name: name, threadName: threadName, id: threadID, state: state, dispatchQueueName: queueName)
            threadInfos.append(threadInfo)
        }

        return threadInfos
    }
}
