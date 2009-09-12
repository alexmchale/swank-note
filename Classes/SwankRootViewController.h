#import <UIKit/UIKit.h>
#import "IndexViewController.h"
#import "EditNoteViewController.h"
#import "AccountSettingsViewController.h"

@interface SwankRootViewController : UIViewController 
{
	IndexViewController *indexViewController;
	EditNoteViewController *editNoteViewController;
  AccountSettingsViewController *accountSettingsViewController;
}

@property (nonatomic, retain) IBOutlet IndexViewController *indexViewController;
@property (nonatomic, retain) IBOutlet EditNoteViewController *editNoteViewController;
@property (nonatomic, retain) IBOutlet AccountSettingsViewController *accountSettingsViewController;

- (void)showEditor;
- (void)showSettings;

@end
