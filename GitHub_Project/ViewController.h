//
//  ViewController.h
//  GitHub_Project
//
//  Created by Apple on 19/05/20.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController


@end

@interface GitUserCell : UITableViewCell 
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblRepo;

@end
