//
//  NetworkManager.m
//  OfferListSDK
//
//  Created by Sharmin Khan on 23.11.20.
//

#import "NetworkManager.h"
#import <UIKit/UIKit.h>
#import "Offer.h"
#import <AdSupport/ASIdentifierManager.h>
#import <CommonCrypto/CommonDigest.h>

@implementation NetworkManager

NSString *baseUrl;
NSString *ip;
NSString *locale;
NSString *timestamp;
NSString *offerTypes;
NSString *version;
NSString *apple_idfa;
NSString *idfaEnabled;
NSString *apiKey;
NSString *gatheredParameters;
NSString *hashKey;
NSString *url;

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Initializing the static query parameters
        baseUrl = @"https://api.fyber.com/feed/v1/offers.json?";
        ip = [NSString stringWithFormat:@"%s%s", "&ip=", "109.235.143.113"];
        locale = [NSString stringWithFormat:@"%s%s", "&locale=", "de"];
        timestamp = [NSString stringWithFormat:@"%s%@", "&timestamp=", [NSString stringWithFormat:@"%lu", (long)[[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] integerValue]]];
        offerTypes = [NSString stringWithFormat:@"%s%s", "&offer_types=", "112"];
        version = [NSString stringWithFormat:@"%s%@", "&phone_version=", [[UIDevice currentDevice] systemVersion]];
        apple_idfa = [NSString stringWithFormat:@"%s%@", "&apple_idfa=", [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
        idfaEnabled = [NSString stringWithFormat:@"%s%s", "&apple_idfa_tracking_enabled=", "true"];
    }
    return self;
}


-(void) loadOffers:(NSString *)appID userID:(NSString *) userId token:(NSString *) token completionHandler: (void (^)(NSArray<Offer *> * offers)) completionHandler {
    
    // getting all the request parameters in correct form
    NSMutableArray<Offer *> *offers = NSMutableArray.new;
    self.appId = [NSString stringWithFormat:@"%s%@", "appid=", appID];
    self.userId = [NSString stringWithFormat:@"%s%@", "&uid=", userId];
    self.securityToken = [NSString stringWithFormat:@"%@", token];
    apiKey = [NSString stringWithFormat:@"%@", token];
    
    // Gathering the parameters in alphabetical order to calculate the hask key
    gatheredParameters = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@", self.appId, apple_idfa, idfaEnabled, ip, locale, offerTypes, version, timestamp, self.userId, apiKey ];
    
    //Calculating the Hash key
//    self.hashKey = [NSString stringWithFormat:@"%s%@", "&hashkey=", [self.gatheredParameters SHA1]];
    hashKey = [NSString stringWithFormat:@"%s%@", "&hashkey=", [self returnHashWithSHA1:gatheredParameters]];
    
    //Creating a url with all the paramters after hash key calculation
    url = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@", baseUrl, self.appId, self.userId, ip, locale, timestamp, offerTypes, version, apple_idfa, idfaEnabled, hashKey ];

    // HTTP get request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {

        //Getting the response signature from the response header
        NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
        NSString *responseSignature = headers[@"x-sponsorpay-response-signature"];
    
        //Getting the response body in string format to check the signature
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        //Concatenating the response body with API Key
        NSString *responseBodyWithApiKey = [NSString stringWithFormat:@"%@%@", str, @"1c915e3b5d42d05136185030892fbb846c278927"];
        
        //Hashing the responseBodyWithApiKey with SHA1 becuase it is the expectedSignature
        NSString *expectedSignature = [self returnHashWithSHA1:responseBodyWithApiKey];
        NSLog(@"response = %@", responseSignature);
        NSLog(@"expected = %@", expectedSignature);
        // Comparing the response signature with the calculated expected signature to check if the data is corrupted or not.
//        if ([responseSignature isEqualToString:expectedSignature]) {
//        if(YES) {
//            NSLog(@"Data recieved from the API is not corrupted.");
//
//        } else {
//            NSLog(@"Data recieved from the API is corrupted!!!");
//        }
        NSError *err;
        
        //Converting the data to Dictionary
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        
        if (err) {
            NSLog(@"Failed to serialoze JSON: %@",err);
//            NSArray<Offer *> *empty = [NSArray new];
            completionHandler(nil,err);
            return;
        }

        NSDictionary *offersJSON = json[@"offers"];
        
        //Appening all the offers from Dictionary to an array of Offer objects
        for (NSDictionary *offer in offersJSON) {
            Offer *o = Offer.new;
            o.title = offer[@"title"];
            o.imageUrl = offer[@"thumbnail"][@"lowres"];
            [offers addObject:o];
        }
        //Completion handler to pass the offers when this function is called
        completionHandler(offers);
        
    }] resume];

}


-(NSString*) returnHashWithSHA1:(NSString*)inputText {
    const char *cstr = [inputText cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:inputText.length];

    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(data.bytes, data.length, digest);

    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

@end
