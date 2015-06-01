//
//  eLongLocation.h
//  eLongLocationManager
//
//  Created by zhucuirong on 15/5/27.
//  Copyright (c) 2015年 elong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface eLongLocation : NSObject

- (instancetype)initWithCLLocation:(CLLocation *)location;
/**
 *  保留最原始的CLLocation信息
 */
@property (nonatomic, strong, readonly) CLLocation *rawLocation;

/**
 *  反地理编码后的回调
 */
@property (nonatomic, copy) void(^reverseGeocodeLocationCompletionHandler)(NSError *error);


///////////////////////////处理后的信息///////////////////////////

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;

/**
 *  当前定位的行政信息
 */
@property (nonatomic, readonly) CLPlacemark *placemark;

/**
 *  当前位置是否在国外
 */
@property (nonatomic, readonly) BOOL abroad;

/**
 *  当前定位城市，市级别城市(名称不包含“市”)
 */
@property (nonatomic, readonly) NSString *city;

/**
 *  当前定位地址全称，由自己拼接而成
 */
@property (nonatomic, readonly) NSString *address;

/**
 *  当前定位地址全称（去掉了“中国”），为直接读取的数据，但这样读取包含了重复信息，eg: 北京市朝阳区酒仙桥街道酒仙桥酒仙桥中路
 */
@property (nonatomic, readonly) NSString *formattedAddressLines;

@end
