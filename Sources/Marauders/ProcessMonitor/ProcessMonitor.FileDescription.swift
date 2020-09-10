//
// Created by Mengyu Li on 2020/3/3.
// Copyright (c) 2020 Mengyu Li. All rights reserved.
//

@_implementationOnly import CMarauders
import Darwin.POSIX.arpa.inet
import Foundation

public extension ProcessMonitor {
    static func fileDescriptions(pid: pid_t) -> [FileDescriptorInfo] {
        let fds = fd_infos(pid: pid)

        let fileDescriptors = fds.compactMap { fd_info -> FileDescriptorInfo? in
            let fd = fd_info.proc_fd
            let fd_type = Int32(fd_info.proc_fdtype)

            switch fd_type {
            case PROX_FDTYPE_ATALK:
                return nil
            case PROX_FDTYPE_VNODE:
                return fd_vnode(pid: pid, fd: fd)
            case PROX_FDTYPE_SOCKET:
                return fd_socket(pid: pid, fd: fd)
            case PROX_FDTYPE_PSHM:
                return nil
            case PROX_FDTYPE_PSEM:
                return nil
            case PROX_FDTYPE_KQUEUE:
                return fd_kqueue(pid: pid, fd: fd)
            case PROX_FDTYPE_PIPE:
                return fd_pipe(pid: pid, fd: fd)
            case PROX_FDTYPE_FSEVENTS:
                return nil
            case PROX_FDTYPE_NETPOLICY:
                return nil
            default:
                return nil
            }
        }

        return fileDescriptors
    }
}

private extension ProcessMonitor {
    static func fd_infos(pid: pid_t) -> [proc_fdinfo] {
        var fdsMemorySize = proc_pidinfo(pid, PROC_PIDLISTFDS, 0, nil, 0)
        let fdInfoSize = MemoryLayout<proc_fdinfo>.size
        let length = Int(fdsMemorySize) / fdInfoSize
        var fds = Array(repeating: proc_fdinfo(), count: length)
        fdsMemorySize = proc_pidinfo(pid, PROC_PIDLISTFDS, 0, &fds, fdsMemorySize)
        guard fdsMemorySize > 0 else { return [] }
        let resultLength = Int(fdsMemorySize) / fdInfoSize
        let fdList = Array(fds[0..<Int(resultLength)])
        return fdList
    }
}

private extension ProcessMonitor {
    static func fd_vnode(pid: pid_t, fd: Int32) -> FileDescriptorInfo? {
        let size = MemoryLayout<vnode_fdinfowithpath>.size
        let vnode = UnsafeMutablePointer<vnode_fdinfowithpath>.allocate(capacity: size)
        defer { vnode.deallocate() }
        proc_pidfdinfo(pid, fd, PROC_PIDFDVNODEPATHINFO, vnode, Int32(size))
        let vnode_fdinfowithpath = vnode.pointee
        var vip_path = vnode_fdinfowithpath.pvip.vip_path
        let path = String(cString: &vip_path.0)
        var name = path
        switch fd {
        case STDIN_FILENO:
            name += " [stdin]"
        case STDOUT_FILENO:
            name += " [stdout]"
        case STDERR_FILENO:
            name += " [stderr]"
        default:
            break
        }
        return .init(
            fd: fd,
            name: name,
            type: "VNODE",
            openFlags: vnode_fdinfowithpath.pfi.fi_openflags,
            node: vnode_fdinfowithpath.pvip.vip_vi.vi_stat.vst_ino
        )
    }

