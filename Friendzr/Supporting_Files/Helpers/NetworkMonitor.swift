//
//  NetworkMonitor.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 06/04/2022.
//

import Foundation
import Network

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let queue = DispatchQueue.global()
    private let mointor: NWPathMonitor
    public private(set) var isConnected: Bool = false
    
    public private(set) var connectionType: ConnectionType = .unknown
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    private init() {
        mointor = NWPathMonitor()
    }
    
    public func startMonitoring() {
        mointor.start(queue: queue)
        mointor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status != .unsatisfied
            self?.getConnectionType(path)
            print("\(self?.isConnected ?? false)")
        }
    }
    
    public func stopMonitoring() {
        mointor.cancel()
        self.isConnected = false
    }
    
    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
            self.isConnected = true
        }
        else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
            self.isConnected = true
        }
        else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .wifi
            self.isConnected = true
        }
        else  {
            connectionType = .unknown
            self.isConnected = false
        }
    }
}
