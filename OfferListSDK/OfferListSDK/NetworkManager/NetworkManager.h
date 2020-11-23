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
@property NSString *baseUrl;
@property NSString *appId;
@property NSString *userId;
@property NSString *securityToken;
@property NSString *ip;
@property NSString *locale;
@property NSString *timestamp;
@property NSString *offerTypes;
@property NSString *version;
@property NSString *apple_idfa;
@property NSString *idfaEnabled;
@property NSString *apiKey;
@property NSString *gatheredParameters;
@property NSString *hashKey;
@property NSString *url;

-(NSArray<Offer *> *) loadData:(NSString *)aID userID:(NSString *) uId token:(NSString *) token completionHandler: (void (^)(NSArray<Offer *> * offers)) completionHandler;
@end

NS_ASSUME_NONNULL_END
