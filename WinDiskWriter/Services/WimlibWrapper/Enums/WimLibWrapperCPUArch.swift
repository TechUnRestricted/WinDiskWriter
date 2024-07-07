//
//  WimLibWrapperCPUArch.swift
//  WinDiskWriter
//
//  Created by Macintosh on 07.07.2024.
//

import Foundation

enum WimLibWrapperCPUArch: Int {
    case unknown = -1
    case intel = 0
    case mips = 1
    case alpha = 2
    case ppc = 3
    case shx = 4
    case arm = 5
    case ia64 = 6
    case alpha64 = 7
    case msil = 8
    case amd64 = 9
    case ia32OnWin64 = 10
    case arm64 = 12
}
