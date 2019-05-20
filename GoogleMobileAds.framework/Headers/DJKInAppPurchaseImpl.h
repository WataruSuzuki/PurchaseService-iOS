//
//  DJKInAppPurchaseImpl.h
//  DJKInAppPurchase
//
//  Created by WataruSuzuki on 2017/01/10.
//  Copyright © 2017年 WataruSuzuki. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@class DJKInAppPurchaseImpl;

@protocol DJKInAppPurchaseDelegate
- (void)updatePurchasedStatus:(BOOL)purchased withID:(NSString *)productID;
@end

@interface DJKInAppPurchaseImpl : NSObject <SKProductsRequestDelegate,SKPaymentTransactionObserver>
{
    //nothing
}
@property (weak, nonatomic) id <DJKInAppPurchaseDelegate> delegate;
//@property (weak, nonatomic) NSString* itemName;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL canMakePurchases;

- (instancetype)initWithViewController:(UIViewController *)controller
                               withApp:(NSString *)clientAppName
                               withKey:(NSArray *)clientItemArray;
- (void)validateProduct;
- (void)addPaymentTransaction;

@end
