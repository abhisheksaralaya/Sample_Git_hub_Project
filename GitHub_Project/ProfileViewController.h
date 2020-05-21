//
//  ProfileViewController.h
//  GitHub_Project
//
//  Created by Apple on 20/05/20.
//  Copyright © 2020 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProfileViewController : UIViewController

@end

@interface RepoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblNoOfStars;
@property (weak, nonatomic) IBOutlet UILabel *lblNoOfForks;
@end

NS_ASSUME_NONNULL_END
