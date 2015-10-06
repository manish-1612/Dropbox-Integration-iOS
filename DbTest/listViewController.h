//
//  listViewController.h
//  DbTestUpload
//
//  Created by Sandip Saha on 07/04/14.
//  Copyright (c) 2014 Sandip Saha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface listViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *dbDataTableVIew;
@property (weak, nonatomic) IBOutlet UIButton *backNavigator;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

-(void)setDropboxSession:(DBSession *)session;


@end
