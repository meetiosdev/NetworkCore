import Foundation

public enum LoadableState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(Error)
}
