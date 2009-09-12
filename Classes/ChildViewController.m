#import "ChildViewController.h"

@implementation ChildViewController
@synthesize rowImage;

- (void) synchronize
{
  SwankNoteAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  [appDelegate.synchronizer updateNotes];
}

@end
