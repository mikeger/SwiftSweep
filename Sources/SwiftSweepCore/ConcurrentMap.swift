//
//  Created by Mike Gerasymenko <mike@gera.cx>
//

import Foundation

final class ThreadSafe<A> {
    private var _value: A
    private let queue = DispatchQueue(label: "ThreadSafe")
    init(_ value: A) {
        _value = value
    }

    var value: A {
        return queue.sync { _value }
    }

    func atomically(_ transform: (inout A) -> Void) {
        queue.sync {
            transform(&self._value)
        }
    }
    
    func atomically<R>(_ transform: (inout A) -> R) -> R {
        return queue.sync(flags: .barrier) {
            return transform(&self._value)
        }
    }
}

extension Array {
    func concurrentMap<B>(_ transform: @escaping (Element) -> B) -> [B] {
        let result = ThreadSafe([B?](repeating: nil, count: count))
        DispatchQueue.concurrentPerform(iterations: count) { idx in
            let element = self[idx]
            let transformed = transform(element)
            result.atomically {
                $0[idx] = transformed
            }
        }
        return result.value.compactMap { $0 }
    }

    func concurrentFirst(where predicate: @escaping (Element) -> Bool) -> Element? {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = ProcessInfo.processInfo.activeProcessorCount
        let result = ThreadSafe<Element?>(nil)
        let shouldStop = ThreadSafe(false)
        var operations: [BlockOperation] = []

        for element in self {
            let operation = BlockOperation {
                if shouldStop.value { return }
                if predicate(element) {
                    shouldStop.atomically { $0 = true }
                    result.atomically {
                        if $0 == nil {
                            $0 = element
                            queue.cancelAllOperations()
                        }
                    }
                }
            }
            operations.append(operation)
        }

        queue.addOperations(operations, waitUntilFinished: true)
        return result.value
    }
}

