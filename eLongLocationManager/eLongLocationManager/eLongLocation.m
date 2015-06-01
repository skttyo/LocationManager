//
//  eLongLocation.m
//  eLongLocationManager
//
//  Created by zhucuirong on 15/5/27.
//  Copyright (c) 2015年 elong. All rights reserved.
//

#import "eLongLocation.h"
#import <AddressBook/AddressBook.h>

static inline double transformLatitude(double x, double y) {
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

static inline double transformLongitude(double x, double y) {
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}

static inline void wgs84ToGCJ_02WithLatitudeLongitude(double *lat, double *lon) {
    const double a = 6378245.0f;
    const double ee = 0.00669342162296594323;
    
    double dLat = transformLatitude(*lon - 105.0, *lat - 35.0);
    double dLon = transformLongitude(*lon - 105.0, *lat - 35.0);
    double radLat = *lat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    *lat = *lat + dLat;
    *lon = *lon + dLon;
}

@interface  NSString (eLongCheckString)

- (BOOL)hasValue;

@end

@implementation NSString (eLongCheckString)

- (BOOL)hasValue {
    if (self && [self isKindOfClass:[NSString class]] && [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        return YES;
    }
    return NO;
}

@end

@interface eLongLocation ()
@property (nonatomic, strong) CLLocation *rawLocation;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) CLPlacemark *placemark;
@property (nonatomic, assign) BOOL abroad;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *formattedAddressLines;

@end

@implementation eLongLocation

- (instancetype)initWithCLLocation:(CLLocation *)location {
    if (self = [super init]) {
        self.rawLocation = location;
    }
    return self;
}

#pragma mark - custom accessor
- (void)setRawLocation:(CLLocation *)rawLocation {
    if (_rawLocation == rawLocation) {
        return;
    }
    _rawLocation = rawLocation;
    
    self.coordinate = rawLocation.coordinate;

    double lon = rawLocation.coordinate.longitude;
    double lat = rawLocation.coordinate.latitude;
    // 把坐标点范围锁定在国内，排除国外的情况
    if (lon > 72.004 && lon < 137.8347 && lat > 0.8293 && lat < 55.8271) {
        // 纠偏处理
        wgs84ToGCJ_02WithLatitudeLongitude(&lat, &lon);
        self.coordinate = CLLocationCoordinate2DMake(lat, lon);
    }
    
    // 火星坐标
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude
                                                      longitude:self.coordinate.longitude];
    [self reverseGeocodeLocation:location];
}

#pragma mark - 位置反编码
- (void)reverseGeocodeLocation:(CLLocation *)location {
    CLGeocoder * geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks,NSError *error) {
        if (error) {
            NSLog(@"获取定位信息失败， 失败原因 = %@", error.localizedDescription);
        }
        // 取得第一个地标，地标中存储了详细的地址信息，注意：一个地名可能搜索出多个地址
        CLPlacemark *placemark = [placemarks firstObject];
        self.placemark = placemark;
        
        if ([placemark.ISOcountryCode isEqualToString:@"CN"]) {
            // 中国大陆
            self.abroad = NO;
        }
        else if ([placemark.ISOcountryCode  isEqualToString:@"TW"]
                 || [placemark.ISOcountryCode  isEqualToString:@"HK"]
                 || [placemark.ISOcountryCode  isEqualToString:@"MO"]) {
            //中国台湾、中国香港、中国澳门
            self.abroad = NO;
            self.coordinate = self.rawLocation.coordinate;
        }
        else {
            // 国外
            self.abroad = YES;
        }
        
        // 省 eg:北京市、湖南省
        NSString *administrativeArea = placemark.administrativeArea;
        //使用系统定义的字符串直接查询，记得导入AddressBook框架
        if (![administrativeArea hasValue]) {
            administrativeArea = placemark.addressDictionary[(NSString *)kABPersonAddressStateKey];
        }
        
        // 市 eg:北京市市辖区、长沙市
        NSString *locality = placemark.locality;
        if (![locality hasValue]) {
            locality = placemark.addressDictionary[(NSString *)kABPersonAddressCityKey];
        }
        self.city = [locality hasValue] ? locality : administrativeArea;
        
        // 区 eg:朝阳区
        NSString *subLocality = [placemark.subLocality hasValue] ? placemark.subLocality : @"";
        
        // 街道 eg:酒仙桥中路
        NSString *thoroughfare = [placemark.thoroughfare hasValue] ? placemark.thoroughfare : @"";
        
        //subThoroughfare为街道相关信息、例如门牌等 eg: 6878号
        if ([placemark.subThoroughfare hasValue]) {
            thoroughfare = [thoroughfare stringByAppendingString:placemark.subThoroughfare];
        }
        
        //位置名 eg:星科大厦
        NSString *name = [placemark.name hasValue] ? placemark.name : @"";
        
        if ([locality hasSuffix:@"市市辖区"]) {
            locality = @"";
        }
        self.address = [NSString stringWithFormat:@"%@%@%@%@%@", administrativeArea, locality, subLocality, thoroughfare, name];

        NSArray * allKeys = placemark.addressDictionary.allKeys;
        for (NSString * key in allKeys) {
         //NSLog(@"key = %@, value = %@", key, placemark.addressDictionary[key]);
            if ([key isEqualToString:@"FormattedAddressLines"]) {
                self.formattedAddressLines = [placemark.addressDictionary[key] componentsJoinedByString:@""];
                if ([self.formattedAddressLines hasPrefix:@"中国"]) {
                    self.formattedAddressLines = [self.formattedAddressLines substringFromIndex:2];
                }
            }
        }
        
        if (self.reverseGeocodeLocationCompletionHandler) {
            self.reverseGeocodeLocationCompletionHandler(error);
        }
    }];
}

#pragma mark - custom accessor
- (void)setCity:(NSString *)city {
    if (_city == city) {
        return;
    }
    
    if ([city hasSuffix:@"市市辖区"]) {
        city = [city substringToIndex:([city rangeOfString:@"市市辖区"]).location];
    }
    else if ([city hasSuffix:@"市"]) {
        if (city.length > 2) {
            city = [city substringToIndex:([city rangeOfString:@"市"]).location];
        }
    }
    else if ([city hasPrefix:@"香港"]) {
        city = @"香港";
    }
    else if ([city hasPrefix:@"澳门"] || [city hasPrefix:@"澳門"]) {
        city = @"澳门";
    }
    
    _city = city;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n ======原定位信息：======\n <rawLocation:%@>\n ======处理后的信息：====== \n <coordinate:%f, %f>\n <abroad:%@>\n <city:%@>\n <address:%@>\n <formattedAddressLines:%@>\n", self.rawLocation, self.coordinate.latitude, self.coordinate.longitude, self.abroad ? @"YES": @"NO", self.city, self.address, self.formattedAddressLines];
}

@end
