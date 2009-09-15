#import "EditNoteTagsViewController.h"
#import "NoteFilter.h"
#import "NewTagsViewController.h"

@implementation EditNoteTagsViewController
@synthesize allTags, currentTags, orderedTags, newTagsController;

- (void)resetForNote:(Note *)note
{
  // Get the list of all saved tags.
  
  self.allTags = [NSMutableArray arrayWithArray:[NoteFilter fetchAllTags]];
  
  // Move all tags in the given note from the list of all tags to the list of current tags.
  
  NSMutableArray *newCurrentTags = [[NSMutableArray alloc] init];
  self.currentTags = newCurrentTags;
  for (NSString *tag in [note.tags splitForTags])
  {
    [allTags removeObject:tag];
    [currentTags addObject:tag];
  }
  [newCurrentTags release];
  
  // Reset the view for the new data.

  [self.tableView reloadData];
}

- (void)addNewTag:(id)sender
{
  [self.navigationController pushViewController:self.newTagsController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
  if (newTagsController != nil && [newTagsController tags] != nil)
  {
    for (NSString *tag in [newTagsController tags])
    {
      [allTags addObject:tag];
      [currentTags addObject:tag];
    }
    
    [allTags sortUsingSelector:@selector(caseInsensitiveCompare:)];
    [currentTags sortUsingSelector:@selector(caseInsensitiveCompare:)];
    
    [[newTagsController tags] removeAllObjects];
  }
  
  [self.tableView reloadData];
}

- (void)viewDidLoad
{
  // New tag button.
  
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"New Tags" 
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self 
                                                                  action:@selector(addNewTag:)] autorelease];
  
  // Load new tag controller.
  
  self.newTagsController = [[[NewTagsViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
}

- (void)viewDidUnload
{
  self.allTags = nil;
  self.currentTags = nil;
  self.newTagsController = nil;
}

- (void)dealloc
{
  [allTags release];
  [currentTags release];
  [newTagsController release];
  [super dealloc];
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  NSMutableArray *src = (indexPath.section == 0) ? currentTags : allTags;
  NSMutableArray *dst = (indexPath.section == 0) ? allTags : currentTags;
  
  NSString *tag = [src objectAtIndex:indexPath.row];
  [src removeObject:tag];
  [dst addObject:tag];
  
  [allTags sortUsingSelector:@selector(caseInsensitiveCompare:)];
  [currentTags sortUsingSelector:@selector(caseInsensitiveCompare:)];
  
  [tableView reloadData];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == 0)
    return [currentTags count];
  else
    return [allTags count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  switch (section)
  {
    case 0: return @"Current Tags";
    case 1: return @"Available Tags";
  }
  
  return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *tableId = @"TagTableId";
  
  NSString *tag;
  
  if (indexPath.section == 0)
    tag = [currentTags objectAtIndex:indexPath.row];
  else
    tag = [allTags objectAtIndex:indexPath.row];
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableId];
  
  if (cell == nil)
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableId] autorelease];
  
  cell.textLabel.text = tag;
  cell.accessoryType = UITableViewCellAccessoryNone; 
  
  return cell;
}

@end
