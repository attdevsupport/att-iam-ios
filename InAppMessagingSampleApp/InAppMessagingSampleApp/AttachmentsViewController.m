//
//  AttachmentsViewController.m
//  InAppMessagingSampleApp
//
//  Created by John O'Dowd on 1/28/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import "AttachmentsViewController.h"
#import "ImageCell.h"
#import "IAMMessage.h"
#import "IAMManager.h"
#import "IAMMessageContentRequest.h"
#import "MMSContent.h"
#import "ImageViewController.h"
#import "TextViewController.h"
#import "TitleView.h"

@interface AttachmentsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSMutableArray *imageAttachments;
@property (nonatomic, strong) NSMutableArray *textAttachments;
@end

@implementation AttachmentsViewController

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
    self.textAttachments = [[NSMutableArray alloc] init];
    self.imageAttachments = [[NSMutableArray alloc] init];
     
    NSArray *mmsContent = self.message.mmsContent;
    for (int i = 0; i < [mmsContent count]; i++) {
        IAMMessageContentRequest *contentRequest = [[IAMMessageContentRequest alloc] init];
        MMSContent *content = mmsContent[i];
        NSArray *pathComponents = [content.path componentsSeparatedByString:@"/"];
        NSString *partNumber = [pathComponents lastObject];
        contentRequest.messageId = self.message.messageId;
        contentRequest.partNumber = [partNumber integerValue];
        [self.iamManager sendAsynchronous:contentRequest
              success:^(id result) {
                  if ([result isKindOfClass:[UIImage class]]) {
                      
                      [self.imageAttachments addObject:(UIImage *)result];
                  } else if ([result isKindOfClass:[NSString class]]){
                      [self.textAttachments addObject:(NSString *)result];
                  }
                  [self.collectionView reloadData];
              } failure:^(NSError *error) {
                  NSLog(@"IAMMessageContentRequest: (%ld) %@", (long)error.code, error.localizedDescription);
                  
                  self.tempCountOfImages--;
                  if (self.tempCountOfImages < 0) {
                      self.tempCountOfImages = 0;
                  }
                  
                  
              }];
    }
    
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pushImageVCFromAttachmentsVC"]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        UIImage *image = self.imageAttachments[indexPath.row];
        ImageViewController *imageVC = (ImageViewController *)segue.destinationViewController;
        imageVC.image = image;
    }
    else if ([segue.identifier isEqualToString:@"pushTextVCFromAttachmentsVC"]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        NSString *text = self.textAttachments[indexPath.row];
        TextViewController *textVC = (TextViewController *)segue.destinationViewController;
        textVC.text = text;
    }
}


#pragma mark - UICollectionView

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section{
    
    if (section == 0 && self.tempCountOfImages > 0) {
        
        if ([self.imageAttachments count] > 0) {
            return [self.imageAttachments count];
        }
        return self.tempCountOfImages;
    }
    else {
        
        if ([self.textAttachments count] > 0) {
            
            return [self.textAttachments count];
        }
        return self.tempCountOfTextFiles;
    }
   
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger typesOfAttachments = 0;
    if (self.tempCountOfImages > 0) {
       
        typesOfAttachments++;
    }
    if (self.tempCountOfTextFiles > 0) {
        typesOfAttachments++;
    }
    return typesOfAttachments;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    TitleView *titleView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        titleView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TitleView" forIndexPath:indexPath];
        if (indexPath.section == 0 && self.tempCountOfImages != 0) {
            
            titleView.titleLabel.text = @"Images";
        }
        else {
            titleView.titleLabel.text = @"Text Files";
        }
    }
    return titleView;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    if (indexPath.section == 0 && self.tempCountOfImages > 0) {
        // Images
        if (self.imageAttachments.count > indexPath.row ) {
            UIImage *image = self.imageAttachments[indexPath.row];
           
            [cell.imageView setImage:image];
        }
        else {
            UIImage *tempImage = [UIImage imageNamed:@"Placeholder"];
            [cell.imageView setImage:tempImage];
        }
    }
    else {
        // Text
        [cell.imageView setImage:[UIImage imageNamed:@"textFileImage"]];
    }
    
    
    return cell;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && self.tempCountOfImages > 0) {
    
        [self performSegueWithIdentifier:@"pushImageVCFromAttachmentsVC" sender:indexPath];
        
    }
    else {
        [self performSegueWithIdentifier:@"pushTextVCFromAttachmentsVC" sender:indexPath];
    }
}

@end
