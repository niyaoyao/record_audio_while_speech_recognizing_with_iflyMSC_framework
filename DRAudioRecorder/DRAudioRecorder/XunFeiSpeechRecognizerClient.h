//
//  XunFeiSpeechRecognizerClient.h
//  doutu
//
//  Created by niyao on 6/20/18.
//  Copyright © 2018 dourui. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IFlyMSC/IFlyMSC.h"

NS_ASSUME_NONNULL_BEGIN
@protocol SpeechRecognizerDelegate <NSObject>

@required
- (void)speechRecognizerDidRecognizePartString:(NSString  * _Nullable )partString fullString:(NSString  * _Nullable )fullString isLast:(BOOL)isLast;

- (void)speechRecognizerDidCompleteWithError:(NSError * _Nullable)error;

@optional
- (void)speechRecognizerDidRecognizeResults:(NSArray  * _Nullable )results isLast:(BOOL)isLast;
- (void)speechRecognizerDidEndSpeech;

@end

@class IFlySpeechRecognizer;

typedef void(^XunFeiSpeechRecognizerClientOnResultsHandler)(NSArray *results, BOOL isLast);

typedef NS_ENUM(NSInteger, XunFeiSpeechRecognizerType) {
    XunFeiSpeechRecognizerTypeDefault,
    XunFeiSpeechRecognizerTypeRecorderStream,
};

@interface XunFeiSpeechRecognizerClient : NSObject <IFlySpeechRecognizerDelegate>
//不带界面的识别对象
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;
@property (nonatomic, weak) id<SpeechRecognizerDelegate> delegate;
@property (nonatomic, copy) XunFeiSpeechRecognizerClientOnResultsHandler onResultsHandler;
@property (nonatomic, assign) XunFeiSpeechRecognizerType type;

+ (void)config;
- (BOOL)start;
- (void)cancel;
- (void)recognizeAudioData:(NSData *)data;

@end
NS_ASSUME_NONNULL_END