    static func fd_socket(pid: pid_t, fd: Int32) -> FileDescriptorInfo? {
        let size = MemoryLayout<socket_fdinfo>.size
        let socket = UnsafeMutablePointer<socket_fdinfo>.allocate(capacity: size)
        proc_pidfdinfo(pid, fd, PROC_PIDFDSOCKETINFO, socket, Int32(size))
        let socket_fdinfo = socket.pointee
        let socket_kind = Int(socket_fdinfo.psi.soi_kind)
        var name: String
        var type: String

        switch socket_kind {
        case SOCKINFO_TCP, SOCKINFO_IN:
            var in_socket_info: in_sockinfo = socket_fdinfo.psi.soi_kind == SOCKINFO_TCP ? socket_fdinfo.psi.soi_proto.pri_tcp.tcpsi_ini : socket_fdinfo.psi.soi_proto.pri_in
            let lip = UnsafeMutablePointer<Int8>.allocate(capacity: Int(INET_ADDRSTRLEN))
            let fip = UnsafeMutablePointer<Int8>.allocate(capacity: Int(INET_ADDRSTRLEN))

            if socket_fdinfo.psi.soi_family == AF_INET {
                inet_ntop(socket_fdinfo.psi.soi_family, &in_socket_info.insi_faddr.ina_46.i46a_addr4, fip, socklen_t(INET_ADDRSTRLEN))
                inet_ntop(socket_fdinfo.psi.soi_family, &in_socket_info.insi_laddr.ina_46.i46a_addr4, lip, socklen_t(INET_ADDRSTRLEN))
            }
            if socket_fdinfo.psi.soi_family == AF_INET6 {
                inet_ntop(socket_fdinfo.psi.soi_family, &in_socket_info.insi_faddr.ina_6, fip, socklen_t(INET_ADDRSTRLEN))
                inet_ntop(socket_fdinfo.psi.soi_family, &in_socket_info.insi_laddr.ina_6, lip, socklen_t(INET_ADDRSTRLEN))
            }
            let local_port = in_socket_info.insi_lport
            let local = getservbyport(local_port, nil)
            let foreign_port = in_socket_info.insi_fport
            let foreign = getservbyport(foreign_port, nil)
            name = "\(String(cString: lip)):"
            if let s = local?.pointee.s_name {
                name += String(cString: s)
            } else {
                name += String(local_port)
            }
            name += "->"
            if in_socket_info.insi_fport == 0 {
                name += "Listening"
            } else {
                name += String(cString: fip)
                if let s = foreign?.pointee.s_name {
                    name += ":\(String(cString: s))"
                } else {
                    name += ":\(String(foreign_port))"
                }
            }

            /*
                 struct servent any = {"*"}    // \u2731
                 struct servent *lsp = 0, *fsp = 0
                 lsp = s->insi_lport ? getservbyport(s->insi_lport, 0) : &any
                 fsp = s->insi_fport ? getservbyport(s->insi_fport, 0) : &any
                 if (lsp) name = [NSMutableString stringWithFormat:"%s:%s \u2192 ", lip, lsp->s_name]
                 else name = [NSMutableString stringWithFormat:"%s:%d \u2192 ", lip, ntohs(s->insi_lport)]
                 if (!s->insi_fport) [name appendString:"Listening"]
                 else if (fsp) [name appendFormat:"%s:%s", fip, fsp->s_name]
                 else [name appendFormat:"%s:%d", fip, ntohs(s->insi_fport)]
             */
            if socket_fdinfo.psi.soi_family == AF_INET6 {
                type = (socket_fdinfo.psi.soi_kind == SOCKINFO_TCP) ? "TCP6" : "UDP6"
            } else {
                type = (socket_fdinfo.psi.soi_kind == SOCKINFO_TCP) ? "TCP" : "UDP"
            }

            lip.deallocate()
            fip.deallocate()
        //            defer { local?.deallocate() }
        //            defer { foreign?.deallocate() }
        case SOCKINFO_UN:
            type = "UNIX"
            switch socket_fdinfo.psi.soi_type {
            case SOCK_STREAM:
                name = "STREAM"
            case SOCK_DGRAM:
                name = "DGRAM"
            case SOCK_RAW:
                name = "RAW"
            case SOCK_RDM:
                name = "RDM"
            case SOCK_SEQPACKET:
                name = "SEQPACKET"
            default:
                name = "UNIX:\(socket_fdinfo.psi.soi_type)"
            }
            /*
                 todo other process partner
                 *partner = socks.objects[(info.psi.soi_proto.pri_un.unsi_conn_so)]
                 [name appendFormat:": % \u2192 % %", SimplifyPathName(client), SimplifyPathName(server), partner ? partner : ""]
             */
            var client_path = socket_fdinfo.psi.soi_proto.pri_un.unsi_caddr.ua_sun.sun_path
            let clientPath = String(cString: &client_path.0)
            var server_path = socket_fdinfo.psi.soi_proto.pri_un.unsi_addr.ua_sun.sun_path
            let serverPath = String(cString: &server_path.0)

            name += ":\(clientPath) -> \(serverPath)"
        case SOCKINFO_GENERIC:
            name = "GENERIC: \(socket_fdinfo.psi.soi_family)"
            type = "GENERIC"
        case SOCKINFO_NDRV:
            name = "NDRV: \(socket_fdinfo.psi.soi_family)"
            type = "NDRV"
        case SOCKINFO_KERN_CTL:
            name = "KERN_CTL(KEXT): \(socket_fdinfo.psi.soi_family)"
            type = "KERN_CTL(KEXT)"
        case SOCKINFO_KERN_EVENT:
            let kern_event_info: kern_event_info = socket_fdinfo.psi.soi_proto.pri_kern_event

            let kern_vendor = Int32(kern_event_info.kesi_vendor_code_filter)
            let kern_vendor_string: String
            switch kern_vendor {
            case KEV_VENDOR_APPLE:
                kern_vendor_string = "APPLE"
            case KEV_ANY_VENDOR:
                kern_vendor_string = "ANY"
            default:
                kern_vendor_string = "\(kern_vendor)"
            }

            let kern_class = Int32(kern_event_info.kesi_class_filter)
            let kern_subclass = Int32(kern_event_info.kesi_subclass_filter)
            let kern_class_string: String
            var kern_subclass_string: String = kern_subclass == KEV_ANY_SUBCLASS ? "ANY" : "\(kern_subclass)"
            switch kern_class {
            case KEV_NETWORK_CLASS:
                kern_class_string = "NETWORK"
                switch kern_subclass {
                case KEV_INET_SUBCLASS:
                    kern_subclass_string = "INET"
                case KEV_DL_SUBCLASS:
                    kern_subclass_string = "DATALINK"
                case KEV_NETPOLICY_SUBCLASS:
                    kern_subclass_string = "POLICY"
                case KEV_SOCKET_SUBCLASS:
                    kern_subclass_string = "SOCKET"
                case KEV_ATALK_SUBCLASS:
                    kern_subclass_string = "APPLETALK"
                case KEV_INET6_SUBCLASS:
                    kern_subclass_string = "INET6"
                case KEV_ND6_SUBCLASS:
                    kern_subclass_string = "ND6"
                case KEV_NECP_SUBCLASS:
                    kern_subclass_string = "NECP"
                case KEV_NETAGENT_SUBCLASS:
                    kern_subclass_string = "NETAGENT"
                case KEV_LOG_SUBCLASS:
                    kern_subclass_string = "LOG"
                default: break
                }
            case KEV_IOKIT_CLASS:
                kern_class_string = "IOKIT"
            case KEV_SYSTEM_CLASS:
                kern_class_string = "SYSTEM"
                switch kern_subclass {
                case KEV_CTL_SUBCLASS:
                    kern_subclass_string = "CTL"
                case KEV_MEMORYSTATUS_SUBCLASS:
                    kern_subclass_string = "MEMORYSTATUS"
                default: break
                }
            case KEV_APPLESHARE_CLASS:
                kern_class_string = "APPLESHARE"
            case KEV_FIREWALL_CLASS:
                kern_class_string = "FIREWALL"
                switch kern_subclass {
                case KEV_IPFW_SUBCLASS:
                    kern_subclass_string = "IPFW"
                case KEV_IP6FW_SUBCLASS:
                    kern_subclass_string = "IP6FW"
                default: break
                }
            case KEV_IEEE80211_CLASS:
                kern_class_string = "WIFI"
                switch kern_subclass {
                case KEV_APPLE80211_EVENT_SUBCLASS:
                    kern_subclass_string = "EVENT"
                default: break
                }
            case KEV_ANY_CLASS:
                kern_class_string = "ANY"
            default:
                kern_class_string = "\(kern_class)"
            }

            name = "\(kern_vendor_string):\(kern_class_string):\(kern_subclass_string)"
            type = "KERN_EVENT"
        default:
            return nil
        }

        return .init(
            fd: fd,
            name: name,
            type: type,
            openFlags: socket_fdinfo.pfi.fi_openflags,
            node: socket_fdinfo.psi.soi_so
        )
    }

