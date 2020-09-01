#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <stdio.h>
#include <uuid/uuid.h>
#include <mach/vm_types.h>
#include <stdbool.h>

struct dyld_all_image_infos_32 {
    uint32_t version;
    uint32_t infoArrayCount;
    mach_vm_address_t infoArray;
    uint32_t notification;
    bool processDetachedFromSharedRegion;
    bool libSystemInitialized;
    uint32_t dyldImageLoadAddress;
    uint32_t jitInfo;
    uint32_t dyldVersion;
    uint32_t errorMessage;
    uint32_t terminationFlags;
    uint32_t coreSymbolicationShmPage;
    uint32_t systemOrderFlag;
    uint32_t uuidArrayCount;
    uint32_t uuidArray;
    uint32_t dyldAllImageInfosAddress;
    uint32_t initialImageCount;
    uint32_t errorKind;
    uint32_t errorClientOfDylibPath;
    uint32_t errorTargetDylibPath;
    uint32_t errorSymbol;
    uint32_t sharedCacheSlide;
    uint8_t sharedCacheUUID[16];
    uint32_t sharedCacheBaseAddress;
    uint64_t infoArrayChangeTimestamp;
    uint32_t dyldPath;
    uint32_t notifyMachPorts[8];
    uint32_t reserved[5];
    uint32_t compact_dyld_image_info_addr;
    uint32_t compact_dyld_image_info_size;
    uint32_t platform;
};

struct dyld_all_image_infos_64 {
    uint32_t version;
    uint32_t infoArrayCount;
    mach_vm_address_t infoArray;
    uint64_t notification;
    bool processDetachedFromSharedRegion;
    bool libSystemInitialized;
    uint32_t paddingToMakeTheSizeCorrectOn32bitAndDoesntAffect64b; // NOT PART OF DYLD_ALL_IMAGE_INFOS!
    uint64_t dyldImageLoadAddress;
    uint64_t jitInfo;
    uint64_t dyldVersion;
    uint64_t errorMessage;
    uint64_t terminationFlags;
    uint64_t coreSymbolicationShmPage;
    uint64_t systemOrderFlag;
    uint64_t uuidArrayCount;
    uint64_t uuidArray;
    uint64_t dyldAllImageInfosAddress;
    uint64_t initialImageCount;
    uint64_t errorKind;
    uint64_t errorClientOfDylibPath;
    uint64_t errorTargetDylibPath;
    uint64_t errorSymbol;
    uint64_t sharedCacheSlide;
    uint8_t sharedCacheUUID[16];
    uint64_t sharedCacheBaseAddress;
    uint64_t infoArrayChangeTimestamp;
    uint64_t dyldPath;
    uint32_t notifyMachPorts[8];
    uint64_t reserved[9];
    uint64_t compact_dyld_image_info_addr;
    uint64_t compact_dyld_image_info_size;
    uint32_t platform;
};

struct dyld_image_info_32 {
    uint32_t imageLoadAddress;
    uint32_t imageFilePath;
    uint32_t imageFileModDate;
};
struct dyld_image_info_64 {
    uint64_t imageLoadAddress;
    uint64_t imageFilePath;
    uint64_t imageFileModDate;
};
