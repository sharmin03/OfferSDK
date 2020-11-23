//
//  OffersViewController.m
//  OfferListSDK
//
//  Created by Sharmin Khan on 23.11.20.
//

#import "OffersViewController.h"
#import "Offer.h"

@interface OffersViewController ()

@end


@implementation OffersViewController

NSString *cellIdentifier = @"CellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Offers";
    self.tableView.tableFooterView = UITableView.new;
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:cellIdentifier];
    [self.tableView reloadData];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style: UIBarButtonItemStylePlain target:self action:@selector(cancelButtonTap)];
    self.navigationItem.rightBarButtonItem = cancelButton;
}

-(void) cancelButtonTap {
    [self handleDismissVC];
}

-(void) handleDismissVC {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.delegate dismissOffersVC];
}

-(UIImage *)getImageFromUrl:(NSString *)link {

    NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:link]];
    return [UIImage imageWithData: imageData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.offers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    Offer *offer = self.offers[indexPath.row];
    cell.textLabel.text = offer.title;
    dispatch_async(dispatch_get_main_queue(), ^{
        cell.imageView.image = [self getImageFromUrl:offer.imageUrl];
    });
    //TODO: - make this asynchronous
//    cell.imageView.image = [self getImageFromUrl:offer.imageUrl];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self handleDismissVC];
}
@end

