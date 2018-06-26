//
//  ViewController.m
//  DRAudioRecorder
//
//  Created by niyao on 6/25/18.
//  Copyright © 2018 dourui. All rights reserved.
//

#import "ViewController.h"
#import "DRAudioRecorder.h"
#import "XunFeiSpeechRecognizerClient.h"

@interface ViewController () <SpeechRecognizerDelegate, DRAudioRecorderDelegate>

@property (nonatomic, strong) DRAudioRecorder *recorder;
@property (nonatomic, strong) XunFeiSpeechRecognizerClient *speechRecognizer;
@property (nonatomic, strong) UITextView *speechTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [XunFeiSpeechRecognizerClient config];
    self.recorder = [[DRAudioRecorder alloc] init];
    self.recorder.delegate = self;
    [self.recorder setupRecorder];
    [self.view addSubview:self.speechTextView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.speechRecognizer start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startRecord:(id)sender {
    self.speechRecognizer.type = XunFeiSpeechRecognizerTypeRecorderStream;
    if ([self.speechRecognizer start]) {
        BOOL success = [self.recorder start];
        NSLog(@"Recorder Start Result: %d", success);
    }
}

- (IBAction)stopRecord:(id)sender {
    [self.recorder stop];
    self.speechRecognizer.type = XunFeiSpeechRecognizerTypeDefault;
    [self.speechRecognizer start];
}
- (IBAction)playAudio:(id)sender {
    [self.recorder play];
}

- (XunFeiSpeechRecognizerClient *)speechRecognizer {
    if (!_speechRecognizer) {
        _speechRecognizer = [[XunFeiSpeechRecognizerClient alloc] init];
        _speechRecognizer.delegate = self;
    }
    return _speechRecognizer;
}

- (UITextView *)speechTextView {
    if (!_speechTextView) {
        _speechTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 200, [UIScreen mainScreen].bounds.size.width, 200)];
    }
    return _speechTextView;
}

- (void)speechRecognizerDidEndSpeech {
    
}

- (void)speechRecognizerDidCompleteWithError:(NSError *)error {
    if (error) {
        NSLog(@"%@", error);
    } else {
        [self.speechRecognizer start];
    }
}

- (void)speechRecognizerDidRecognizeResults:(NSArray *)results isLast:(BOOL)isLast {
    
}

- (void)speechRecognizerDidRecognizePartString:(NSString *)partString fullString:(NSString *)fullString isLast:(BOOL)isLast {
    self.speechTextView.text = [NSString stringWithFormat:@"%@\n%@", partString, fullString];
}

#pragma mark - DRAudioRecorderDelegate
- (void)recorderDidProcessAudioData:(NSData *)audioData {
    [self.speechRecognizer recognizeAudioData:audioData];
}

@end
