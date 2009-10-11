#import "EditNoteViewController.h"
#import "SwankNoteAppDelegate.h"
#import "Note.h"

#define kKeyboardHeightPortrait 216
#define kKeyboardHeightLandscape 140

@implementation EditNoteViewController
@synthesize text, tagsController;
@synthesize note, navigation;
@synthesize currentText, currentTags;
@synthesize bottomToolbar, noteLeft, noteRight, trash;

- (void)dealloc 
{
  [note release];
  [text release];
  [noteLeft release];
  [noteRight release];
  [trash release];
  [tagsController release];
  [navigation release];
  [currentText release];
  [currentTags release];
  [super dealloc];
}

#pragma mark Utility Methods
- (Note *) noteRelativeToThisOne:(NSInteger)offset
{
  if (navigation == nil || note == nil)
    return nil;
  
  NSInteger index = [navigation indexOfObject:note];
  
  if (index == NSNotFound)
    return nil;
  
  NSInteger otherNoteIndex = index + offset;
  
  if (otherNoteIndex < 0 || otherNoteIndex >= [navigation count])
    return nil;
  
  return [navigation objectAtIndex:otherNoteIndex];
}

- (void) synchronize
{
  SwankNoteAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  [appDelegate.synchronizer updateNotes];
}

- (void) setNote:(Note *)newNote
{
  if (note != newNote)
  {
    note = newNote;
    [note retain];
  }
  
  if (note != nil)
  {
    self.currentText = note.text;
    self.currentTags = note.tags;
  }
  else
  {
    self.currentText = @"";
    self.currentTags = @"";
  }
  
  [tagsController resetForNote:note];
}

#pragma mark Public Methods
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (IBAction) editTags
{
  [self.navigationController pushViewController:tagsController animated:YES];
}

#pragma mark Controller Actions
- (IBAction)dismissKeyboard:(id)sender
{
  [text resignFirstResponder];
}

- (IBAction)cancel:(id)sender
{  
  self.note = nil;
  self.navigation = nil;
  
  closedIntentionally = true;
  
  [[note managedObjectContext] rollback];
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender
{
  NSString *newTags = [tagsController.currentTags componentsJoinedByString:@" "];
  
  if (note == nil)
    self.note = [NoteFilter newNote];
  
  note.text = [text text];  
  note.tags = newTags;
  
  [note save:YES];    
  [self synchronize];
  
  self.note = nil;
  self.navigation = nil;

  closedIntentionally = true;
  
  [self.navigationController popViewControllerAnimated:YES];
}
 
- (IBAction)destroy
{
  UIActionSheet *sheet = 
    [[[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this note?"
                                 delegate:self
                        cancelButtonTitle:@"Wait, no."
                   destructiveButtonTitle:@"Yes, destroy it!"
                        otherButtonTitles:nil] autorelease];
  [sheet showInView:self.navigationController.view];
}

// Respond to the destroy confirmation sheet.
- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 0)
  {
    [note destroy];
    self.note = nil;
    [self synchronize];
    
    closedIntentionally = true;
    
    [self.navigationController popViewControllerAnimated:YES];
  }  
}

- (IBAction) previous
{
  Note *previousNote = [self noteRelativeToThisOne:-1];
  
  if (previousNote != nil)
    self.note = previousNote;
  
  [self viewWillAppear:NO];
}

- (IBAction) next
{
  Note *nextNote = [self noteRelativeToThisOne:+1];
  
  if (nextNote != nil)
    self.note = nextNote;
  
  [self viewWillAppear:NO];
}

