//
//  XunFeiSpeechRecognizerClient.m
//  doutu
//
//  Created by niyao on 6/20/18.
//  Copyright © 2018 dourui. All rights reserved.
//

#import "XunFeiSpeechRecognizerClient.h"
#import "ISRDataHelper.h"

#if DEBUG
#define ShowFunctionName NSLog(@"XunFei: %s",__func__);
#else
#define ShowFunctionName
#endif

@interface XunFeiSpeechRecognizerClient ()

@property (nonatomic, strong) NSString *text;

@end

@implementation XunFeiSpeechRecognizerClient


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupRecognizer];
    }
    return self;
}

- (void)dealloc {
    [self.iFlySpeechRecognizer cancel];
    self.iFlySpeechRecognizer.delegate = nil;
    [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
}

#pragma mark - Private
- (void)setupRecognizer {
    //recognition singleton without view
    if (_iFlySpeechRecognizer == nil) {
        _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
    }
    
    [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    
    //set recognition domain
    [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    
    _iFlySpeechRecognizer.delegate = self;
    
    if (_iFlySpeechRecognizer != nil) {
        //set timeout of recording
        [_iFlySpeechRecognizer setParameter:@"30000" forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        //set VAD timeout of end of speech(EOS)
        [_iFlySpeechRecognizer setParameter:@"3000" forKey:[IFlySpeechConstant VAD_EOS]];
        //set VAD timeout of beginning of speech(BOS)
        [_iFlySpeechRecognizer setParameter:@"3000" forKey:[IFlySpeechConstant VAD_BOS]];
        //set network timeout
        [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        
        //set sample rate, 16K as a recommended option
        [_iFlySpeechRecognizer setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
        
        //set language
        //            [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        //            //set accent
        //            [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
        
        //set whether or not to show punctuation in recognition results
        [_iFlySpeechRecognizer setParameter:@"1" forKey:[IFlySpeechConstant ASR_PTT]];
        
    }
}
#pragma mark - Public
+ (void)config {
    //Set log level
    [IFlySetting setLogFile:LVL_ALL];
    
    //Set whether to output log messages in Xcode console
    [IFlySetting showLogcat:YES];
    
    //Set the local storage path of SDK
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    [IFlySetting setLogFilePath:cachePath];
    
    //Set APPID
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@", @"5b1f9dcc"];
    
    //Configure and initialize iflytek services.(This interface must been invoked in application:didFinishLaunchingWithOptions:)
    [IFlySpeechUtility createUtility:initString];
    
}


- (BOOL)start {
    if (self.type == XunFeiSpeechRecognizerTypeDefault) {
        if(_iFlySpeechRecognizer == nil) {
            [self setupRecognizer];
        }
        
        [_iFlySpeechRecognizer cancel];
        
        //Set microphone as audio source
        [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        
        //Set result type
        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        
        //Set the audio name of saved recording file while is generated in the local storage path of SDK,by default in library/cache.
        [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        
        [_iFlySpeechRecognizer setDelegate:self];
        
        return [_iFlySpeechRecognizer startListening];
    } else {
        if(_iFlySpeechRecognizer == nil) {
            [self setupRecognizer];
        }
        
        [_iFlySpeechRecognizer cancel];
        [_iFlySpeechRecognizer setDelegate:self];
        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_STREAM forKey:@"audio_source"];    //Set audio stream as audio source,which requires the developer import audio data into the recognition control by self through "writeAudio:".
        return [_iFlySpeechRecognizer startListening];
        
        
    }
}


- (void)cancelSpeech {
    [_iFlySpeechRecognizer cancel];
}

- (void)recognizeAudioData:(NSData *)data {
    [_iFlySpeechRecognizer writeAudio:data];
}

#pragma mark - IFlySpeechRecognizerDelegate
- (void)onVolumeChanged:(int)volume {
    
}

- (void)onBeginOfSpeech {
    
}

- (void)onResults:(NSArray *)results isLast:(BOOL)isLast {
    ShowFunctionName
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
        NSLog(@"XunFei Key: %@", key);
    }
    
    NSString *result = [NSString stringWithFormat:@"%@%@", _text,resultString];
    NSString *resultFromJson =  nil;
        resultFromJson = [ISRDataHelper stringFromJson:resultString];
    
    if (self.text == nil) {
        self.text = resultFromJson;
    } else {
        self.text = [NSString stringWithFormat:@"%@%@", self.text, resultFromJson];
    }
    
    if (isLast){
//        NSLog(@"ISR Results(json)：%@",  self.result);
    }
//    NSLog(@"_result=%@",_result);
#if DEBUG
    NSLog(@"XunFei resultFromJson=%@",resultFromJson);
    NSLog(@"XunFei isLast=%d,_textView.text=%@",isLast, self.text);
#endif
    
    if (_onResultsHandler) {
        _onResultsHandler(results,isLast);
    }
    
    if ([self.delegate respondsToSelector:@selector(speechRecognizerDidRecognizePartString:fullString:isLast:)]) {
        [self.delegate speechRecognizerDidRecognizePartString:resultFromJson fullString:self.text isLast:isLast];
    }
}



- (void)onEndOfSpeech {
    ShowFunctionName
    if ([self.delegate respondsToSelector:@selector(speechRecognizerDidEndSpeech)]) {
        [self.delegate speechRecognizerDidEndSpeech];
    }
}

- (void)onCompleted:(IFlySpeechError *)error {
    ShowFunctionName
    if (error.errorCode == 0) {
        if ([self.delegate respondsToSelector:@selector(speechRecognizerDidCompleteWithError:)]) {
            [self.delegate speechRecognizerDidCompleteWithError:nil];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(speechRecognizerDidCompleteWithError:)]) {
            NSError *speechError = [NSError errorWithDomain:@"XunFeiSpeechDomain"
                                                  code:error.errorCode
                                              userInfo:@{ NSLocalizedDescriptionKey : error.errorDesc }];
            [self.delegate speechRecognizerDidCompleteWithError:speechError];
        }
    }
}

- (void)onCancel {
    ShowFunctionName
}


@end
