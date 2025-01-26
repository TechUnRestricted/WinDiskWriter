//
//  HDIUtilAttachOptions.swift
//  WinDiskWriter
//
//  Created by Macintosh on 22.12.2024.
//

import Foundation

struct AttachOptions {
    let readonly: Bool?
    let readwrite: Bool?
    let kernel: Bool?
    let nokernel: Bool?
    let notremovable: Bool?
    let mount: MountOption?
    let mountRoot: String?
    let mountRandom: String?
    let mountPoint: String?
    let nobrowse: Bool?
    let owners: Bool?
    let verify: Bool?
    let ignoreBadChecksums: Bool?
    let autoopen: Bool?
    let autoopenRO: Bool?
    let autoopenRW: Bool?
    let autofsck: Bool?

    enum MountOption: String {
        case required
        case optional
        case suppressed
    }

    init(
        readonly: Bool? = nil,
        readwrite: Bool? = nil,
        kernel: Bool? = nil,
        nokernel: Bool? = nil,
        notremovable: Bool? = nil,
        mount: MountOption? = nil,
        mountRoot: String? = nil,
        mountRandom: String? = nil,
        mountPoint: String? = nil,
        nobrowse: Bool? = nil,
        owners: Bool? = nil,
        verify: Bool? = nil,
        ignoreBadChecksums: Bool? = nil,
        autoopen: Bool? = nil,
        autoopenRO: Bool? = nil,
        autoopenRW: Bool? = nil,
        autofsck: Bool? = nil
    ) {
        self.readonly = readonly
        self.readwrite = readwrite
        self.kernel = kernel
        self.nokernel = nokernel
        self.notremovable = notremovable
        self.mount = mount
        self.mountRoot = mountRoot
        self.mountRandom = mountRandom
        self.mountPoint = mountPoint
        self.nobrowse = nobrowse
        self.owners = owners
        self.verify = verify
        self.ignoreBadChecksums = ignoreBadChecksums
        self.autoopen = autoopen
        self.autoopenRO = autoopenRO
        self.autoopenRW = autoopenRW
        self.autofsck = autofsck
    }

    func toArguments() -> [String] {
        var args = ["-plist"]

        if let readonly = readonly, readonly { args.append("-readonly") }
        if let readwrite = readwrite, readwrite { args.append("-readwrite") }
        if let kernel = kernel, kernel { args.append("-kernel") }
        if let nokernel = nokernel, nokernel { args.append("-nokernel") }
        if let notremovable = notremovable, notremovable { args.append("-notremovable") }
        if let mount = mount { args.append(contentsOf: ["-mount", mount.rawValue]) }
        if let mountRoot = mountRoot { args.append(contentsOf: ["-mountroot", mountRoot]) }
        if let mountRandom = mountRandom { args.append(contentsOf: ["-mountrandom", mountRandom]) }
        if let mountPoint = mountPoint { args.append(contentsOf: ["-mountpoint", mountPoint]) }
        if let nobrowse = nobrowse, nobrowse { args.append("-nobrowse") }
        if let owners = owners { args.append(contentsOf: ["-owners", owners ? "on" : "off"]) }
        if let verify = verify { args.append(contentsOf: [verify ? "-verify" : "-noverify"]) }
        if let ignoreBadChecksums = ignoreBadChecksums { args.append(contentsOf: [ignoreBadChecksums ? "-ignorebadchecksums" : "-noignorebadchecksums"]) }
        if let autoopen = autoopen { args.append(contentsOf: [autoopen ? "-autoopen" : "-noautoopen"]) }
        if let autoopenRO = autoopenRO { args.append(contentsOf: [autoopenRO ? "-autoopenro" : "-noautoopenro"]) }
        if let autoopenRW = autoopenRW { args.append(contentsOf: [autoopenRW ? "-autoopenrw" : "-noautoopenrw"]) }
        if let autofsck = autofsck { args.append(contentsOf: [autofsck ? "-autofsck" : "-noautofsck"]) }

        return args
    }
}