#pragma mark View Initializers
- (void) viewDidLoad
{
  [super viewDidLoad];
  
  // Set the left navigation button.
  
  self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" 
                                                                            style:UIBarButtonItemStyleBordered 
                                                                           target:self 
                                                                           action:@selector(cancel:)] autorelease];
  
  // Set the right navigation button.
  
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Save" 
                                                                 style:UIBarButtonItemStyleDone 
                                                                target:self 
                                                                action:@selector(save:)] autorelease];
  
  // Add keyboard hooks.
  
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
  [nc addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
  
  // Add tag editor.
  
  self.tagsController = [[[EditNoteTagsViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
  [tagsController resetForNote:note];
}

- (void) viewWillAppear:(BOOL)animated
{
  noteLeft.enabled = [self noteRelativeToThisOne:-1] != nil;
  noteRight.enabled = [self noteRelativeToThisOne:+1] != nil;
  trash.enabled = note != nil;
  
  text.text = (currentText == nil) ? @"" : currentText;
}

- (void) viewDidAppear:(BOOL)animated
{ 
  // If this is a new note, open the keyboard.
  
  if ([text.text length] == 0)
    [text becomeFirstResponder];
  else
    [text resignFirstResponder];
  
  // Scroll to top.

  CGRect bounds = text.bounds;
  bounds.origin.x = 0;
  bounds.origin.y = 0;
  text.bounds = bounds;
  
  closedIntentionally = false;
}

- (void) viewWillDisappear:(BOOL)animated
{
  self.currentText = text.text;
  self.currentTags = [tagsController.currentTags componentsJoinedByString:@" "];
  
  // Get rid of any unsaved changes before storing the application state.
  [[SwankNoteAppDelegate context] rollback];
  
  if (closedIntentionally)
    [AppSettings clearNoteInProgress];
  else
    [AppSettings setNoteInProgress:note withText:currentText withTags:currentTags];
  
  [super viewWillDisappear:animated];
}

- (void)viewDidUnload 
{
  self.note = nil;
  self.text = nil;
  self.noteLeft = nil;
  self.noteRight = nil;
  self.trash = nil;
  self.tagsController = nil;
  self.navigation = nil;
  self.currentText = nil;
  self.currentTags = nil;
  [super viewDidUnload];
}

#pragma mark Adjust the text entry box for the keyboard and view shifts.
- (NSUInteger) textFieldHeight:(bool)keyboardIsVisible
{
  UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
  
  NSUInteger screenHeight = UIDeviceOrientationIsLandscape(orientation)
                            ? text.window.frame.size.width
                            : text.window.frame.size.height;
  
  NSUInteger textTop = text.superview.superview.frame.origin.y;
  NSUInteger textBot = bottomToolbar.frame.origin.y;
  
  NSUInteger keyboardHeight = UIDeviceOrientationIsLandscape(orientation)
                              ? kKeyboardHeightLandscape 
                              : kKeyboardHeightPortrait;
  
  NSUInteger keyboardPadding = UIDeviceOrientationIsLandscape(orientation) ? 5 : 25;
  
  if (keyboardIsVisible)
    return screenHeight - textTop - keyboardHeight + keyboardPadding;
  else
    return textBot;
}

-(void) keyboardDidShow:(NSNotification *)notification
{
  // Change the right button to Done, to dismiss the keyboard.
  
  //self.navigationItem.leftBarButtonItem.style = UIBarButtonItemStyleDone;
  self.navigationItem.leftBarButtonItem.title = @"Done Editing";
  self.navigationItem.leftBarButtonItem.action = @selector(dismissKeyboard:);
  
  // Adjust the text view to accomidate the keyboard.
  
  //NSUInteger textTop = [[text superview] superview].frame.origin.y;
  
  CGRect textDim = text.frame;
  
  //[[notification.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue:&keyboardDim];
  textDim.size.height = [self textFieldHeight:true];
  
  text.frame = textDim;
}

-(void) keyboardDidHide:(NSNotification *)notification
{
  // Change right button to Save.
  
  //self.navigationItem.leftBarButtonItem.style = UIBarButtonItemStyleBordered;
  self.navigationItem.leftBarButtonItem.title = @"Cancel";
  self.navigationItem.leftBarButtonItem.action = @selector(cancel:);
  
  // Adjust the text view to its original size.
  
  CGRect textDim = text.frame;
  
  //[[notification.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue:&keyboardDim];
  textDim.size.height = [self textFieldHeight:false];
  
  text.frame = textDim;
}

@end
