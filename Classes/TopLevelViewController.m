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

- (void) refreshRecentNotes
{
  // Load recent notes.
  
  self.recentNotes = [NoteFilter fetchRecentNotes:5];
  
  [self.tableView reloadData]; 
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
  
  self.recentNoteEditor = [[EditNoteViewController alloc] init];
  
  NSMutableArray *array = [[NSMutableArray alloc] init];
  self.controllers = array;
  
  // New Note
  child = [[EditNoteViewController alloc] init];
  child.title = @"New Note";
  [array addObject:child];
  [child release];
  
  // All Notes
  child = [[IndexViewController alloc] init];
  child.title = @"All Notes";
  [array addObject:child];
  [child release];
  
  // Tags
  child = [[TagIndexViewController alloc] init];
  child.title = @"Tags";
  [array addObject:child];
  [child release];
  
  // Settings
  child = [[AccountSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
  child.title = @"Settings";
  [array addObject:child];
  [child release];
  
  [array release];
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
    case kNavigationSection:  return [self.controllers count];
    case kRecentNotesSection: return (self.recentNotes == nil) ? 0 : [self.recentNotes count];
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableId] autorelease];
      
      // Configure the cell.
      
      Note *note = [recentNotes objectAtIndex:indexPath.row];
      cell.textLabel.text = note.text;
      
      if (multipleAccounts)
        cell.accessoryView = [[[AccountImageView alloc] initWithColor:[note.account color]] autorelease];
      else
        cell.accessoryView = nil;
      
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
