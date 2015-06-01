//
//  eLongLocationDefines.h
//  eLongLocationManager
//
//  Created by zhucuirong on 15/5/26.
//  Copyright (c) 2015年 elong. All rights reserved.
//

#ifndef eLongLocationManager_eLongLocationDefines_h
#define eLongLocationManager_eLongLocationDefines_h
#import <CoreLocation/CoreLocation.h>
#import "INTULocationRequestDefines.h"
#import "eLongLocation.h"

/** The possible states that location services can be in. */
typedef NS_ENUM(NSInteger, eLongLocationServicesState) {
    /** 定位服务可用且用户已同意
     Note: this state will be returned for both the "When In Use" and "Always" permission levels. */
    eLongLocationServicesStateAvailable = INTULocationServicesStateAvailable,
    
    /** 用户还没有响应定位服务授权框 */
    eLongLocationServicesStateNotDetermined = INTULocationServicesStateNotDetermined,
    
    /** 用户拒绝该应用的定位服务 */
    eLongLocationServicesStateDenied = INTULocationServicesStateDenied,
    
    /** 定位服务受到限制（如 "家长控制" "公司政策" etc.） */
    eLongLocationServicesStateRestricted = INTULocationServicesStateRestricted,
    
    /** 用户设备关闭了定位服务（所有应用都不可定位） */
    eLongLocationServicesStateDisabled = INTULocationServicesStateDisabled
};

/** 定位请求对应的唯一ID */
typedef INTULocationRequestID eLongLocationRequestID;

/** 定位精度 */
typedef NS_ENUM(NSInteger, eLongLocationAccuracy) {
    /** 持续性定位时的精度，无需手动设置 */
    eLongLocationAccuracyNone = INTULocationAccuracyNone,
    
    // The below options are valid desired accuracies.
    /** 5000米 或更好 10分钟内有效（10分钟内再次定位，若满足精度则使用上次的定位结果） */
    eLongLocationAccuracyCity = INTULocationAccuracyCity,
    
    /** 1000米 或更好 5分钟内有效 */
    eLongLocationAccuracyNeighborhood = INTULocationAccuracyNeighborhood,
    
    /** 100米 或更好 1分钟内有效 */
    eLongLocationAccuracyBlock = INTULocationAccuracyBlock,
    
    /** 15米 或更好 15秒内有效 */
    eLongLocationAccuracyHouse = INTULocationAccuracyHouse,
    
    /** 5米 或更好 5秒内有效 */
    eLongLocationAccuracyRoom = INTULocationAccuracyRoom,
};

typedef NS_ENUM(NSInteger, eLongLocationStatus) {
    // These statuses will accompany a valid location.
    /** 定位成功 */
    eLongLocationStatusSuccess = INTULocationStatusSuccess,
    
    /** 定位超时（不适用于持续性的定位） */
    eLongLocationStatusTimedOut = INTULocationStatusTimedOut,
    
    // These statuses indicate some sort of error, and will accompany a nil location.
    /**  用户没有响应定位服务授权框 */
    eLongLocationStatusServicesNotDetermined = INTULocationStatusServicesNotDetermined,
    
    /** 用户拒绝该应用定位 */
    eLongLocationStatusServicesDenied = INTULocationStatusServicesDenied,
    
    /** 定位受限 （如 "家长控制" "公司政策" etc.）*/
    eLongLocationStatusServicesRestricted = INTULocationStatusServicesRestricted,
    
    /** 用户设备关闭了定位服务（所有应用都不可定位） */
    eLongLocationStatusServicesDisabled = INTULocationStatusServicesDisabled,
    
    /** 其它错误 */
    eLongLocationStatusError = INTULocationStatusError
};

typedef void (^eLongLocationRequestBlock) (CLLocation *rawLocation, eLongLocation *processedLocation, eLongLocationAccuracy achievedAccuracy, eLongLocationStatus status);


#endif
