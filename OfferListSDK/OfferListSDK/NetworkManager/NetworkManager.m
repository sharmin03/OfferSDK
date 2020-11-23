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
//#import <NSHash/NSString+NSHash.h>
//#import <NSHash/NSData+NSHash.h>
#import <CommonCrypto/CommonDigest.h>

@implementation NetworkManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Initializing the static query parameters
        self.baseUrl = @"https://api.fyber.com/feed/v1/offers.json?";
        self.ip = [NSString stringWithFormat:@"%s%s", "&ip=", "109.235.143.113"];
        self.locale = [NSString stringWithFormat:@"%s%s", "&locale=", "de"];
        self.timestamp = [NSString stringWithFormat:@"%s%@", "&timestamp=", [NSString stringWithFormat:@"%lu", (long)[[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] integerValue]]];
        self.offerTypes = [NSString stringWithFormat:@"%s%s", "&offer_types=", "112"];
        self.version = [NSString stringWithFormat:@"%s%@", "&phone_version=", [[UIDevice currentDevice] systemVersion]];
        self.apple_idfa = [NSString stringWithFormat:@"%s%@", "&apple_idfa=", [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
        self.idfaEnabled = [NSString stringWithFormat:@"%s%s", "&apple_idfa_tracking_enabled=", "true"];
    }
    return self;
}


-(void) loadData:(NSString *)aID userID:(NSString *) uId token:(NSString *) token completionHandler: (void (^)(NSArray<Offer *> * offers)) completionHandler {
    
    // getting all the request parameters in correct form
    NSMutableArray<Offer *> *offers = NSMutableArray.new;
    self.appId = [NSString stringWithFormat:@"%s%@", "appid=", aID];
    self.userId = [NSString stringWithFormat:@"%s%@", "&uid=", uId];
    self.securityToken = [NSString stringWithFormat:@"%@", token];
    self.apiKey = [NSString stringWithFormat:@"%@", token];
    
    // Gathering the parameters in alphabetical order to calculate the hask key
    self.gatheredParameters = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@", self.appId, self.apple_idfa, self.idfaEnabled, self.ip, self.locale, self.offerTypes, self.version, self.timestamp, self.userId, self.apiKey ];
    
    //Calculating the Hash key
//    self.hashKey = [NSString stringWithFormat:@"%s%@", "&hashkey=", [self.gatheredParameters SHA1]];
    self.hashKey = [NSString stringWithFormat:@"%s%@", "&hashkey=", [self returnHashWithSHA1:self.gatheredParameters]];
    
    //Creating a url with all the paramters after hash key calculation
    self.url = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@", self.baseUrl, self.appId, self.userId, self.ip, self.locale, self.timestamp, self.offerTypes, self.version, self.apple_idfa, self.idfaEnabled, self.hashKey ];

    // HTTP get request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:self.url]];
    
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
//        NSString *expectedSignature = [responseBodyWithApiKey SHA1];
    
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
            NSArray<Offer *> *empty = [NSArray new];
            completionHandler(empty);
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
