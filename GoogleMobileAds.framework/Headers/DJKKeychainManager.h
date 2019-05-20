//
//  DJKKeychainManager.h
//  DJKInAppPurchase
//
//  Created by WataruSuzuki on 2017/01/10.
//  Copyright © 2017年 WataruSuzuki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DJKKeychainManager : NSObject


- (void)updatePurchased:(NSString *)appName
                withKey:(NSString *)keyName
              withValue:(BOOL)boolValue;

- (BOOL)isPurchased:(NSString *)appName
       withValueKey:(NSString *)keyName;

@end
