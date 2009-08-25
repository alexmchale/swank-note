//
//  EditNoteViewController.h
//  SwankNote
//
//  Created by Alex McHale on 8/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "SwankNavigator.h"

// the amount of vertical shift upwards keep the Notes text view visible as the keyboard appears
#define kKEYBOARD_HEIGHT     215
#define kTOOLBAR_HEIGHT      44
#define kOFFSET_FOR_KEYBOARD (kKEYBOARD_HEIGHT - kTOOLBAR_HEIGHT - 25)

// the duration of the animation for the view shift
#define kVerticalOffsetAnimationDuration		0.50

@interface EditNoteViewController : SwankNavigator <UITextViewDelegate>
{  
  UITextView *text;
  
  BOOL viewShifted;
  Note *note;
}

@property (nonatomic, retain) IBOutlet UITextView *text;
@property (nonatomic, retain) Note *note;

- (void)edit;
- (void)edit:(Note *)note;
- (IBAction)cancel;
- (IBAction)save;
- (IBAction)previous;
- (IBAction)next;
- (IBAction)destroy;
- (void)dismiss:(UIModalTransitionStyle)style;

@end
