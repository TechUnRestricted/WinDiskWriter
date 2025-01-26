//
//  DiskMonitor.swift
//  WinDiskWriter
//
//  Created by Macintosh on 28.12.2024.
//

import SwiftUI
import Foundation
import DiskArbitration
import Combine

final class DiskMonitor: ObservableObject {
    @Published private(set) var disks: [DiskInfo] = []
    @Published private(set) var isMonitoring: Bool = false
    
    private let diskSession: DASession
    private let queue = DispatchQueue(label: "com.diskinspector.queue")
    private let autostart: Bool
    
    init(autostart: Bool = true) {
        guard let session = DASessionCreate(kCFAllocatorDefault) else {
            fatalError("Failed to create DASession")
        }
        self.diskSession = session
        self.autostart = autostart
        self.disks = DiskInspector.getDisksInfoList()
        
        if autostart {
            startMonitoring()
        }
    }
    
    deinit {
        stopMonitoring()
    }
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        DASessionScheduleWithRunLoop(
            diskSession,
            CFRunLoopGetMain(),
            CFRunLoopMode.defaultMode.rawValue
        )
        
        DARegisterDiskAppearedCallback(
            diskSession,
            nil,
            { disk, context in
                guard let context = context else { return }
                let manager = Unmanaged<DiskMonitor>.fromOpaque(context).takeUnretainedValue()
                manager.handleDiskAppeared(disk)
            },
            Unmanaged.passUnretained(self).toOpaque()
        )
        
        DARegisterDiskDisappearedCallback(
            diskSession,
            nil,
            { disk, context in
                guard let context = context else { return }
                let manager = Unmanaged<DiskMonitor>.fromOpaque(context).takeUnretainedValue()
                manager.handleDiskDisappeared(disk)
            },
            Unmanaged.passUnretained(self).toOpaque()
        )
        
        isMonitoring = true
    }
    
    func stopMonitoring() {
        guard isMonitoring else { return }
        
        DASessionUnscheduleFromRunLoop(
            diskSession,
            CFRunLoopGetMain(),
            CFRunLoopMode.defaultMode.rawValue
        )
        
        isMonitoring = false
    }
    
    func refreshDiskList() {
        disks = DiskInspector.getDisksInfoList()
    }
    
    private func handleDiskAppeared(_ disk: DADisk) {
        guard let diskDescription = DADiskCopyDescription(disk) as NSDictionary?,
              let bsdName = diskDescription[kDADiskDescriptionMediaBSDNameKey] as? String else {
            print("Failed to get disk description")
            return
        }
        
        do {
            let diskInfo = try DiskInspector.diskInfo(bsdName: bsdName)
            DispatchQueue.main.async {
                print("Disk appeared:", diskInfo.shortDescription())
                if !self.disks.contains(where: { $0.id == diskInfo.id }) {
                    self.disks.append(diskInfo)
                }
            }
        } catch {
            print("Error handling disk appearance: \(error)")
        }
    }
    
    private func handleDiskDisappeared(_ disk: DADisk) {
        guard let diskDescription = DADiskCopyDescription(disk) as NSDictionary?,
              let bsdName = diskDescription[kDADiskDescriptionMediaBSDNameKey] as? String else {
            print("Failed to get disk description")
            return
        }
        
        DispatchQueue.main.async {
            print("Disk disappeared:", bsdName)
            self.disks.removeAll { diskInfo in
                diskInfo.media.bsdName == bsdName
            }
        }
    }
}
