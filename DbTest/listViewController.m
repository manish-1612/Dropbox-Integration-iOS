//
//  listViewController.m
//  DbTestUpload
//
//  Created by Sandip Saha on 07/04/14.
//  Copyright (c) 2014 Sandip Saha. All rights reserved.
//

#import "listViewController.h"

@interface listViewController ()<UITableViewDataSource, UITableViewDelegate , DBRestClientDelegate>
@property (strong , nonatomic) NSMutableArray *dbArray;
@property (strong , nonatomic ) DBRestClient *restClient;
@property (strong, nonatomic) NSMutableArray *apiCallArray;
@property (strong , nonatomic) NSMutableArray *backButtonTitleArray;


@end

@implementation listViewController
@synthesize dbDataTableVIew;
@synthesize backButton;
@synthesize dbArray;
@synthesize restClient;
@synthesize apiCallArray;
@synthesize backNavigator;
@synthesize titleLabel;
@synthesize backButtonTitleArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dbDataTableVIew.delegate=self;
    dbDataTableVIew.dataSource=self;
    titleLabel.text=@"Dropbox";
    backButtonTitleArray=[[NSMutableArray alloc]initWithCapacity:0];
    apiCallArray = [[NSMutableArray alloc]initWithCapacity:0];
    
    [self loadDataFromDropBox];

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

-(void)setDropboxSession:(DBSession *)session
{
    DBSession *currentSession=[[DBSession alloc]init];
    currentSession=session;
    
    [DBSession setSharedSession:currentSession];
    
    NSLog(@"link : %i", currentSession.isLinked);
}
-(void)loadDataFromDropBox
{
    if ([[DBSession sharedSession] isLinked]) {
        [[self restClient] loadMetadata:@"/"];
    }
    else
    {
        UIAlertView *alertToLinkDropBox=[[UIAlertView alloc]initWithTitle:@"ERROR" message:@"first create a session by by linking to your dropbox account" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [alertToLinkDropBox show];
    }
}

-(NSString *)makeApi :(NSString *)apiString
{
    [apiCallArray addObject:apiString];
    
    //NSString *title=[self checkLabelForWhiteSpace:titleLabel];
    
    //[backButtonTitleArray addObject:title];
    
    
    NSString *apiToSend=@"";
    for (NSString *api in apiCallArray)
    {
        apiToSend = [apiToSend stringByAppendingString:[NSString stringWithFormat:@"/%@",api]];
    }
    
    //[backButton setTitle:title forState:UIControlStateNormal];
    
    //CGSize size = [apiString sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f]}];
    
    //[backButton setFrame:CGRectMake(backButton.frame.origin.x,backButton.frame.origin.y,size.width+6, size.height+26)];
    [backButton addTarget:self action:@selector(performBackNavigation) forControlEvents:UIControlEventTouchUpInside];
    
    [backNavigator addTarget:self action:@selector(performBackNavigation) forControlEvents:UIControlEventTouchUpInside];
    titleLabel.text=apiString;
    
    return apiToSend;
}

-(void)performBackNavigation
{    
    if (apiCallArray.count > 1)
    {
        NSString *lastApi=[apiCallArray lastObject];
        NSString *pageTitle=[apiCallArray objectAtIndex:apiCallArray.count-2];
        
        [apiCallArray removeObject:lastApi];


        NSString *apiToSend=@"";
        for (NSString *api in apiCallArray)
        {
            apiToSend = [apiToSend stringByAppendingString:[NSString stringWithFormat:@"/%@",api]];
        }
        
        titleLabel.text=pageTitle;

        //[backButton setTitle:[backButtonTitleArray objectAtIndex:backButtonTitleArray.count-2] forState:UIControlStateNormal];
        
        //CGSize size = [pageTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f]}];
        
        //[backButton setFrame:CGRectMake(backButton.frame.origin.x,backButton.frame.origin.y,size.width+10, size.height+26)];
        //[backButtonTitleArray removeObjectAtIndex:backButtonTitleArray.count-1];

        [[self restClient] loadMetadata:apiToSend];
    }
    else if(apiCallArray.count==0)
    {
        [backButton removeTarget:self action:@selector(performBackNavigation) forControlEvents:UIControlEventTouchUpInside];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        //[backButton setTitle:@"Back" forState:UIControlStateNormal];
        titleLabel.text=@"Dropbox";
        
        NSString *lastApi=[apiCallArray lastObject];
        [apiCallArray removeObject:lastApi];
        
        NSString *apiToSend=@"";
        
        for (NSString *api in apiCallArray)
        {
            apiToSend = [apiToSend stringByAppendingString:[NSString stringWithFormat:@"/%@",api]];
        }
        
        [[self restClient] loadMetadata:apiToSend];

        //CGSize size = [@"Back" sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f]}];
        
        //[backButton setFrame:CGRectMake(backButton.frame.origin.x,backButton.frame.origin.y,size.width+10, size.height+26)];
        
        [apiCallArray removeAllObjects];
        //[backButtonTitleArray removeObjectAtIndex:backButtonTitleArray.count-1];
    }
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory)
    {
        dbArray=[[NSMutableArray alloc]initWithCapacity:0];
        
        for (DBMetadata *file in metadata.contents)
        {
            [dbArray addObject:file];
        }
        
        [self.dbDataTableVIew reloadData];
        //[self performSegueWithIdentifier:@"list" sender:restClient];
    }
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"Error loading metadata: %@", error);
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dbArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.imageView.image=nil;
    // Configure the cell...
    cell.textLabel.text=((DBMetadata*)[dbArray objectAtIndex:indexPath.row]).filename;
    
    
    NSLog(@"data icon : %@",((DBMetadata*)[dbArray objectAtIndex:indexPath.row]).icon);
  
    
    if (((DBMetadata*)[dbArray objectAtIndex:indexPath.row]).isDirectory)
    {
        cell.imageView.image=[UIImage imageNamed:@"folder.png"];
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (((DBMetadata *)[dbArray objectAtIndex:indexPath.row]).isDirectory)
    {
        NSString *api = [self makeApi:((DBMetadata *)[dbArray objectAtIndex:indexPath.row]).filename];

        [[self restClient] loadMetadata:api];
    }
    else
    {
        NSString *api =((DBMetadata *)[dbArray objectAtIndex:indexPath.row]).filename;
        
        NSString *apiToSend=@"";
        
        for (NSString *api in apiCallArray)
        {
            apiToSend = [apiToSend stringByAppendingString:[NSString stringWithFormat:@"/%@",api]];
        }
        
        NSLog(@"the api is :%@", apiToSend);
        
        NSString *filename = [api lastPathComponent];
        NSString *destPath = [apiToSend stringByAppendingPathComponent:filename];
        destPath=[@"/" stringByAppendingString:destPath];
        
        NSLog(@"dst path : %@", destPath);
        NSLog(@"file name : %@", filename);
        
        /*NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [searchPaths objectAtIndex:0];
        */
        NSString *tmpDir = NSTemporaryDirectory();
        NSString *tmpFileName = [tmpDir stringByAppendingPathComponent:filename];
        NSLog(@"temporary directory, %@", tmpDir);
        
        [[self restClient] loadFile:destPath intoPath:tmpFileName];
    }
}


- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath
{
    NSLog(@"File loaded into path: %@", localPath);
    [self uploadFileFromPath:localPath];
}

-(void)uploadFileFromPath:(NSString *)path
{
    NSLog(@"path : %@", path);
    
    NSData *statementData=[[NSData alloc]initWithContentsOfFile:path];

    NSLog(@"data recvd: %@", statementData);
    
    //selector to remove file from app sandbox after file s uploaded successfully in Doc and Do app
    //[self performSelector:@selector(removeFileAtPath:) withObject:path afterDelay:5.0];
}


-(void)removeFileAtPath:(NSString *)path
{
    NSLog(@"path : %@", path);
    // you need to write a function to get to that directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path])
    {
        NSError *error;
        if (![fileManager removeItemAtPath:path error:&error])
        {
            NSLog(@"Error removing file: %@", error);
        }
        else
        {
            NSLog(@"file removed successfully");
        }
    }
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error
{
    UIAlertView *alertForNoFile=[[UIAlertView alloc]initWithTitle:@"ERROR" message:@"error loading file" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [alertForNoFile show];
}

-(NSString *)checkLabelForWhiteSpace:(UILabel *)label
{
    int j = -1;
    
    if (label.text.length>0)
    {
        for (int i =0; i<label.text.length;i++)
        {
            char character= [label.text characterAtIndex:i];
            if (character != ' ')
            {
                j=i;
                break;
            }
        }
    }
    
    if (j== -1)
    {
        j=(int)label.text.length;
    }
    
    NSString *text=[label.text substringFromIndex:j];
    
    return text;
}




@end
