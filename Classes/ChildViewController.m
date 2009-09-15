#import "ChildViewController.h"

@implementation ChildViewController
@synthesize rowImage;

- (void) synchronize
{
  SwankNoteAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  [appDelegate.synchronizer updateNotes];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

@end
