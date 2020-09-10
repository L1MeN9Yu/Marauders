//
// Created by Mengyu Li on 2020/3/20.
// Copyright (c) 2020 Mengyu Li. All rights reserved.
//

@_implementationOnly import CMarauders
import Darwin.POSIX.dlfcn
import Foundation
import os.log

@available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
public struct OSLogMonitor {
    private init() {}
}

@available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
private extension OSLogMonitor {
    static var callback: Callback?
    static let flags = os_activity_stream_flag_t(OS_ACTIVITY_STREAM_INFO | OS_ACTIVITY_STREAM_DEBUG)
}

@available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
public extension OSLogMonitor {
    typealias Callback = (OSLogMessage) -> Void

    static func start(callback: @escaping Callback) throws {
        try setup()
        self.callback = callback

        let stream_block: os_activity_stream_block_t = { entry, error in
            handleStreamEntry(entry: entry, error: error)
        }
        let stream_event_block: os_activity_stream_event_block_t = { _, _ in }
        activity_stream = s_os_activity_stream_for_pid?(-1, flags, stream_block)
        s_os_activity_stream_set_event_handler?(activity_stream, stream_event_block)
        s_os_activity_stream_resume?(activity_stream)
    }

    static func stop() {
        callback = nil
        guard let stream = activity_stream else { return }
        guard let cancel = s_os_activity_stream_cancel else { return }
        cancel(stream)
    }
}

@available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
private extension OSLogMonitor {
    static func handleStreamEntry(entry: os_activity_stream_entry_t?, error: Int32) -> Bool {
        guard let entry = entry?.pointee else { return true }
        guard error == 0 else { return true }
        let pid = entry.pid
        let processName = ProcessMonitor.processName(pid: pid)
        if entry.type == OS_ACTIVITY_STREAM_TYPE_ACTIVITY_CREATE {
            return true
        }
        if entry.type == OS_ACTIVITY_STREAM_TYPE_LOG_MESSAGE {
            var log_message = entry.log_message
            let message_char_optional: UnsafePointer<CChar>? = UnsafePointer<CChar>(s_os_log_copy_formatted_message?(&log_message))
            defer { message_char_optional?.deallocate() }
            guard let message = String(cString: message_char_optional) else { return true }
            let logType = OSLogType(m_os_log_get_type?(&log_message) ?? OSLogType.default.rawValue)
            let category = String(cString: log_message.category) ?? ""
            let subsystem = String(cString: log_message.subsystem) ?? ""

            let osLogMessage = OSLogMessage(pid: pid, processName: processName, category: category, subsystem: subsystem, type: logType, message: message)

            callback?(osLogMessage)
        }

        return true
    }
}

// MARK: - OSLog Valid

@available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
private extension OSLogMonitor {
    static let frameworkPath = "/System/Library/PrivateFrameworks/LoggingSupport.framework/LoggingSupport"

    static var activity_stream: os_activity_stream_t?
    static var s_os_activity_stream_for_pid: os_activity_stream_for_pid_t?
    static var s_os_activity_stream_resume: os_activity_stream_resume_t?
    static var s_os_activity_stream_cancel: os_activity_stream_cancel_t?
    static var s_os_activity_stream_set_event_handler: os_activity_stream_set_event_handler_t?
    static var s_os_log_copy_formatted_message: os_log_copy_formatted_message_t?

    typealias m_os_log_get_type_t = @convention(c) (UnsafeMutableRawPointer?) -> UInt8
    static var m_os_log_get_type: m_os_log_get_type_t?

    static func setup() throws {
        guard let framework = dlopen(frameworkPath, RTLD_NOW) else {
            throw Error.frameworkOpenFailed(String(cString: dlerror()))
        }
        defer { dlclose(framework) }

        guard let s_os_activity_stream_for_pid_p = dlsym(framework, "os_activity_stream_for_pid") else {
            throw Error.symbolNotFound("os_activity_stream_for_pid")
        }
        s_os_activity_stream_for_pid = unsafeBitCast(s_os_activity_stream_for_pid_p, to: os_activity_stream_for_pid_t.self)
        guard let s_os_activity_stream_resume_p = dlsym(framework, "os_activity_stream_resume") else {
            throw Error.symbolNotFound("os_activity_stream_resume")
        }
        s_os_activity_stream_resume = unsafeBitCast(s_os_activity_stream_resume_p, to: os_activity_stream_resume_t.self)
        guard let s_os_activity_stream_cancel_p = dlsym(framework, "os_activity_stream_cancel") else {
            throw Error.symbolNotFound("os_activity_stream_cancel")
        }
        s_os_activity_stream_cancel = unsafeBitCast(s_os_activity_stream_cancel_p, to: os_activity_stream_cancel_t.self)
        guard let s_os_log_copy_formatted_message_p = dlsym(framework, "os_log_copy_formatted_message") else {
            throw Error.symbolNotFound("os_log_copy_formatted_message")
        }
        s_os_log_copy_formatted_message = unsafeBitCast(s_os_log_copy_formatted_message_p, to: os_log_copy_formatted_message_t.self)
        guard let s_os_activity_stream_set_event_handler_p = dlsym(framework, "os_activity_stream_set_event_handler") else {
            throw Error.symbolNotFound("os_activity_stream_set_event_handler")
        }
        s_os_activity_stream_set_event_handler = unsafeBitCast(s_os_activity_stream_set_event_handler_p, to: os_activity_stream_set_event_handler_t.self)
        guard let m_os_log_get_type_t_p = dlsym(framework, "os_log_get_type") else {
            throw Error.symbolNotFound("os_log_get_type")
        }
        m_os_log_get_type = unsafeBitCast(m_os_log_get_type_t_p, to: m_os_log_get_type_t.self)
    }
}
