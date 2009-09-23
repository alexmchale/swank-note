#import "EditNoteViewController.h"
#import "SwankNoteAppDelegate.h"
#import "Note.h"

#define kKeyboardHeightPortrait 216
#define kKeyboardHeightLandscape 140

@implementation EditNoteViewController
@synthesize text;
@synthesize note, navigation;
@synthesize bottomToolbar, noteLeft, noteRight, trash;
@synthesize tagsController;

- (void)dealloc 
{
  [note release];
  [text release];
  [noteLeft release];
  [noteRight release];
  [trash release];
  [tagsController release];
  [navigation release];
  [super dealloc];
}

#pragma mark Public Methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (IBAction)editTags
{
  [self.navigationController pushViewController:tagsController animated:YES];
}

- (void) synchronize
{
  SwankNoteAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  [appDelegate.synchronizer updateNotes];
}

#pragma mark Controller Actions
- (IBAction)dismissKeyboard:(id)sender
{
  [text resignFirstResponder];
}

- (IBAction)cancel:(id)sender
{
  [[note managedObjectContext] rollback];
  
  self.note = nil;
  self.navigation = nil;
  
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender
{
  if (note == nil)
    self.note = [NoteFilter newNote];
  
  NSString *newTags = [tagsController.currentTags componentsJoinedByString:@" "];
  
  note.text = [text text];
  note.tags = newTags;
  
  [note save:YES];    
  [self synchronize];
  
  self.note = nil;
  self.navigation = nil;
  
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
  
//  [note destroy];
//  [self synchronize];
//  [self.navigationController popViewControllerAnimated:YES];
}

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 0)
  {
    [note destroy];
    [self synchronize];
    [self.navigationController popViewControllerAnimated:YES];
  }  
}

- (Note *)noteAtOffset:(NSInteger)offset
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

- (IBAction)previous
{
  Note *previousNote = [self noteAtOffset:-1];
  
  if (previousNote != nil)
    self.note = previousNote;
  
  [self viewWillAppear:NO];
}

- (IBAction)next
{
  Note *nextNote = [self noteAtOffset:+1];
  
  if (nextNote != nil)
    self.note = nextNote;
  
  [self viewWillAppear:NO];
}

- (void)setNote:(Note *)newNote
{
  if (note != newNote)
  {
    note = newNote;
    [note retain];
  }
  
  [tagsController resetForNote:note];
}

#pragma mark View Initializers
- (void)viewDidLoad
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
  noteLeft.enabled = [self noteAtOffset:-1] != nil;
  noteRight.enabled = [self noteAtOffset:+1] != nil;
  trash.enabled = note != nil;
  
  text.text = (note == nil) ? @"" : note.text;
}

- (void) viewDidAppear:(BOOL)animated
{  
  if ([text.text length] == 0)
    [text becomeFirstResponder];
  else
    [text resignFirstResponder];
  
  // Scroll to top.

  CGRect bounds = text.bounds;
  bounds.origin.x = 0;
  bounds.origin.y = 0;
  text.bounds = bounds;
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
                              ? kKeyboardHeightLandscape : kKeyboardHeightPortrait;
  
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
