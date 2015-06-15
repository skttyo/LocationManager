# LocationManager
定位服务

iOS 6 & 7

For iOS 6 & 7, it is recommended that you provide a description for how your app uses location services by setting a string for the key NSLocationUsageDescription in your app's Info.plist file.
iOS6和7系统，应该在info.plist中加入一个key为NSLocationUsageDescription的定位说明



iOS 8

Starting with iOS 8, you must provide a description for how your app uses location services by setting a string for the key NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription in your app's Info.plist file. INTULocationManager determines which level of permissions to request based on which description key is present. You should only request the minimum permission level that your app requires, therefore it is recommended that you use the "When In Use" level unless you require more access. If you provide values for both description keys, the more permissive "Always" level is requested.
iOS8系统， 使用期间的定位说明key: NSLocationWhenInUseUsageDescription
持续定位说明key: NSLocationAlwaysUsageDescription