//
//  ViewController.m
//  DbTest
//
//  Created by Sandip Saha on 07/04/14.
//  Copyright (c) 2014 Sandip Saha. All rights reserved.
//

#import "ViewController.h"
#import "listViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#define APP_KEY  @"t4hrxj237xhxlva"
#define APP_SECRET  @"3lb335cnfmmhxvo"


@interface ViewController ()<DBRestClientDelegate>

@property (strong , nonatomic) DBRestClient *restClient;
@property (nonatomic) BOOL isLinked;
@property (strong , nonatomic) NSMutableArray *dbArray;

@end

@implementation ViewController

@synthesize restClient,isLinked, dbArray;

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(IBAction)linkDropBox:(id)sender
{
    [self didPressLink];
}

-(void)didPressLink
{
    if (![[DBSession sharedSession] isLinked]){
        [[DBSession sharedSession] linkFromController:self];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Link to your account exists, you can access your files directly." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(IBAction)getFiles:(id)sender
{
    if ([[DBSession sharedSession] isLinked])
    {
        [self performSegueWithIdentifier:@"list" sender:restClient];
    }
    else
    {
        UIAlertView *alertToLinkDropBox=[[UIAlertView alloc]initWithTitle:@"ERROR" message:@"first create a session by by linking to your dropbox account" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [alertToLinkDropBox show];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"list"])
    {
       // [segue.destinationViewController performSelector:@selector(setDataSourceWithObjects:) withObject:dbArray];
        [segue.destinationViewController performSelector:@selector(setDropboxSession:) withObject:[DBSession sharedSession]];
    }
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
