//
//  Offer.h
//  OfferListSDK
//
//  Created by Sharmin Khan on 23.11.20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Offer Model

@interface Offer : NSObject
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *imageUrl;
@end

NS_ASSUME_NONNULL_END
