//
//  ConversationCell.h
//  InAppMessagingSampleApp
//
//  Created by John O'Dowd on 1/24/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversationCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *messageBodyLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIButton *attachmentsButton;
@end
