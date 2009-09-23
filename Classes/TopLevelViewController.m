#import "TopLevelViewController.h"
#import "ChildViewController.h"
#import "IndexViewController.h"
#import "AccountSettingsViewController.h"
#import "TagIndexViewController.h"
#import "EditNoteViewController.h"
#import "AccountImageView.h"

enum TopLevelSections 
{
  kNavigationSection,
  kRecentNotesSection,
  kSectionCount
};

@implementation TopLevelViewController
@synthesize controllers, recentNotes, recentNoteEditor;

- (IBAction) editNewNote
{
  // New Note

  EditNoteViewController *editor = [[[EditNoteViewController alloc] init] autorelease];

  [self.navigationController pushViewController:editor animated:YES];
}

- (IBAction) editSettings
{
  // Edit SwankNote Settings
  
  AccountSettingsViewController *settings = 
    [[[AccountSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
  
  [settings push:self.navigationController];
}

- (void) refreshRecentNotes
{
  // Load recent notes.
  
  self.recentNotes = [NoteFilter fetchRecentNotes:5];
  
  [self.tableView reloadData]; 
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Apple recommends against allowing portrait upside-down, because it will stay that
  // way when a phone call begins.
  
  return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)viewWillAppear:(BOOL)animated
{
  multipleAccounts = [[Account fetchAllAccounts] count] > 1;
  [self refreshRecentNotes];
}

- (void)viewDidLoad
{
  ChildViewController *child;
  
  self.title = @"Swank Note";
  
  // Configure left nav button.
  self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
                                            initWithTitle:@"Settings"
                                            style:UIBarButtonItemStyleBordered
                                            target:self
                                            action:@selector(editSettings)] autorelease];
  
  // Configure right nav button.
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                             target:self
                                             action:@selector(editNewNote)]
                                            autorelease];
  
  self.recentNoteEditor = [[[EditNoteViewController alloc] init] autorelease];
  
  self.controllers = [[[NSMutableArray alloc] init] autorelease];
  
  // All Notes
  child = [[[IndexViewController alloc] init] autorelease];
  child.title = @"All Notes";
  [controllers addObject:child];
  
  // Tags
  child = [[[TagIndexViewController alloc] init] autorelease];
  child.title = @"Tags";
  [controllers addObject:child];
  
  [super viewDidLoad];
}

- (void)viewDidUnload
{
  self.recentNotes = nil;
  self.recentNoteEditor = nil;
  self.controllers = nil;
  [super viewDidUnload];
}

- (void)dealloc
{
  [recentNotes release];
  [recentNoteEditor release];
  [controllers release];
  [super dealloc];
}

#pragma mark Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return kSectionCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  switch (section)
  {
    case kNavigationSection:  return nil;
    case kRecentNotesSection: return @"Recent Notes";
  }
  
  return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  switch (section)
  {
    case kNavigationSection:  return [controllers count];
    case kRecentNotesSection: return (recentNotes == nil) ? 0 : [recentNotes count];
  }
  
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  switch (indexPath.section)
  {
    case kNavigationSection:
    {
      static NSString *tableId = @"TopLevelTableId";
      
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableId];
      
      if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableId] autorelease];
      
      // Configure the cell.
      
      UIViewController *child = [controllers objectAtIndex:indexPath.row];
      cell.textLabel.text = child.title;
      
      if ([child isKindOfClass:[ChildViewController class]])
      {
        ChildViewController *childC = (ChildViewController *)child;
        cell.imageView.image = childC.rowImage;
      }
      
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      
      return cell;
    }
     
    case kRecentNotesSection:
    {
      static NSString *tableId = @"RecentNoteTableId";
      
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableId];
      
      if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tableId] autorelease];
      
      // Configure the cell.
      
      Note *note = [recentNotes objectAtIndex:indexPath.row];

      cell.textLabel.text = note.text;
      cell.detailTextLabel.text = [note changedDelta];
      cell.accessoryView = multipleAccounts ? [note.account imageView] : nil;
      
      return cell;
    }
  }
  
  return nil;
}

#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  switch (indexPath.section)
  {
    case kNavigationSection:
    {
      ChildViewController *child = [self.controllers objectAtIndex:indexPath.row];
      [self.navigationController pushViewController:child animated:YES];
    } break;
      
    case kRecentNotesSection:
    {
      Note *note = [recentNotes objectAtIndex:indexPath.row];
      recentNoteEditor.note = note;
      recentNoteEditor.navigation = recentNotes;
      [self.navigationController pushViewController:recentNoteEditor animated:YES];
    } break;      
  }
}

@end
