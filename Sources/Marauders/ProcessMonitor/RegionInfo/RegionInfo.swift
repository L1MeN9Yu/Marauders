//
// Created by Mengyu Li on 2020/3/13.
// Copyright (c) 2020 Mengyu Li. All rights reserved.
//

@_implementationOnly import CMarauders
import Darwin.Mach.vm_prot
import Darwin.Mach.vm_statistics
import Foundation

public struct RegionInfo: Codable {
    private let _address: UInt64

    public let id: String
    public let address: String
    public let size: UInt64
    public let path: String
    public let tag: String
    public let shareMode: String
    public let mask: String

    init(region_info: proc_regionwithpathinfo) {
        let r_info = region_info.prp_prinfo
        let v_info = region_info.prp_vip

        _address = r_info.pri_address
        address = String(r_info.pri_address, radix: 16, uppercase: false)

        var vip_path = v_info.vip_path
        path = String(cString: &vip_path.0)

        id = String(r_info.pri_obj_id, radix: 16, uppercase: false)
        size = r_info.pri_size
        tag = Int32(r_info.pri_user_tag).userTag
        shareMode = Int32(r_info.pri_share_mode).shareMode
        mask = "\(r_info.pri_protection.fileMode)/\(r_info.pri_max_protection.fileMode)"
    }
}

extension RegionInfo: Equatable {
    public static func == (lhs: RegionInfo, rhs: RegionInfo) -> Bool {
        lhs._address == rhs._address
    }
}

