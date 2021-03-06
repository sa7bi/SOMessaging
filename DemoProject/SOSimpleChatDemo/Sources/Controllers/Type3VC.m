//
//  WithUserImagesVC.m
//  SOSimpleChatDemo
//
// Created by : arturdev
// Copyright (c) 2014 SocialObjects Software. All rights reserved.
//

#import "Type3VC.h"
#import "ContentManager.h"

@interface Type3VC ()

@property (strong, nonatomic) NSMutableArray *dataSource;

@property (strong, nonatomic) UIImage *myImage;
@property (strong, nonatomic) UIImage *partnerImage;

@end

@implementation Type3VC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myImage      = [UIImage imageNamed:@"arturdev.jpg"];
    self.partnerImage = [UIImage imageNamed:@"jobs.jpg"];
 
//--------------------------------------------------
//         Customizing input view
//--------------------------------------------------
    self.inputView.textInitialHeight = 45;
    self.inputView.textView.font = [UIFont systemFontOfSize:17];
    
    // Apply changes
    [self.inputView adjustInputView];
//--------------------------------------------------
    
    [self loadMessages];
}

- (void)loadMessages
{
    self.dataSource = [[[ContentManager sharedManager] generateConversation] mutableCopy];
}

#pragma mark - SOMessaging data source
- (NSMutableArray *)messages
{
    return self.dataSource;
}

- (CGFloat)heightForMessageForIndex:(NSInteger)index
{
    CGFloat height = [super heightForMessageForIndex:index];
    
    height += 15; // Increasing message height for more 15pts
    
    return height;
}

- (void)configureMessageCell:(SOMessageCell *)cell forMessageAtIndex:(NSInteger)index
{
    SOMessage *message = self.dataSource[index];
    
    // Adjusting content for 4pt. (In this demo the width of bubble's tail is 8pt)
    if (!message.fromMe) {
        cell.contentInsets = UIEdgeInsetsMake(0, 4.0f, 0, 0); //Move content for 4 pt. to right
    } else {
        cell.contentInsets = UIEdgeInsetsMake(0, 0, 0, 4.0f); //Move content for 4 pt. to left
    }
    
    cell.textView.textColor = [UIColor blackColor];
    
    cell.userImageView.layer.cornerRadius = 3;
    
    // Fix user image position on top or bottom.
    cell.userImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    // Setting user images
    cell.userImage = message.fromMe ? self.myImage : self.partnerImage;
    
    // Disabling left drag functionality
    cell.panGesture.enabled = NO;
 
    
//-----------------------------------------------//
//     Adding datetime label under balloon
//-----------------------------------------------//
    UILabel *label = [self generateLabelForCell:cell];
    
    UILabel *existingLabel = [[cell.contentView.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag == %d",label.tag]] lastObject];;
    [existingLabel removeFromSuperview];
    
    [cell.contentView addSubview:label];
//-----------------------------------------------//
}

- (UILabel *)generateLabelForCell:(SOMessageCell *)cell
{
    SOMessage *message = cell.message;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:8];
    label.textColor = [UIColor grayColor];
    label.tag = 90;
    label.text = [formatter stringFromDate:message.date];
    [label sizeToFit];
    CGRect frame = label.frame;
    
    CGFloat topMargin = 5.0f;
    CGFloat leftMargin = 15.0f;
    CGFloat rightMargin = 20.0f;
    
    if (message.fromMe) {
        frame.origin.x = cell.contentView.frame.size.width - cell.userImageView.frame.size.width - frame.size.width - rightMargin;
        frame.origin.y = cell.containerView.frame.origin.y + cell.containerView.frame.size.height + topMargin;
    } else {
        frame.origin.x = cell.containerView.frame.origin.x + cell.userImageView.frame.origin.x + cell.userImageView.frame.size.width + leftMargin;
        frame.origin.y = cell.containerView.frame.origin.y + cell.containerView.frame.size.height + topMargin;
    }
    label.frame = frame;
    
    return label;
}

- (UIImage *)balloonImageForSending
{
    UIImage *img = [UIImage imageNamed:@"bubble_rect_sending.png"];
    return [img resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 24, 11)];
}

- (UIImage *)balloonImageForReceiving
{
    UIImage *img = [UIImage imageNamed:@"bubble_rect_receiving.png"];
    return [img resizableImageWithCapInsets:UIEdgeInsetsMake(3, 11, 24, 3)];
}

- (CGFloat)messageMaxWidth
{
    return 140;
}

- (CGSize)userImageSize
{
    return CGSizeMake(60, 60);
}

- (CGFloat)balloonMinHeight
{
    return 60;
}

- (CGFloat)balloonMinWidth
{
    return 243;
}

#pragma mark - SOMessaging delegate
- (void)didSelectMedia:(NSData *)media inMessageCell:(SOMessageCell *)cell
{
    // Show selected media in fullscreen
    [super didSelectMedia:media inMessageCell:cell];
}

- (void)messageInputView:(SOMessageInputView *)inputView didSendMessage:(NSString *)message
{
    if (![[message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        return;
    }
    
    SOMessage *msg = [[SOMessage alloc] init];
    msg.text = message;
    msg.fromMe = YES;
    
    [self sendMessage:msg];
}

- (void)messageInputViewDidSelectMediaButton:(SOMessageInputView *)inputView
{
    // Take a photo/video or choose from gallery
}

@end
