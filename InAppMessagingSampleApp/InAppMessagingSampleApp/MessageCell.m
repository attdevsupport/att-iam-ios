//
//  MessageCell.m
//  TestSampleApp
//
//  Created by John O'Dowd on 1/13/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
//    if () {
//        <#statements#>
//    }
//    self.dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
//    self.addressLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
//    self.messageBodyLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
