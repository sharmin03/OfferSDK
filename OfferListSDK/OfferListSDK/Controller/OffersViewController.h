//
//  OffersViewController.h
//  OfferListSDK
//
//  Created by Sharmin Khan on 23.11.20.
//

#import "Offer.h"
#import <UIKit/UIKit.h>

@protocol OffersViewControllerDelegate
- (void)dismissOffersVC;
@end

@interface OffersViewController : UITableViewController
@property (strong, nonatomic) NSArray<Offer *> *offers;
@property(nonatomic, weak)id <OffersViewControllerDelegate> delegate;
@end
