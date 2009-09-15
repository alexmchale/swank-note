#import "EditNoteViewController.h"
#import "SwankNoteAppDelegate.h"
#import "IndexViewController.h"
#import "Note.h"

@implementation EditNoteViewController
@synthesize text, backgroundImage;
@synthesize note, navigation;
@synthesize noteLeft, noteRight, trash;
@synthesize tagsController;

#pragma mark Public Methods
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
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender
{
  if ([text isFirstResponder])
  {
    [text resignFirstResponder];
  }
  else
  {
    if (note == nil)
      note = [NoteFilter newNote];
    
    NSString *newTags = [tagsController.currentTags componentsJoinedByString:@" "];
    
    note.text = [text text];
    note.tags = newTags;
    
    [note save:YES];    
    [self synchronize];
    
    self.note = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
  }
}

- (IBAction)destroy
{
  [note destroy];
  [self synchronize];
  [self.navigationController popViewControllerAnimated:YES];
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
  note = newNote;
  [tagsController resetForNote:note];
}

#pragma mark View Initializers
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Set the left navigation button.
  
  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" 
                                                                   style:UIBarButtonItemStyleBordered 
                                                                  target:self 
                                                                  action:@selector(cancel:)];
  self.navigationItem.leftBarButtonItem = cancelButton;
  [cancelButton release];
  
  // Set the right navigation button.
  
  UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" 
                                                                 style:UIBarButtonItemStyleDone 
                                                                target:self 
                                                                action:@selector(save:)];
  self.navigationItem.rightBarButtonItem = saveButton;
  [saveButton release];
  
  // Set the editor background image.
  
  if (self.backgroundImage == nil && FALSE)
  {
    self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notepaper.png"]];
    [self.view addSubview: self.backgroundImage];
    [self.view sendSubviewToBack: self.backgroundImage];
  }
  
  // Add keyboard hooks.
  
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  
  // Add tag editor.
  
  EditNoteTagsViewController *newTagsController = [[EditNoteTagsViewController alloc] initWithStyle:UITableViewStyleGrouped];
  self.tagsController = newTagsController;
  [newTagsController resetForNote:note];
  [newTagsController release];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  if (note == nil)
    text.text = @"";
  else
    text.text = note.text;
  
  noteLeft.enabled = [self noteAtOffset:-1] != nil;
  noteRight.enabled = [self noteAtOffset:+1] != nil;
  trash.enabled = note != nil;
  
  if ([text.text length] == 0)
    [text becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
  note.text = text.text;
}

- (void)viewDidUnload 
{
  self.backgroundImage = nil;
  self.note = nil;
  self.text = nil;
  self.noteLeft = nil;
  self.noteRight = nil;
  self.trash = nil;
  self.tagsController = nil;
}

- (void)dealloc 
{
  [backgroundImage release];
  [note release];
  [text release];
  [noteLeft release];
  [noteRight release];
  [trash release];
  [tagsController release];
  [super dealloc];
}

#pragma mark Keyboard Hooks
-(void) keyboardWillShow:(NSNotification *)notification
{
  // Change the right button to Done, to dismiss the keyboard.
  
  self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
  self.navigationItem.rightBarButtonItem.title = @"Done";
  self.navigationItem.rightBarButtonItem.action = @selector(dismissKeyboard:);
  
  // Adjust the text view to accomidate the keyboard.
  
  CGRect textDim = text.frame;
  CGRect keyboardDim;
  
  [[notification.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue:&keyboardDim];
  textDim.size.height -= keyboardDim.size.height - 70;
  
  text.frame = textDim;
}

-(void) keyboardWillHide:(NSNotification *)notification
{
  // Change right button to Save.
  
  self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
  self.navigationItem.rightBarButtonItem.title = @"Save";
  self.navigationItem.rightBarButtonItem.action = @selector(save:);
  
  // Adjust the text view to its original size.
  
  CGRect textDim = text.frame;
  CGRect keyboardDim;
  
  [[notification.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue:&keyboardDim];
  textDim.size.height += keyboardDim.size.height - 70;
  
  text.frame = textDim;
}

@end
