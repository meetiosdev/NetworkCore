import Foundation

public enum LogLevel: Sendable {
    case disabled
    case errorsOnly
    case basic
    case verbose

    public static var defaultForBuild: LogLevel {
        #if DEBUG
        .basic
        #else
        .disabled
        #endif
    }
}