    static func fd_kqueue(pid: pid_t, fd: Int32) -> FileDescriptorInfo? {
        let size = MemoryLayout<kqueue_fdinfo>.size
        let kqueue = UnsafeMutablePointer<kqueue_fdinfo>.allocate(capacity: size)
        defer { kqueue.deallocate() }
        proc_pidfdinfo(pid, fd, PROC_PIDFDKQUEUEINFO, kqueue, Int32(size))
        let kqueue_fdinfo = kqueue.pointee
        let kqueue_state = kqueue_fdinfo.kqueueinfo.kq_state

        var name: String
        if (kqueue_state & UInt32(PROC_KQUEUE_64)) != 0 {
            name = "KQUEUE64:"
        } else if (kqueue_state & UInt32(PROC_KQUEUE_32)) != 0 {
            name = "KQUEUE32:"
        } else {
            name = "KQUEUE:"
        }
        if (kqueue_state & UInt32(PROC_KQUEUE_SELECT)) != 0 { name += " SELECT" }
        if (kqueue_state & UInt32(PROC_KQUEUE_SLEEP)) != 0 { name += " SLEEP" }
        if (kqueue_state & UInt32(PROC_KQUEUE_QOS)) != 0 { name += " QOS" }
        if (kqueue_state & ~(UInt32(PROC_KQUEUE_32) | UInt32(PROC_KQUEUE_64))) == 0 { name += " SUSPENDED" }

        return .init(
            fd: fd,
            name: name,
            type: "QUEUE",
            openFlags: kqueue_fdinfo.pfi.fi_openflags,
            node: UInt64(kqueue_fdinfo.kqueueinfo.kq_state)
        )
    }

