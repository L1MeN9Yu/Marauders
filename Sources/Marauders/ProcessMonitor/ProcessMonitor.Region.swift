//
// Created by Mengyu Li on 2020/3/6.
// Copyright (c) 2020 Mengyu Li. All rights reserved.
//

@_implementationOnly import CMarauders
import CoreFoundation
import Darwin.Mach.task
import Darwin.Mach.vm_region
import Foundation

public extension ProcessMonitor {
    static func regions(pid: pid_t) -> [RegionInfo] {
        var regions = [RegionInfo]()
        let mach_port_name_p = UnsafeMutablePointer<mach_port_name_t>.allocate(capacity: MemoryLayout<mach_port_name_t>.size)
        defer { mach_port_name_p.deallocate() }
        guard task_for_pid(mach_task_self_, pid, mach_port_name_p) == KERN_SUCCESS else { return regions }
        let mach_port = mach_port_name_p.pointee
        var task_dyld_info = task_dyld_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_dyld_info_data_t>.size / MemoryLayout<natural_t>.size)
        let task_dyld_info_kern_ret = withUnsafeMutablePointer(to: &task_dyld_info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_port, task_flavor_t(TASK_DYLD_INFO), $0, &count)
            }
        }
        guard task_dyld_info_kern_ret == KERN_SUCCESS else { return regions }
        let dyld_all_image_infos_64_size = MemoryLayout<dyld_all_image_infos_64>.size
        let dyld_all_image_infos_64_p = UnsafeMutableBufferPointer<dyld_all_image_infos_64>.allocate(capacity: dyld_all_image_infos_64_size)
        do {
            let target: UInt = unsafeBitCast(dyld_all_image_infos_64_p.baseAddress, to: UInt.self)
            let target64 = UInt64(target)
            var out_size: mach_vm_size_t = 0
            let copy_rc = mach_vm_read_overwrite(
                mach_port, task_dyld_info.all_image_info_addr, task_dyld_info.all_image_info_size,
                target64, &out_size
            )
            guard copy_rc == KERN_SUCCESS else {
                print("error \(copy_rc)")
                return regions
            }
        }
        guard let dyld_all_image_infos_64 = dyld_all_image_infos_64_p.first else {
            print("error : no dyld_all_image_infos_64")
            return regions
        }

        let info_array = dyld_all_image_infos_64.infoArray
        let info_array_count = dyld_all_image_infos_64.infoArrayCount
        let info_array_memory_size = MemoryLayout<dyld_image_info_64>.size * Int(info_array_count)
        do {
            var bufferAddress: vm_offset_t = 0
            var bufferByteCount: mach_msg_type_number_t = 0

            let info_array_p_vm_read_rc = mach_vm_read(mach_port, info_array, mach_vm_size_t(info_array_memory_size), &bufferAddress, &bufferByteCount)

            guard info_array_p_vm_read_rc == KERN_SUCCESS else {
                print("mach_vm_read error")
                return regions
            }
            guard let bufferPointer = UnsafeMutableRawPointer(bitPattern: Int(bufferAddress)) else {
                print("mach_vm_read returned NULL pointer.")
                return regions
            }
            let info_array = bufferPointer.bindMemory(to: dyld_image_info_64.self, capacity: Int(info_array_count))

            //            for item in 0..<info_array_count {
            for item in 0..<1 {
                let info = info_array[Int(item)]
                var region_info = proc_regionwithpathinfo()
                let region_info_size = Int32(MemoryLayout<proc_regionwithpathinfo>.size)
                let proc_info_rc = proc_pidinfo(pid, PROC_PIDREGIONPATHINFO, info.imageLoadAddress, &region_info, region_info_size)
                guard proc_info_rc == region_info_size else {
                    print("PROC_PIDREGIONPATHINFO error (code : \(proc_info_rc)) for address :\(info.imageLoadAddress)")
                    continue
                }
                let regionInfo = RegionInfo(region_info: region_info)
                if !regions.contains(regionInfo) { regions.append(regionInfo) }

                do {
                    var current_region_info = region_info
                    var size = current_region_info.prp_prinfo.pri_size
                    while size != 0 {
                        let nextAddress = current_region_info.prp_prinfo.pri_address + current_region_info.prp_prinfo.pri_size
                        if proc_pidinfo(pid, PROC_PIDREGIONPATHINFO, nextAddress, &current_region_info, region_info_size) != region_info_size {
                            break
                        }
                        //                        if (current_region_info.prp_vip.vip_vi.vi_stat.vst_dev != 0 &&
                        //                                current_region_info.prp_vip.vip_vi.vi_stat.vst_ino != 0 &&
                        //                                (current_region_info.prp_vip.vip_vi.vi_stat.vst_dev != region_info.prp_vip.vip_vi.vi_stat.vst_dev
                        //                                        || current_region_info.prp_vip.vip_vi.vi_stat.vst_ino != region_info.prp_vip.vip_vi.vi_stat.vst_ino)) {
                        //                            break
                        //                        }
                        //                        if (current_region_info.prp_vip.vip_vi.vi_stat.vst_dev == 0 &&
                        //                                current_region_info.prp_vip.vip_vi.vi_stat.vst_ino == 0 &&
                        //                                current_region_info.prp_prinfo.pri_user_tag != 0) {
                        //                            break
                        //                        }
                        //                        if current_region_info.prp_vip.vip_path.0 == 0 {
                        //                            var size3: mach_vm_size_t = 0
                        //                            let path = UnsafeMutableBufferPointer<[CChar]>.allocate(capacity: Int(MAXPATHLEN))
                        //                            let target: UInt = unsafeBitCast(path.baseAddress, to: UInt.self)
                        //                            let target64 = UInt64(target)
                        //                            // info.imageFilePath 不对
                        //                            let path_rc = mach_vm_read_overwrite(mach_port, info.imageFilePath, mach_vm_size_t(MAXPATHLEN), target64, &size3)
                        //                            if path_rc == KERN_SUCCESS {
//
                        //                            } else {
                        //                                print("path rc error :\(path_rc)")
                        //                            }
                        //                        }
                        size = current_region_info.prp_prinfo.pri_size
                        let nextRegionInfo = RegionInfo(region_info: current_region_info)
                        if !regions.contains(nextRegionInfo) { regions.append(nextRegionInfo) }
                    }
                }
            }
        }

        return regions
    }
}
