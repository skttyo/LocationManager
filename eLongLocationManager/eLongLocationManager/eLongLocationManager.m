//
//  eLongLocationManager.m
//  eLongLocationManager
//
//  Created by zhucuirong on 15/5/26.
//  Copyright (c) 2015年 elong. All rights reserved.
//

#import "eLongLocationManager.h"
#import "INTULocationManager.h"

@interface eLongLocationManager ()
@property (nonatomic, strong) INTULocationManager *locationManager;
@end

@implementation eLongLocationManager

+ (eLongLocationServicesState)locationServicesState {
    return (eLongLocationServicesState)[INTULocationManager locationServicesState];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static id _sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.locationManager = [INTULocationManager sharedInstance];
    }
    return self;
}

- (eLongLocationRequestID)requestLocationWithDesiredAccuracy:(eLongLocationAccuracy)desiredAccuracy
                                                     timeout:(NSTimeInterval)timeout
                                                       block:(eLongLocationRequestBlock)block {
    return [self requestLocationWithDesiredAccuracy:desiredAccuracy timeout:timeout delayUntilAuthorized:YES block:block];
}

- (eLongLocationRequestID)requestLocationWithDesiredAccuracy:(eLongLocationAccuracy)desiredAccuracy
                                                     timeout:(NSTimeInterval)timeout
                                        delayUntilAuthorized:(BOOL)delayUntilAuthorized
                                                       block:(eLongLocationRequestBlock)block {
    return [self.locationManager requestLocationWithDesiredAccuracy:(INTULocationAccuracy)desiredAccuracy timeout:timeout delayUntilAuthorized:delayUntilAuthorized block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        if (currentLocation && status == INTULocationStatusSuccess) {
            eLongLocation *processedLocation = [[eLongLocation alloc] initWithCLLocation:currentLocation];
            __weak eLongLocation *weakProcessedLocation = processedLocation;
            processedLocation.reverseGeocodeLocationCompletionHandler = ^(NSError *error) {
                if (error) {
                    block(currentLocation, nil, (eLongLocationAccuracy)achievedAccuracy, (eLongLocationStatus)status);
                }
                else {
                    block(currentLocation, weakProcessedLocation, (eLongLocationAccuracy)achievedAccuracy, (eLongLocationStatus)status);
                }
            };
        }
        else {
            block(currentLocation, nil, (eLongLocationAccuracy)achievedAccuracy, (eLongLocationStatus)status);
        }
    }];
}

- (eLongLocationRequestID)subscribeToLocationUpdatesWithBlock:(eLongLocationRequestBlock)block {
    return [self.locationManager subscribeToLocationUpdatesWithBlock:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        if (currentLocation && status == INTULocationStatusSuccess) {
            eLongLocation *processedLocation = [[eLongLocation alloc] initWithCLLocation:currentLocation];
            __weak eLongLocation *weakProcessedLocation = processedLocation;
            processedLocation.reverseGeocodeLocationCompletionHandler = ^(NSError *error) {
                if (error) {
                    block(currentLocation, nil, (eLongLocationAccuracy)achievedAccuracy, (eLongLocationStatus)status);
                }
                else {
                    block(currentLocation, weakProcessedLocation, (eLongLocationAccuracy)achievedAccuracy, (eLongLocationStatus)status);
                }
            };
        }
        else {
            block(currentLocation, nil, (eLongLocationAccuracy)achievedAccuracy, (eLongLocationStatus)status);
        }
    }];
}

- (void)forceCompleteLocationRequest:(eLongLocationRequestID)requestID {
    [self.locationManager forceCompleteLocationRequest:requestID];
}

- (void)cancelLocationRequest:(eLongLocationRequestID)requestID {
    [self.locationManager cancelLocationRequest:requestID];
}


+ (UIAlertView *)showAlertViewWithStatus:(eLongLocationStatus)status delegate:(id<UIAlertViewDelegate>)delegate {
    NSString *message;
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    switch (status) {
        case eLongLocationStatusSuccess: {
            return nil;
            break;
        }
        case eLongLocationStatusTimedOut: {
            //@"Location request timed out."
            message = [NSString stringWithFormat:@"%@的定位请求超时", appName];
            break;
        }
        case eLongLocationStatusServicesNotDetermined: {
            //@"Error: User has not responded to the permissions alert."
            message = [NSString stringWithFormat:@"用户没有响应%@的定位服务授权", appName];
            break;
        }
        case eLongLocationStatusServicesDenied: {
            //@"Error: User has denied this app permissions to access device location.";
            message = [NSString stringWithFormat:@"用户拒绝了%@的定位服务", appName];
            break;
        }
        case eLongLocationStatusServicesRestricted: {
            //@"Error: User is restricted from using location services by a usage policy.";
            message = [NSString stringWithFormat:@"定位服务受到限制"];
            break;
        }
        case eLongLocationStatusServicesDisabled: {
            //@"Error: Location services are turned off for all apps on this device.";
            message = [NSString stringWithFormat:@"用户关闭了手机的定位功能"];
            break;
        }
        case eLongLocationStatusError: {
            message = @"定位出错";
            break;
        }
        default: {
            //@"An unknown error occurred.\n(Are you using iOS Simulator with location set to 'None'?)"
            message = @"未知错误";
            break;
        }
    }
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:message delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
    return av;
}

@end
