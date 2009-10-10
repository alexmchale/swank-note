#import "IndexViewController.h"

#define kMinimumRows 10

@implementation IndexViewController
@synthesize searchBar, tableView, noteEditor;
@synthesize notes, searchPhrase, searchTag;

- (void) dealloc 
{
  [searchBar release];
  [tableView release];
  [noteEditor release];
  [notes release];
  [searchPhrase release];
  [searchTag release];
  [super dealloc];
}

- (void) viewDidLoad
{
  [super viewDidLoad];
  
  self.noteEditor = [[[EditNoteViewController alloc] init] autorelease];
  multipleAccounts = [[Account fetchAllAccounts] count] > 1;
  [self reload];
}

- (void) viewDidUnload 
{
  self.searchBar = nil;
  self.noteEditor = nil;
  self.notes = nil;
  self.searchPhrase = nil;
  self.searchTag = nil;
  [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
  multipleAccounts = [[Account fetchAllAccounts] count] > 1;
  [self reload];
  
  [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
  if (searchPhrase == nil || [searchPhrase length] == 0)
    [tableView setContentOffset:CGPointMake(0.0, 44.0) animated:YES];
  else
    [tableView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
  
  [searchBar resignFirstResponder];
  
  [super viewDidAppear:animated];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
  return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

// Reload the list of notes and refresh the table.
- (void) reload
{
  self.notes = [NoteFilter fetchWithPhrase:searchPhrase withTag:searchTag];
  
  [self.tableView reloadData];
}

#pragma mark Table Methods
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  noteEditor.note = [notes objectAtIndex:indexPath.row];
  noteEditor.navigation = notes;
  
  [self.navigationController pushViewController:noteEditor animated:YES];
}

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row >= [notes count])
    return nil;
  
  return indexPath;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSInteger count = [self.notes count];
  
  if (count < kMinimumRows)
    return kMinimumRows;
  
  return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *tableId = @"NewIndexTableId";
  
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:tableId];
  
  if (cell == nil)
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tableId] autorelease];
  
  if (indexPath.row < [notes count])
  {
    Note *note = [notes objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = note.text;
    
    NSString *details = @"";
    NSString *delta = [note changedDelta];
    NSString *tags = [[note tags] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([delta length] && [tags length])
      details = [NSString stringWithFormat:@"%@ - %@", delta, tags];
    else if ([delta length])
      details = delta;
    else if ([tags length])
      details = tags;
    
    cell.detailTextLabel.text = details; 
    
    cell.accessoryView = multipleAccounts ? [note.account imageView] : nil;
  }
  else
  {
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    cell.accessoryView = nil;
  }

  
  return cell;  
}

#pragma mark Search Methods
- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
  self.searchPhrase = searchText;
  [self reload];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
  self.searchPhrase = @"";
  self.searchBar.text = @"";
  [self reload];  
  
  [tableView setContentOffset:CGPointMake(0.0, 44.0) animated:YES];
  [self.searchBar resignFirstResponder];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  if (searchPhrase == nil || [searchPhrase length] == 0)
    [tableView setContentOffset:CGPointMake(0.0, 44.0) animated:YES];
  
  [self.searchBar resignFirstResponder];
}

@end
