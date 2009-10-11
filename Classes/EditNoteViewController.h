#import <UIKit/UIKit.h>
#import "Note.h"
#import "ChildViewController.h"
#import "EditNoteTagsViewController.h"

// the amount of vertical shift upwards keep the Notes text view visible as the keyboard appears
#define kKEYBOARD_HEIGHT     215
#define kTOOLBAR_HEIGHT      44
#define kOFFSET_FOR_KEYBOARD (kKEYBOARD_HEIGHT - kTOOLBAR_HEIGHT - 25)

// the duration of the animation for the view shift
#define kVerticalOffsetAnimationDuration		0.50

@interface EditNoteViewController : UIViewController <UITextViewDelegate, UIActionSheetDelegate>
{  
  UITextView *text;
  
  bool viewShifted;
  
  Note *note;
  NSArray *navigation;
  NSString *currentText;
  NSString *currentTags;
  
  EditNoteTagsViewController *tagsController;
  
  UIToolbar *bottomToolbar;
  UIBarButtonItem *noteLeft;
  UIBarButtonItem *noteRight;
  UIBarButtonItem *separator;
  UIBarButtonItem *trash;
  
  bool closedIntentionally;
}

@property (nonatomic, retain) IBOutlet UITextView *text;
@property (nonatomic, retain) Note *note;
@property (nonatomic, retain) NSArray *navigation;
@property (nonatomic, retain) NSString *currentText;
@property (nonatomic, retain) NSString *currentTags;
@property (nonatomic, retain) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *noteLeft;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *noteRight;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *trash;
@property (nonatomic, retain) EditNoteTagsViewController *tagsController;

- (IBAction) dismissKeyboard:(id)sender;
- (IBAction) cancel:(id)sender;
- (IBAction) save:(id)sender;
- (IBAction) previous;
- (IBAction) next;
- (IBAction) destroy;
- (IBAction) editTags;

@end
