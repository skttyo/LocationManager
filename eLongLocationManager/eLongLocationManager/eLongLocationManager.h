//
//  eLongLocationManager.h
//  eLongLocationManager
//
//  Created by zhucuirong on 15/5/26.
//  Copyright (c) 2015年 elong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "eLongLocationDefines.h"
#import <UIKit/UIKit.h>

#define eLongLocationDefaultTimeout 10.f

@interface eLongLocationManager : NSObject

+ (eLongLocationServicesState)locationServicesState;

+ (instancetype)sharedInstance;

/**
 *  一次性定位，定位完成则关闭定位服务，等待用户授权完才开始timeout
 *
 *  @param desiredAccuracy 在测试时达到的最好精度是65.00m，在“崔各庄”定位的精度大于1000m,所以这里一般传eLongLocationAccuracyCity（精度5000米），但此框架用的真正“定位精度”为： CLLocationManager.desiredAccuracy = kCLLocationAccuracyBest
 *  @param timeout         因为要进行地理反编码，所以真实的timeout会稍微大点
 *  @param block           block description
 *
 *  @return <#return value description#>
 */
- (eLongLocationRequestID)requestLocationWithDesiredAccuracy:(eLongLocationAccuracy)desiredAccuracy
                                                    timeout:(NSTimeInterval)timeout
                                                      block:(eLongLocationRequestBlock)block;

/**
 *  <#Description#>
 *
 *  @param desiredAccuracy      <#desiredAccuracy description#>
 *  @param timeout              <#timeout description#>
 *  @param delayUntilAuthorized 是否用户授权完才开始计算timeout
 *  @param block                如果delayUntilAuthorized:NO且用户一直不响应定位授权框，在timeout过后，该block执行且eLongLocationStatus status为eLongLocationStatusServicesNotDetermined
 *
 *  @return <#return value description#>
 */
- (eLongLocationRequestID)requestLocationWithDesiredAccuracy:(eLongLocationAccuracy)desiredAccuracy
                                                    timeout:(NSTimeInterval)timeout
                                       delayUntilAuthorized:(BOOL)delayUntilAuthorized
                                                      block:(eLongLocationRequestBlock)block;

/**
 *  持续性定位
 *
 *  @param block <#block description#>
 *
 *  @return <#return value description#>
 */
- (eLongLocationRequestID)subscribeToLocationUpdatesWithBlock:(eLongLocationRequestBlock)block;



/** 强制完成指定的定位请求，如果是一次性的定位，则相当于定位超时，并调用之前的定位block,如果是持续性的定位，则不调用定位block直接取消定位*/
- (void)forceCompleteLocationRequest:(eLongLocationRequestID)requestID;

/** 取消指定的定位请求*/
- (void)cancelLocationRequest:(eLongLocationRequestID)requestID;

+ (UIAlertView *)showAlertViewWithStatus:(eLongLocationStatus)status delegate:(id<UIAlertViewDelegate>)delegate;

@end
