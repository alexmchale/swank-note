#import "EditNoteViewController.h"
#import "SwankNoteAppDelegate.h"
#import "IndexViewController.h"
#import "SwankRootViewController.h"
#import "SwankNavigator.h"
#import "Note.h"

@implementation EditNoteViewController
@synthesize text;
@synthesize note;

- (void)edit
{
  self.note = nil;
  [self.text setText:@""];
}

- (void)edit:(Note *)newNote
{
  self.note = newNote;
  [self.text setText:newNote.text];
}

- (IBAction)cancel
{
  [self dismiss:UIModalTransitionStyleCoverVertical];
}

- (IBAction)save
{
  if (note == nil)
    self.note = [Note new];

  note.text = [text text];
  
  [note save];
  
  [self dismiss:UIModalTransitionStyleCoverVertical];
}

- (IBAction)destroy
{
  [note destroy];
  [self dismiss:UIModalTransitionStyleCoverVertical];
}

- (IBAction)previous
{
  [self edit:[self previousNote:note]];
}

- (IBAction)next
{
  [self edit:[self nextNote:note]];
}

- (void)dismiss:(UIModalTransitionStyle)style
{
  self.note = nil;
  [self reloadIndex];
  self.modalTransitionStyle = style;
  [self dismissModalViewControllerAnimated:YES];  
}

- (void)viewDidUnload {
  self.note = nil;
  self.text = nil;
}

- (void)dealloc {
  [note release];
  [text release];
  [super dealloc];
}

#pragma mark UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
	if (!viewShifted)
  {		
    // don't shift if it's already shifted
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kVerticalOffsetAnimationDuration];
    
		CGRect rect = textView.frame;		
		rect.size.height -= kOFFSET_FOR_KEYBOARD;
		textView.frame = rect;
    
		[UIView commitAnimations];
		
		viewShifted = TRUE;
	}
  
	return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
  if (viewShifted)
  {
    [UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kVerticalOffsetAnimationDuration];
    
		CGRect rect = textView.frame;
		rect.size.height += kOFFSET_FOR_KEYBOARD;
		textView.frame = rect;
    
		[UIView commitAnimations];
		
		viewShifted = FALSE;
  }
  
  return YES;
}

@end