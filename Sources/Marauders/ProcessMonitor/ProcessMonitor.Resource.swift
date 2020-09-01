//
// Created by Mengyu Li on 2020/3/2.
// Copyright (c) 2020 Mengyu Li. All rights reserved.
//

@_implementationOnly import CMarauders
import Darwin.POSIX.sys.resource
import Darwin.POSIX.sys.types

public extension ProcessMonitor {
    static func resourceUsage(pid: pid_t) -> ResourceInfo {
        var u = rusage_info_current()
        withUnsafeMutablePointer(to: &u) { p in
            p.withMemoryRebound(to: rusage_info_t?.self, capacity: 1) { up in
                _ = proc_pid_rusage(pid, RUSAGE_INFO_CURRENT, up)
            }
        }
        let resourceInfo = ResourceInfo(rusageInfo: u)
        return resourceInfo
    }
}
