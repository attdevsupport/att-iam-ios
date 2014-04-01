//
//  MessageCell.h
//  TestSampleApp
//
//  Created by John O'Dowd on 1/13/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageBodyLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

@end
