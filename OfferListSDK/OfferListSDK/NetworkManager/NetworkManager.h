//
//  NetworkManager.h
//  OfferListSDK
//
//  Created by Sharmin Khan on 23.11.20.
//

#import <Foundation/Foundation.h>
#import "Offer.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetworkManager : NSObject

@property NSString *appId;
@property NSString *userId;
@property NSString *securityToken;

-(void) loadOffers:(NSString *)appID userID:(NSString *) userId token:(NSString *) token completionHandler: (void (^)(NSArray<Offer *> * offers, NSError *error)) completionHandler;
@end

NS_ASSUME_NONNULL_END
