# Marauders

The Process Performance Monitor in iOS(jailbroken)/macosx written by Swift.

## Marauders Library

### OSLog Monitor

The `LoggingSupport.framework` wrapper to monitor OSLog.

#### Usage:

```swift
//start monitor
try OSLogMonitor.start { message:OSLogMessage in
    // handle message
    // the callback thread is a thread in the LoggingSupport.framework.the name has
    // "com.apple.activity.stream" prefix.
    print("\(message.content)")
}

//stop monitor
OSLogMonitor.stop()
```

### Network Monitor

The `NetworkStatistics.framework` wrapper to monitor network statistics.

#### Usage

```swift
try NetworkMonitor.start(fileDescriptorPath: "/path/for/fd", dispatchQueue: .global()) { info:NetFlowInfo in
    print("\(info)")
}
````