private extension Int32 {
    var userTag: String {
        switch self {
        case 0:
            return "(0)"
        case VM_MEMORY_MALLOC:
            return "MALLOC"
        case VM_MEMORY_MALLOC_SMALL:
            return "MALLOC_SMALL"
        case VM_MEMORY_MALLOC_LARGE:
            return "MALLOC_LARGE"
        case VM_MEMORY_MALLOC_HUGE:
            return "MALLOC_HUGE"
        case VM_MEMORY_SBRK:
            return "SBRK"
        case VM_MEMORY_REALLOC:
            return "REALLOC"
        case VM_MEMORY_MALLOC_TINY:
            return "MALLOC_TINY"
        case VM_MEMORY_MALLOC_LARGE_REUSABLE:
            return "MALLOC_LARGE_REUSABLE"
        case VM_MEMORY_MALLOC_LARGE_REUSED:
            return "MALLOC_LARGE_REUSED"
        case VM_MEMORY_ANALYSIS_TOOL:
            return "ANALYSIS_TOOL"
        case VM_MEMORY_MALLOC_NANO:
            return "MALLOC_NANO"
        case VM_MEMORY_MALLOC_MEDIUM:
            return "MALLOC_MEDIUM"
        case VM_MEMORY_MACH_MSG:
            return "MACH_MSG"
        case VM_MEMORY_IOKIT:
            return "IOKIT"
        case VM_MEMORY_STACK:
            return "STACK"
        case VM_MEMORY_GUARD:
            return "GUARD"
        case VM_MEMORY_SHARED_PMAP:
            return "SHARED_PMAP"
        case VM_MEMORY_DYLIB:
            return "DYLIB"
        case VM_MEMORY_OBJC_DISPATCHERS:
            return "OBJC_DISPATCHERS"
        case VM_MEMORY_UNSHARED_PMAP:
            return "UNSHARED_PMAP"
        case VM_MEMORY_APPKIT:
            return "APPKIT"
        case VM_MEMORY_FOUNDATION:
            return "FOUNDATION"
        case VM_MEMORY_COREGRAPHICS:
            return "COREGRAPHICS"
        case VM_MEMORY_CORESERVICES:
            return "CORESERVICES"
        case VM_MEMORY_CARBON:
            return "CARBON"
        case VM_MEMORY_JAVA:
            return "JAVA"
        case VM_MEMORY_COREDATA:
            return "COREDATA"
        case VM_MEMORY_COREDATA_OBJECTIDS:
            return "COREDATA_OBJECTIDS"
        case VM_MEMORY_ATS:
            return "ATS"
        case VM_MEMORY_LAYERKIT:
            return "LAYERKIT"
        case VM_MEMORY_CGIMAGE:
            return "CGIMAGE"
        case VM_MEMORY_TCMALLOC:
            return "TCMALLOC"
        case VM_MEMORY_COREGRAPHICS_DATA:
            return "COREGRAPHICS_DATA"
        case VM_MEMORY_COREGRAPHICS_SHARED:
            return "COREGRAPHICS_SHARED"
        case VM_MEMORY_COREGRAPHICS_FRAMEBUFFERS:
            return "COREGRAPHICS_FRAMEBUFFERS"
        case VM_MEMORY_COREGRAPHICS_BACKINGSTORES:
            return "COREGRAPHICS_BACKINGSTORES"
        case VM_MEMORY_COREGRAPHICS_XALLOC:
            return "COREGRAPHICS_XALLOC"
        case VM_MEMORY_COREGRAPHICS_MISC:
            return "COREGRAPHICS_MISC"
        case VM_MEMORY_DYLD:
            return "DYLD"
        case VM_MEMORY_DYLD_MALLOC:
            return "DYLD_MALLOC"
        case VM_MEMORY_SQLITE:
            return "SQLITE"
        case VM_MEMORY_JAVASCRIPT_CORE:
            return "JAVASCRIPT_CORE"
        case VM_MEMORY_WEBASSEMBLY:
            return "WEBASSEMBLY"
        case VM_MEMORY_JAVASCRIPT_JIT_EXECUTABLE_ALLOCATOR:
            return "JAVASCRIPT_JIT_EXECUTABLE_ALLOCATOR"
        case VM_MEMORY_JAVASCRIPT_JIT_REGISTER_FILE:
            return "JAVASCRIPT_JIT_REGISTER_FILE"
        case VM_MEMORY_GLSL:
            return "GLSL"
        case VM_MEMORY_OPENCL:
            return "OPENCL"
        case VM_MEMORY_COREIMAGE:
            return "COREIMAGE"
        case VM_MEMORY_WEBCORE_PURGEABLE_BUFFERS:
            return "WEBCORE_PURGEABLE_BUFFERS"
        case VM_MEMORY_IMAGEIO:
            return "IMAGEIO"
        case VM_MEMORY_COREPROFILE:
            return "COREPROFILE"
        case VM_MEMORY_ASSETSD:
            return "ASSETSD"
        case VM_MEMORY_OS_ALLOC_ONCE:
            return "OS_ALLOC_ONCE"
        case VM_MEMORY_LIBDISPATCH:
            return "LIBDISPATCH"
        case VM_MEMORY_ACCELERATE:
            return "ACCELERATE"
        case VM_MEMORY_COREUI:
            return "COREUI"
        case VM_MEMORY_COREUIFILE:
            return "COREUIFILE"
        case VM_MEMORY_GENEALOGY:
            return "GENEALOGY"
        case VM_MEMORY_RAWCAMERA:
            return "RAWCAMERA"
        case VM_MEMORY_CORPSEINFO:
            return "CORPSEINFO"
        case VM_MEMORY_ASL:
            return "ASL"
        case VM_MEMORY_SWIFT_RUNTIME:
            return "SWIFT_RUNTIME"
        case VM_MEMORY_SWIFT_METADATA:
            return "SWIFT_METADATA"
        case VM_MEMORY_DHMM:
            return "DHMM"
        case VM_MEMORY_SCENEKIT:
            return "SCENEKIT"
        case VM_MEMORY_SKYWALK:
            return "SKYWALK"
        case VM_MEMORY_IOSURFACE:
            return "IOSURFACE"
        case VM_MEMORY_LIBNETWORK:
            return "LIBNETWORK"
        case VM_MEMORY_AUDIO:
            return "AUDIO"
        case VM_MEMORY_VIDEOBITSTREAM:
            return "VIDEOBITSTREAM"
        case VM_MEMORY_CM_XPC:
            return "CM_XPC"
        case VM_MEMORY_CM_RPC:
            return "CM_RPC"
        case VM_MEMORY_CM_MEMORYPOOL:
            return "CM_MEMORYPOOL"
        case VM_MEMORY_CM_READCACHE:
            return "CM_READCACHE"
        case VM_MEMORY_CM_CRABS:
            return "CM_CRABS"
        case VM_MEMORY_QUICKLOOK_THUMBNAILS:
            return "QUICKLOOK_THUMBNAILS"
        case VM_MEMORY_ACCOUNTS:
            return "ACCOUNTS"
        case VM_MEMORY_SANITIZER:
            return "SANITIZER"
        case VM_MEMORY_IOACCELERATOR:
            return "IOACCELERATOR"
        case VM_MEMORY_CM_REGWARP:
            return "CM_REGWARP"
        case VM_MEMORY_APPLICATION_SPECIFIC_1:
            return "APPLICATION_SPECIFIC_1"
        case VM_MEMORY_APPLICATION_SPECIFIC_16:
            return "APPLICATION_SPECIFIC_16"
        default:
            return "Tag: \(self)"
        }
    }
}

private extension Int32 {
    var shareMode: String {
        switch self {
        case SM_COW:
            return "COW"
        case SM_PRIVATE:
            return "PRIVATE"
        case SM_EMPTY:
            return "EMPTY"
        case SM_SHARED:
            return "SHARED"
        case SM_TRUESHARED:
            return "TRUESHARED"
        case SM_PRIVATE_ALIASED:
            return "PRIVATE_ALIASED"
        case SM_SHARED_ALIASED:
            return "SHARED_ALIASED"
        case SM_LARGE_PAGE:
            return "LARGE_PAGE"
        default:
            return "Unknown"
        }
    }
}

private extension UInt32 {
    var fileMode: String {
        let r = (self & UInt32(VM_PROT_READ) != 0) ? "r" : "-"
        let w = (self & UInt32(VM_PROT_WRITE) != 0) ? "w" : "-"
        let x = (self & UInt32(VM_PROT_EXECUTE) != 0) ? "x" : "-"
        return r + w + x
    }
}
