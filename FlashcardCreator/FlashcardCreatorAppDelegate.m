//
//  MathFlashAppDelegate.m
//  MathFlash
//
//  Created by Brett Hutley on 21/09/2011.
//  Copyright 2011 Stimuli Limited. All rights reserved.
//

#import "FlashcardCreatorAppDelegate.h"

@implementation FlashcardCreatorAppDelegate

@synthesize window;
@synthesize savePath = _savePath;
@synthesize topic = _topic;
@synthesize section = _section;
@synthesize questionNumber = _questionNumber;
@synthesize question = _question;
@synthesize image2 = _image2;
@synthesize isQuestion = _isQuestion;

static NSString *USERDEF_SAVEPATH_KEY = @"SavePath";
static NSString *USERDEF_TOPIC_KEY = @"CurrentTopic";
static NSString *USERDEF_SECTION_KEY = @"CurrentSection";
static NSString *USERDEF_QUESTION_KEY = @"CurrentQuestion";

static int
getOffsetForTopic(NSString *topicName)
{
    NSString *subString = [topicName substringWithRange:NSMakeRange(5, 2)];
    return atoi([subString UTF8String]);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    for (int i = 0; i < 30; i++)
    {
        NSString *s = [NSString stringWithFormat:@"Unit %02d", i+1];
        [self.topic addItemWithObjectValue:s];
    }
    
    NSURL *defaultSavePath = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEF_SAVEPATH_KEY];
    if (defaultSavePath == nil) {
        defaultSavePath = [NSURL URLWithString:NSHomeDirectory()];
    }
    
    [self.savePath setURL:defaultSavePath];
    [self.savePath setPathStyle:NSPathStylePopUp];
    
    NSNumber *selectedItemOffset = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEF_TOPIC_KEY];
    if (selectedItemOffset != nil)
    {
        int topicOffset = [selectedItemOffset intValue];
        if (topicOffset >= 0)
            [self.topic selectItemAtIndex:topicOffset];
        else
            [self.topic selectItemAtIndex:0];
    }
    else
        [self.topic selectItemAtIndex:0];
    
    NSString *selectedSection = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEF_SECTION_KEY];
    if (selectedSection != nil)
    {
        [self.section setStringValue:selectedSection];
    }
    
    NSString *selectedQuestion = [[NSUserDefaults standardUserDefaults] valueForKey:USERDEF_QUESTION_KEY];
    if (selectedQuestion != nil)
    {
        [self.questionNumber setStringValue:selectedQuestion];
    }
    
    [self.isQuestion selectItemAtIndex:0];
}

- (void) applicationWillTerminate:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] setValue:[self.savePath URL] forKey:USERDEF_SAVEPATH_KEY];
    
    long topicOffset = [self.topic indexOfSelectedItem];
    if (topicOffset >= 0)
    {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:(int)topicOffset] forKey:USERDEF_TOPIC_KEY];
    }
    
    NSString *currentSection = [self.section stringValue];
    if (currentSection != nil)
    {
        [[NSUserDefaults standardUserDefaults] setValue:currentSection forKey:USERDEF_SECTION_KEY];
    }
    
    NSString *currentQuestion = [self.questionNumber stringValue];
    if (currentQuestion != nil)
    {
        [[NSUserDefaults standardUserDefaults] setValue:currentQuestion forKey:USERDEF_QUESTION_KEY];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) dealloc
{
    [_savePath release];
    [_topic release];
    [_section release];
    [_questionNumber release];
    [_question release];
    [_isQuestion release];
    [_image2 release];
    [super dealloc];
}

- (void) save1Image: (NSData *)jpegdata withImageNumber: (int) imageNum
{
    //NSImageRep *imageRep = [[question_ representations] objectAtIndex:0];
    //[imageRep 
    
    NSString *currentSection = [self.section stringValue];
    NSString *currentQuestion = [self.questionNumber stringValue];
    long selItem = [self.isQuestion indexOfSelectedItem];
    BOOL isAQuestion = (selItem == 0);
    const char *questSuffix;
    if (isAQuestion)
        questSuffix = "q";
    else
        questSuffix = "a";
    NSString *basePath = [[self.savePath URL] path];
    NSString *filename = [NSString stringWithFormat:@"%@/fc_%02d_%02d_%02d_%s_%02d.pdf", basePath, getOffsetForTopic([self.topic stringValue]), [currentSection intValue], [currentQuestion intValue], questSuffix, imageNum];
    [jpegdata writeToFile:filename atomically:NO];
}