    static func fd_pipe(pid: pid_t, fd: Int32) -> FileDescriptorInfo? {
        let size = MemoryLayout<pipe_fdinfo>.size
        let pipe = UnsafeMutablePointer<pipe_fdinfo>.allocate(capacity: size)
        defer { pipe.deallocate() }
        proc_pidfdinfo(pid, fd, PROC_PIDFDPIPEINFO, pipe, Int32(size))
        let pipe_fdinfo = pipe.pointee
        let pipe_status = pipe_fdinfo.pipeinfo.pipe_status

        var name: String = ""

        /*
         todo other process partner
         NSString *partner = socks.objects[(info.pipeinfo.pipe_peerhandle)]
         name = [NSMutableString stringWithFormat:"\u2192 %", partner ? partner : "<Unknown>"]
         */

        if pipe_status & PIPE_ASYNC != 0 { name += " ASYNC" }
        if pipe_status & PIPE_WANTR != 0 { name += " WANTR" }
        if pipe_status & PIPE_WANTW != 0 { name += " WANTW" }
        if pipe_status & PIPE_WANT != 0 { name += " WANT" }
        if pipe_status & PIPE_SEL != 0 { name += " SEL" }
        if pipe_status & PIPE_EOF != 0 { name += " EOF" }
        if pipe_status & PIPE_LOCKFL != 0 { name += " LOCKFL" }
        if pipe_status & PIPE_LWANT != 0 { name += " LWANT" }
        if pipe_status & PIPE_DIRECTW != 0 { name += " DIRECTW" }
        if pipe_status & PIPE_DIRECTOK != 0 { name += " DIRECTOK" }
        if pipe_status & PIPE_DRAIN != 0 { name += " DRAIN" }
        if pipe_status & PIPE_WSELECT != 0 { name += " WSELECT" }
        if pipe_status & PIPE_DEAD != 0 { name += " DEAD" }
        if pipe_status == 0 { name += "EXITED WITH STATUS 0" }

        return .init(
            fd: fd,
            name: name,
            type: "PIPE",
            openFlags: pipe_fdinfo.pfi.fi_openflags,
            node: pipe_fdinfo.pipeinfo.pipe_handle
        )
    }
}
