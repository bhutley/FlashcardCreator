//
//  MathFlashAppDelegate.h
//  MathFlash
//
//  Created by Brett Hutley on 21/09/2011.
//  Copyright 2011 Stimuli Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FlashcardCreatorAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    
    NSComboBox *topic_;
    NSTextField *section_;
    NSTextField *questionNumber_;
    NSImageCell *question_;
    NSImageCell *image2_;
    NSComboBox *isQuestion_;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet NSPathControl *savePath;
@property (nonatomic, retain) IBOutlet NSComboBox *topic;
@property (nonatomic, retain) IBOutlet NSTextField *section;
@property (nonatomic, retain) IBOutlet NSTextField *questionNumber;
@property (nonatomic, retain) IBOutlet NSImageCell *question;
@property (nonatomic, retain) IBOutlet NSImageCell *image2;
@property (nonatomic, retain) IBOutlet NSComboBox *isQuestion;


- (IBAction)saveImages:(id)sender;
- (IBAction) sectionChanged: (id) sender;

@end