- (NSData *) getJPGDataForImage: (NSImage *) image
{
    NSData *ret = nil;
    for (int i = 0; i < [[image representations] count]; i++)
    {
        NSImageRep *rep = [[image representations] objectAtIndex:i];
        //NSLog([[bits class] description]);
        if ([rep isKindOfClass:[NSPDFImageRep class]])
        {
            NSPDFImageRep *bits = (NSPDFImageRep *)rep;
            //return [bits PDFRepresentation];
            // convert to jpeg rep
            NSImage *tmpimg = [[NSImage alloc] initWithData:[bits PDFRepresentation]];
            NSBitmapImageRep *bitrep = [NSBitmapImageRep imageRepWithData:[tmpimg TIFFRepresentation]];
            ret = [bitrep representationUsingType:NSJPEGFileType properties:nil];
            [tmpimg release];
            break;
        }
        else if ([rep isKindOfClass:[NSBitmapImageRep class]])
        {
            NSBitmapImageRep *bitrep = (NSBitmapImageRep *)rep;
            ret = [bitrep representationUsingType:NSJPEGFileType properties:nil];
        }
        else
        {
            [image lockFocus];
            NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0.0, 0.0, [image size].width, [image size].height)] ;
            [image unlockFocus];
            ret = [bitmapRep representationUsingType:NSJPEGFileType properties:nil];
            [bitmapRep release];
        }
    }
                    
    return ret;
}

- (NSPDFImageRep *) getPDFImageRepFromImage: (NSImage *) image
{
    NSPDFImageRep *bits = nil;
    for (int i = 0; i < [[image representations] count]; i++)
    {
        NSImageRep *rep = [[image representations] objectAtIndex:i];
        //NSLog([[bits class] description]);
        if ([rep isKindOfClass:[NSPDFImageRep class]])
        {
            bits = (NSPDFImageRep *)rep;
            break;
        }
        bits = nil;
    }

    return bits;
}

- (NSImage *) combineImage1: (NSImage *) image1 andImage2: (NSImage *)image2
{
    NSSize size1 = [image1 size];
    NSSize size2 = [image2 size];
    CGFloat width = size1.width;
    if (size2.width > width)
        width = size2.width;
    width *= 2;
    
    CGFloat height = (size1.height * 2) + 40 + (size2.height * 2);
    NSImage *newImage = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
    //NSImage *newImage = [[NSImage alloc] initWithData:[[self getPDFImageRepFromImage: image1] PDFRepresentation] ];
    //[newImage setSize:NSMakeSize(width, height)];
    [newImage setDataRetained:YES];
    
    [newImage lockFocus];
    NSRect rect1;
    rect1.origin.x = 0;
    rect1.origin.y = 0;
    rect1.size.width = size1.width * 2;
    rect1.size.height = size1.height * 2;
    
    NSRect rect2;
    rect2.origin.x = 0;
    rect2.origin.y = size1.height+40;
    rect2.size.width = size2.width * 2;
    rect2.size.height = size2.height * 2;
    
    [newImage drawRepresentation:[self getPDFImageRepFromImage:image1]  inRect:rect1];
    [newImage drawRepresentation:[self getPDFImageRepFromImage:image2]  inRect:rect2];
    //[image1 compositeToPoint:NSMakePoint(0,0) operation:NSCompositeSourceOver];
    //[image2 compositeToPoint:NSMakePoint(0,height+40) operation:NSCompositeSourceOver];
    
    //NSImageRep *newImageRep = [[NSImageRep imageRepClassForFileType: @"PDF"] alloc];
    //[newImage addRepresentation:newImageRep];
    //[newImageRep release];
    
    [newImage unlockFocus];
    [newImage autorelease];
    return newImage;
}

/*
- (IBAction)saveImages:(id)sender
{
    NSImage *combinedImage;
    
    if ([self.image2 image] != nil)
    {
        combinedImage = [self combineImage1:[question_ image] andImage2:[image2_ image]];
    }
    else
    {
        combinedImage = [question_ image];
    }
    [combinedImage retain];
    NSData *jpegdata = [self getJPGDataForImage:combinedImage];
    if (jpegdata != nil)
    {
        [self save1Image:jpegdata];
        
        NSString *currentQuestion = [self.questionNumber stringValue];
        
        int questionNum = [currentQuestion intValue];
        questionNum++;
        [self.questionNumber setStringValue:[NSString stringWithFormat:@"%d", questionNum]];
    }
    [combinedImage release];
}
 */

- (IBAction)saveImages:(id)sender
{
    BOOL savedOk = NO;
    
    if (self.question)
    {
        NSPDFImageRep *bits = [self getPDFImageRepFromImage:[_question image]];
        if (bits != nil)
        {
            [self save1Image:[bits PDFRepresentation] withImageNumber:0];

            savedOk = YES;
        }
        
        //[self.question setStringVa
        [self.question setImage:[[NSImage alloc] init]];
    }
    
    if (self.image2)
    {
        NSPDFImageRep *bits = [self getPDFImageRepFromImage:[_image2 image]];
        if (bits != nil)
        {
            [self save1Image:[bits PDFRepresentation] withImageNumber:1];
        }

        [self.image2 setImage:[[NSImage alloc] init]];
    }
    
    if (savedOk)
    {
        NSString *currentQuestion = [self.questionNumber stringValue];
        
        int questionNum = [currentQuestion intValue];
        questionNum++;
        [self.questionNumber setStringValue:[NSString stringWithFormat:@"%d", questionNum]];
    }
}

- (IBAction) sectionChanged: (id) sender
{
    //NSLog([NSString stringWithFormat: @"sectionChanged: new value is now %@", [self.section stringValue]]);
    [self.questionNumber setStringValue:@"1"];
}


@end
