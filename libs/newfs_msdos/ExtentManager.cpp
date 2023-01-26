/*
 * Copyright (c) 2008 Apple Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_LICENSE_HEADER_END@
 */
//
//    ExtentManager.cpp
//

#include "ExtentManager.h"

void
ExtentManager::Init(uint32_t theBlockSize, uint32_t theNativeBlockSize, off_t theTotalBytes)
{
    blockSize = theBlockSize;
    nativeBlockSize = theNativeBlockSize;
    totalBytes = theTotalBytes;
    totalBlocks = howmany(totalBytes, blockSize);

    // add sentry empty extents at both sides so empty partition doesn't need to be handled specially
    AddBlockRangeExtent(0, 0);
    AddBlockRangeExtent(totalBlocks, 0);
}

void
ExtentManager::MergeExtent(const ExtentInfo &a, const ExtentInfo &b, ExtentInfo *c)
{
    // merge ext into *curIt
    c->blockAddr = min(a.blockAddr, b.blockAddr);
    c->numBlocks = max(a.blockAddr + a.numBlocks, b.blockAddr + b.numBlocks) - c->blockAddr;
}

void
ExtentManager::AddBlockRangeExtent(off_t blockAddr, off_t numBlocks)
{
    struct ExtentInfo ext, newExt;
    ListExtIt curIt, newIt;
    bool merged = false;

    // make the range a valid range
    if ((blockAddr > totalBlocks) || (blockAddr + numBlocks < 0)) { // totally out of range, do nothing
        return;
    }
    if (blockAddr < 0) {
        numBlocks = blockAddr + numBlocks;
        blockAddr = 0;
    }
    if (blockAddr + numBlocks > totalBlocks) {
        numBlocks = totalBlocks - blockAddr;
    }

    ext.blockAddr = blockAddr;
    ext.numBlocks = numBlocks;

    for (curIt = extentList.begin(); curIt != extentList.end(); curIt++) {
        if (BeforeExtent(ext, *curIt))
            break;
        if (!BeforeExtent(*curIt, ext)) { // overlapped extents
            MergeExtent(ext, *curIt, &newExt);
            *curIt = newExt;
            merged = true;
            break;
        }
    }

    // insert ext before curIt
    if (!merged) {
        curIt = extentList.insert(curIt, ext); // throws bad_alloc when out of memory
    }

    // merge the extents
    newIt = curIt;
    curIt = extentList.begin();
    while (curIt != extentList.end()) {
        if (curIt == newIt || BeforeExtent(*curIt, *newIt)) { // curIt is before newIt
            curIt++;
            continue;
        }
        if (BeforeExtent(*newIt, *curIt)) { // curIt is after newIt now, we are done
            break;
        }
        // merge the two extents
        MergeExtent(*curIt, *newIt, &newExt);
        *newIt = newExt;
        curIt = extentList.erase(curIt);
    }
    // printf("After %s(%lld, %lld)\n", __func__, blockAddr, numBlocks);     DebugPrint();
} // ExtentManager::AddBlockRangeExtent

void
ExtentManager::RemoveBlockRangeExtent(off_t blockAddr, off_t numBlocks)
{
    struct ExtentInfo ext, newExt;
    ListExtIt curIt;

    ext.blockAddr = blockAddr;
    ext.numBlocks = numBlocks;

    curIt = extentList.begin();
    while (curIt != extentList.end()) {
        if (BeforeExtent(*curIt, ext)) {
            curIt++;
            continue;
        }
        if (BeforeExtent(ext, *curIt)) // we are done
            break;
        // overlapped extents
        if (curIt->blockAddr >= ext.blockAddr &&
            curIt->blockAddr + curIt->numBlocks <= ext.blockAddr + ext.numBlocks) {
            // *curIt is totally within ext, remove curIt
            curIt = extentList.erase(curIt);
        } else if (curIt->blockAddr < ext.blockAddr &&
            curIt->blockAddr + curIt->numBlocks > ext.blockAddr + ext.numBlocks) {
            // ext is totally within *curIt, split ext into two
            newExt.blockAddr = ext.blockAddr + ext.numBlocks;
            newExt.numBlocks = curIt->blockAddr + curIt->numBlocks - newExt.blockAddr;
            curIt->numBlocks = ext.blockAddr - curIt->blockAddr;
            curIt++;
            extentList.insert(curIt, newExt); // throws bad_alloc when out of memory
            curIt++;
        } else { // remove part of ext
            if (curIt->blockAddr >= ext.blockAddr) { // remove the former part of *curIt
                assert(curIt->blockAddr + curIt->numBlocks > newExt.blockAddr);
                newExt.blockAddr = ext.blockAddr + ext.numBlocks;
                newExt.numBlocks = curIt->blockAddr + curIt->numBlocks - newExt.blockAddr;
                *curIt = newExt;
            } else { // remove the latter part of *curIt
                curIt->numBlocks = ext.blockAddr - curIt->blockAddr;
            }
            curIt++;
        }
    }
    //printf("After %s(%lld, %lld)\n", __func__, blockAddr, numBlocks);     DebugPrint();
}

void
ExtentManager::AddByteRangeExtent(off_t byteAddr, off_t numBytes)
{
    off_t blockAddr = byteAddr / blockSize;
    off_t blockAddrOfLastByte = (byteAddr + numBytes - 1) / blockSize;
    off_t numBlocks = blockAddrOfLastByte - blockAddr + 1;
    AddBlockRangeExtent(blockAddr, numBlocks);
}

void
ExtentManager::DebugPrint()
{
    ListExtIt it;

    for (it = extentList.begin(); it != extentList.end(); it++) {
        printf("[%lld, %lld] ", it->blockAddr, it->numBlocks);
    }
    printf("\n");
}
