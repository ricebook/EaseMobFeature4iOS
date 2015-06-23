/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "MessageReadManager.h"
//#import "UIImageView+EMWebCache.h"
//#import "EMCDDeviceManager.h"
#import "Daenerys-Swift.h"
static MessageReadManager *detailInstance = nil;

@interface MessageReadManager()
@property (strong, nonatomic) RBDImageBrowser *imageBrowser;
@end

@implementation MessageReadManager

+ (id)defaultManager
{
    @synchronized(self){
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            detailInstance = [[self alloc] init];
        });
    }
    
    return detailInstance;
}

#pragma mark - getter
- (RBDImageBrowser *)imageBrowser {
    if (_imageBrowser == nil) {
        _imageBrowser = [[RBDImageBrowser alloc] init];
        _imageBrowser.isShowTextInfo = false;
    }
    return _imageBrowser;
}

#pragma mark - private


#pragma mark - public

- (void)showBrowserWithImages:(NSArray *)imageArray
{
    self.imageBrowser.shownImageWithUrlString = imageArray;
    [self.imageBrowser show];
}

- (BOOL)prepareMessageAudioModel:(MessageModel *)messageModel
                      updateViewCompletion:(void (^)(MessageModel *prevAudioModel, MessageModel *currentAudioModel))updateCompletion
{
    BOOL isPrepare = NO;
    
    if(messageModel.type == eMessageBodyType_Voice)
    {
        MessageModel *prevAudioModel = self.audioMessageModel;
        MessageModel *currentAudioModel = messageModel;
        self.audioMessageModel = messageModel;
        
        BOOL isPlaying = messageModel.isPlaying;
        if (isPlaying) {
            messageModel.isPlaying = NO;
            self.audioMessageModel = nil;
//            prevAudioModel.isPlaying = NO;
            currentAudioModel = nil;
            
//            [[EMCDDeviceManager sharedInstance] stopPlaying];
        }
        else {
            messageModel.isPlaying = YES;
            prevAudioModel.isPlaying = NO;
            isPrepare = YES;
            
            if (!messageModel.isPlayed) {
                messageModel.isPlayed = YES;
                EMMessage *chatMessage = messageModel.message;
                if (chatMessage.ext) {
                    NSMutableDictionary *dict = [chatMessage.ext mutableCopy];
                    if (![[dict objectForKey:@"isPlayed"] boolValue]) {
                        [dict setObject:@YES forKey:@"isPlayed"];
                        chatMessage.ext = dict;
                        [chatMessage updateMessageExtToDB];
                    }
                }
            }
        }
        
        if (updateCompletion) {
            updateCompletion(prevAudioModel, currentAudioModel);
        }
    }
    
    return isPrepare;
}

- (MessageModel *)stopMessageAudioModel
{
    MessageModel *model = nil;
    if (self.audioMessageModel.type == eMessageBodyType_Voice) {
        if (self.audioMessageModel.isPlaying) {
            model = self.audioMessageModel;
        }
        self.audioMessageModel.isPlaying = NO;
        self.audioMessageModel = nil;
    }
    
    return model;
}


@end
