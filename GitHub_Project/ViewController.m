//
//  ViewController.m
//  GitHub_Project
//
//  Created by Apple on 19/05/20.
//  Copyright © 2020 Apple. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@interface ViewController () < UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tblSearchResult;

@end

@implementation ViewController
NSMutableArray *arrItems;
NSArray<NSCache *> *arrImageCache;
NSMutableArray *arrImgLoaded;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchBar.delegate = self;
    self.tblSearchResult.dataSource = self;
    self.tblSearchResult.delegate = self;
}

- (void)connect:(NSString *)urlString completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {
    NSError *error;

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];

    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];

    [request setHTTPMethod:@"GET"];
//    NSDictionary *mapData = [[NSDictionary alloc] initWithObjectsAndKeys: @"TEST IOS", @"name",
//                         @"IOS TYPE", @"typemap",
//                         nil];
//    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&error];
//    [request setHTTPBody:postData];


    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        completionHandler(data, response ,error);
    }];

    [postDataTask resume];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] > 0) {
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SearchDB"];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"login contains[c] %@",searchText]];
        NSArray *arrSearchData = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
        BOOL isPresentInDB = false;
        NSLog(@"arrdata%@",arrSearchData);
//        NSLog(@"arrdata%@",[arrSearchData count]);
        arrItems = [[NSMutableArray alloc]init];
        
        for (int i = 0; i < arrSearchData.count; i ++) {
            NSLog(@"qwert%@",[[arrSearchData objectAtIndex:i] valueForKey:@"id"]);
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[[arrSearchData objectAtIndex:i] valueForKey:@"avatar_url"] ,@"avatar_url",[[arrSearchData objectAtIndex:i] valueForKey:@"events_url"] ,@"events_url",[[arrSearchData objectAtIndex:i] valueForKey:@"followers_url"] ,@"followers_url",[[arrSearchData objectAtIndex:i] valueForKey:@"following_url"] ,@"following_url",[[arrSearchData objectAtIndex:i] valueForKey:@"gists_url"] ,@"gists_url",[[arrSearchData objectAtIndex:i] valueForKey:@"gravatar_id"] ,@"gravatar_id",[[arrSearchData objectAtIndex:i] valueForKey:@"html_url"] ,@"html_url",[[arrSearchData objectAtIndex:i] valueForKey:@"id"] ,@"id",[[arrSearchData objectAtIndex:i] valueForKey:@"login"] ,@"login",[[arrSearchData objectAtIndex:i] valueForKey:@"node_id"] ,@"node_id",[[arrSearchData objectAtIndex:i] valueForKey:@"organizations_url"] ,@"organizations_url",[[arrSearchData objectAtIndex:i] valueForKey:@"received_events_url"] ,@"received_events_url",[[arrSearchData objectAtIndex:i] valueForKey:@"repos_url"] ,@"repos_url",[[arrSearchData objectAtIndex:i] valueForKey:@"score"] ,@"score",[[arrSearchData objectAtIndex:i] valueForKey:@"site_admin"] ,@"site_admin",[[arrSearchData objectAtIndex:i] valueForKey:@"starred_url"] ,@"starred_url",[[arrSearchData objectAtIndex:i] valueForKey:@"subscriptions_url"] ,@"subscriptions_url",[[arrSearchData objectAtIndex:i] valueForKey:@"type"] ,@"type",[[arrSearchData objectAtIndex:i] valueForKey:@"url"] ,@"url", nil];
            
            isPresentInDB = true;
            NSLog(@"dict%@",dict);
            [arrItems addObject:dict];
            if (i == arrSearchData.count - 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                [self.tblSearchResult reloadData];
                });
            }
        }
        NSLog(@"arrItemssss%@",arrItems);
