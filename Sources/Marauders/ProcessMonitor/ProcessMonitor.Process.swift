//
// Created by Mengyu Li on 2020/3/2.
// Copyright (c) 2020 Mengyu Li. All rights reserved.
//

@_implementationOnly import CMarauders
import Darwin.POSIX.sys.types
import Darwin.sys.proc

public extension ProcessMonitor {
    static func processList() -> [ProcessInfo] {
        all_pids().compactMap { pid -> ProcessInfo? in
            let pid = pid
            let name = pid_name(pid: pid)
            let path = pid_path(pid: pid)
            return ProcessInfo(pid: pid, name: name, path: path)
        }
    }

    static func processCount() -> UInt {
        UInt(pid_count())
    }

    static func processName(pid: pid_t) -> String {
        pid_name(pid: pid)
    }

    static func processPath(pid: pid_t) -> String {
        pid_path(pid: pid)
    }

    static func processID(name: String) -> pid_t? {
        let allPids = all_pids()
        let pid = allPids.first { pid in
            name == self.pid_name(pid: pid)
        }
        return pid
    }

    static func processChildProcessIDs(pid: pid_t) -> [pid_t] {
        pid_child_pids(pid: pid)
    }
}

extension ProcessMonitor {
    static func pid_count() -> Int32 {
        proc_listallpids(nil, 0)
    }

    static func pid_name(pid: pid_t) -> String {
        let nameBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(MAXPATHLEN))
        defer { nameBuffer.deallocate() }
        proc_name(pid, nameBuffer, UInt32(MAXPATHLEN))
        let procName = String(cString: nameBuffer)
        return procName
    }

    static func pid_path(pid: pid_t) -> String {
        let nameBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(MAXPATHLEN))
        defer { nameBuffer.deallocate() }
        proc_pidpath(pid, nameBuffer, UInt32(MAXPATHLEN))
        let procName = String(cString: nameBuffer)
        return procName
    }

    static func all_pids() -> [pid_t] {
        var pidsMemorySize = proc_listpids(UInt32(PROC_ALL_PIDS), 0, nil, 0)
        let pidMemorySize = MemoryLayout<pid_t>.size
        let length = Int(pidsMemorySize) / pidMemorySize
        var pids = Array(repeating: pid_t(), count: length)
        pidsMemorySize = proc_listpids(UInt32(PROC_ALL_PIDS), 0, &pids, pidsMemorySize)
        guard pidsMemorySize > 0 else { return [] }
        let resultLength = Int(pidsMemorySize) / pidMemorySize
        let pidList = Array(pids[0..<Int(resultLength)])
        return pidList
    }

    static func pid_child_pids(pid: pid_t) -> [pid_t] {
        var pidsMemorySize = proc_listpids(UInt32(PROC_PPID_ONLY), UInt32(pid), nil, 0)
        let pidMemorySize = MemoryLayout<pid_t>.size
        let length = Int(pidsMemorySize) / pidMemorySize
        var pids = Array(repeating: pid_t(), count: length)
        pidsMemorySize = proc_listpids(UInt32(PROC_PPID_ONLY), UInt32(pid), &pids, pidsMemorySize)
        guard pidsMemorySize > 0 else { return [] }
        let resultLength = Int(pidsMemorySize) / pidMemorySize
        let pidList = Array(pids[0..<Int(resultLength)])
        return pidList
    }
}
