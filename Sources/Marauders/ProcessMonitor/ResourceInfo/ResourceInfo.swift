//
// Created by Mengyu Li on 2020/2/28.
// Copyright (c) 2020 Mengyu Li. All rights reserved.
//

import Darwin.POSIX.sys.resource
import Foundation

public struct ResourceInfo: Codable {
    public let userTime: UInt64
    public let systemTime: UInt64
    public let pkgIdleWkups: UInt64
    public let interruptWkups: UInt64
    public let pageins: UInt64
    public let wiredSize: UInt64
    public let residentSize: UInt64
    public let physFootprint: UInt64
    public let procStartAbstime: UInt64
    public let procExitAbstime: UInt64
    public let childUserTime: UInt64
    public let childSystemTime: UInt64
    public let childPkgIdleWkups: UInt64
    public let childInterruptWkups: UInt64
    public let childPageins: UInt64
    public let childElapsedAbstime: UInt64
    public let diskioBytesread: UInt64
    public let diskioByteswritten: UInt64
    public let cpuTimeQosDefault: UInt64
    public let cpuTimeQosMaintenance: UInt64
    public let cpuTimeQosBackground: UInt64
    public let cpuTimeQosUtility: UInt64
    public let cpuTimeQosLegacy: UInt64
    public let cpuTimeQosUserInitiated: UInt64
    public let cpuTimeQosUserInteractive: UInt64
    public let billedSystemTime: UInt64
    public let servicedSystemTime: UInt64
    public let logicalWrites: UInt64
    public let lifetimeMaxPhysFootprint: UInt64
    public let instructions: UInt64
    public let cycles: UInt64
    public let billedEnergy: UInt64
    public let servicedEnergy: UInt64
    public let intervalMaxPhysFootprint: UInt64
    public let runnableTime: UInt64

    public init(rusageInfo: rusage_info_current) {
        userTime = rusageInfo.ri_user_time
        systemTime = rusageInfo.ri_system_time
        pkgIdleWkups = rusageInfo.ri_pkg_idle_wkups
        interruptWkups = rusageInfo.ri_interrupt_wkups
        pageins = rusageInfo.ri_pageins
        wiredSize = rusageInfo.ri_wired_size
        residentSize = rusageInfo.ri_resident_size
        physFootprint = rusageInfo.ri_phys_footprint
        procStartAbstime = rusageInfo.ri_proc_start_abstime
        procExitAbstime = rusageInfo.ri_proc_exit_abstime
        childUserTime = rusageInfo.ri_child_user_time
        childSystemTime = rusageInfo.ri_child_system_time
        childPkgIdleWkups = rusageInfo.ri_child_pkg_idle_wkups
        childInterruptWkups = rusageInfo.ri_child_interrupt_wkups
        childPageins = rusageInfo.ri_child_pageins
        childElapsedAbstime = rusageInfo.ri_child_elapsed_abstime
        diskioBytesread = rusageInfo.ri_diskio_bytesread
        diskioByteswritten = rusageInfo.ri_diskio_byteswritten
        cpuTimeQosDefault = rusageInfo.ri_cpu_time_qos_default
        cpuTimeQosMaintenance = rusageInfo.ri_cpu_time_qos_maintenance
        cpuTimeQosBackground = rusageInfo.ri_cpu_time_qos_background
        cpuTimeQosUtility = rusageInfo.ri_cpu_time_qos_utility
        cpuTimeQosLegacy = rusageInfo.ri_cpu_time_qos_legacy
        cpuTimeQosUserInitiated = rusageInfo.ri_cpu_time_qos_user_initiated
        cpuTimeQosUserInteractive = rusageInfo.ri_cpu_time_qos_user_interactive
        billedSystemTime = rusageInfo.ri_billed_system_time
        servicedSystemTime = rusageInfo.ri_serviced_system_time
        logicalWrites = rusageInfo.ri_logical_writes
        lifetimeMaxPhysFootprint = rusageInfo.ri_lifetime_max_phys_footprint
        instructions = rusageInfo.ri_instructions
        cycles = rusageInfo.ri_cycles
        billedEnergy = rusageInfo.ri_billed_energy
        servicedEnergy = rusageInfo.ri_serviced_energy
        intervalMaxPhysFootprint = rusageInfo.ri_interval_max_phys_footprint
        runnableTime = rusageInfo.ri_runnable_time
    }
}