//        for (NSDictionary *diction in arrSearchData) {
//            if ([[diction objectForKey:@"login"] localizedCaseInsensitiveContainsString:searchText]) {
//                isPresentInDB = true;
//                [arrItems addObject:diction];
//            }
//        }
        if (isPresentInDB == true) {
            for (NSUInteger i = 0; i < arrSearchData.count; i ++) {
                if (![[[arrSearchData objectAtIndex:i] valueForKey:@"searchText"] isEqualToString:searchText]) {
                    isPresentInDB = false;
                    i = arrSearchData.count;
                }
            }
        }
        
        
        if (isPresentInDB == false) {
            
            [self connect:[NSString stringWithFormat:@"https://api.github.com/search/users?q=%@",searchText] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSHTTPURLResponse *resp = (NSHTTPURLResponse*)response;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!error && (resp.statusCode == 201 || resp.statusCode == 200)) {
                        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                        NSArray *arr = [[NSArray alloc] initWithArray:[dataDict objectForKey:@"items"]];
                        NSLog(@"ItemsDict=%@",arr);
                        for (NSDictionary * dict in arr) {
                            if ([[dict objectForKey:@"login"] localizedCaseInsensitiveContainsString:searchText]) {
                                BOOL isPresent = false;
                                for (NSDictionary * dict1 in arrItems) {
                                    if ([dict1 objectForKey:@"id"] == [dict objectForKey:@"id"]) {
                                        isPresent = true;
                                    }
                                }
                                if (isPresent == false) {
                                    NSManagedObjectContext *context = [self managedObjectContext];
                                    
                                    // Create a new managed object
                                    NSManagedObject *searchData = [NSEntityDescription insertNewObjectForEntityForName:@"SearchDB" inManagedObjectContext:context];
                                    [searchData setValue:[dict objectForKey:@"avatar_url"] forKey:@"avatar_url"];
                                    [searchData setValue:[dict objectForKey:@"events_url"] forKey:@"events_url"];
                                    [searchData setValue:[dict objectForKey:@"followers_url"] forKey:@"followers_url"];
                                    [searchData setValue:[dict objectForKey:@"following_url"] forKey:@"following_url"];
                                    [searchData setValue:[dict objectForKey:@"gists_url"] forKey:@"gists_url"];
                                    [searchData setValue:[dict objectForKey:@"gravatar_id"] forKey:@"gravatar_id"];
                                    [searchData setValue:[dict objectForKey:@"html_url"] forKey:@"html_url"];
                                    [searchData setValue:[dict objectForKey:@"id"] forKey:@"id"];
                                    [searchData setValue:[dict objectForKey:@"login"] forKey:@"login"];
                                    [searchData setValue:[dict objectForKey:@"node_id"] forKey:@"node_id"];
                                    [searchData setValue:[dict objectForKey:@"organizations_url"] forKey:@"organizations_url"];
                                    [searchData setValue:[dict objectForKey:@"received_events_url"] forKey:@"received_events_url"];
                                    [searchData setValue:[dict objectForKey:@"repos_url"] forKey:@"repos_url"];
                                    [searchData setValue:[dict objectForKey:@"score"] forKey:@"score"];
                                    [searchData setValue:[dict objectForKey:@"site_admin"] forKey:@"site_admin"];
                                    [searchData setValue:[dict objectForKey:@"starred_url"] forKey:@"starred_url"];
                                    [searchData setValue:[dict objectForKey:@"subscriptions_url"] forKey:@"subscriptions_url"];
                                    [searchData setValue:[dict objectForKey:@"type"] forKey:@"type"];
                                    [searchData setValue:[dict objectForKey:@"url"] forKey:@"url"];
                                    [searchData setValue:searchText forKey:@"searchText"];
                                    NSError *error = nil;
                                    // Save the object to persistent store
                                    if (![context save:&error]) {
                                        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                                    }
                                    [arrItems addObject:dict];
                                }
                            }
                        }
                        [self.tblSearchResult reloadData];
                        NSLog(@"arrItems%@",arrItems);
                    }
                });
            }];
        }
    }
}


#pragma mark - UITableviewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    GitUserCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    NSDictionary *dict = [arrItems objectAtIndex:indexPath.row];
    NSString *imgUrlStr = [dict objectForKey:@"avatar_url"];
    if ([arrImgLoaded objectAtIndex:indexPath.row] != [NSNumber numberWithInteger: indexPath.row]) {
        UIImage *image = [[arrImageCache objectAtIndex:indexPath.row] objectForKey:imgUrlStr];
        if (image) {
            cell.imgAvatar.image=image;
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSURL *url = [NSURL URLWithString:[imgUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (data) {
//                        NSData *imgData = [NSData dataWithContentsOfURL:url];
                        UIImage *image = [[UIImage alloc] initWithData:data];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (image) {
                                cell.imgAvatar.image=image;
                            } else {
                                cell.imgAvatar.image = [UIImage imageNamed:@"placeholder.png"];
                                
                            }
                            NSCache *cache;
                            [cache setObject:cell.imgAvatar.image forKey:imgUrlStr];
                            [arrImageCache arrayByAddingObject: cache];
//                            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        });
                    }
                }];
                [task resume];
            });
        }
        [arrImgLoaded addObject: [NSNumber numberWithInteger:indexPath.row]];
    }
    cell.lblUserName.text = [dict objectForKey:@"login"];
//    cell.lblRepo.text =
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"RepoDB"];
//    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id contains[c] %@",[dict objectForKey:@"id"]]];
//    NSArray *arrSearchData = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
//    for (int i = 0; i < arrSearchData.count; i ++) {
//        NSLog(@"qwert%@",[[arrSearchData objectAtIndex:i] valueForKey:@"id"]);
//        NSDictionary *dict = NSJSONSerialization JSONObjectWithData: options:<#(NSJSONReadingOptions)#> error:<#(NSError *__autoreleasing  _Nullable * _Nullable)#>
//
//        NSLog(@"dict%@",dict);
//        [arrItems addObject:dict];
//        if (i == arrSearchData.count - 1) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tblSearchResult reloadData];
//            });
//        }
//    }
    [self connect:[dict objectForKey:@"repos_url"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSHTTPURLResponse *resp = (NSHTTPURLResponse*)response;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!error && (resp.statusCode == 201 || resp.statusCode == 200)) {
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"arr%@",arr);
            
            cell.lblRepo.text = [NSString stringWithFormat: @"%lu",arr.count];
        } else {
            cell.lblRepo.text = @"NaN";
        }
    });
    }];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrItems.count;
}

#pragma mark - UITableviewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Coredata

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
//    id delegate = [[UIApplication sharedApplication] delegate];
    
//    if ([delegate performSelector:@selector(managedObjectContext)]) {
//        context = delegate.
//    }
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    context = appDelegate.persistentContainer.viewContext;
    return context;
}


@end


@implementation GitUserCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
