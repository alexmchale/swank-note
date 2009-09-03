#import "IndexViewController.h"
#import "SwankNoteAppDelegate.h"
#import "SwankRootViewController.h"
#import "Note.h"
#import "NoteFilter.h"

@implementation IndexViewController
@synthesize noteFilter, noteSync, table, searchBar;

- (void)viewDidLoad
{
  NoteFilter *newNoteFilter = [[NoteFilter alloc] initWithContext];
  self.noteFilter = newNoteFilter;
  [newNoteFilter release];
  
  NoteSync *newNoteSync = [[NoteSync alloc] init];
  self.noteSync = newNoteSync;
  [newNoteSync release];
  self.noteSync.delegate = self;
  [self.noteSync updateNotes];
    
  [self reload];
  [super viewDidLoad];
  
  [table setContentOffset:CGPointMake(0.0, 44.0) animated:NO];
}

- (IBAction)composeNewMessage
{
  [self editNewNote];
}

- (void)reload
{
  [noteFilter resetContext];
  [table reloadData];
}

- (void)viewDidUnload 
{
  self.table = nil;
  self.searchBar = nil;
  self.noteFilter = nil;
  self.noteSync = nil;
  [super viewDidUnload];
}

- (void)dealloc 
{
  [table release];
  [searchBar release];
  [noteFilter release];
  [noteSync release];
  [super dealloc];
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  Note *note = [noteFilter atIndex:[indexPath row]];
  [self editNote:note];
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [noteFilter count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *tableId = @"IndexTableId";
  Note *note = [noteFilter atIndex:[indexPath row]];
  NSDate *date = (NSDate *)note.updatedAt;
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableId];
  
  if (cell == nil)
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tableId] autorelease];
  
  NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
  [df setDateFormat:@"MMM d, yyyy"];
  NSString *dateText = [df stringFromDate:date];
  [df setDateFormat:@"h:mma"];
  NSString *timeText = [df stringFromDate:date];
  NSString *detailText = [[[NSString alloc] initWithFormat:@"%@ on %@", timeText, dateText] autorelease];
  
  cell.textLabel.text = note.text;
  cell.detailTextLabel.text = detailText; 
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 

  return cell;
}

#pragma mark NoteSync
- (IBAction)sync
{
  [noteSync updateNotes];
}

- (void)notesWereUpdated
{
  [self reload];
}

#pragma mark Search Bar Methods
- (IBAction)showSearchBar
{
  if ([self.searchBar isFirstResponder])
  {
    [noteFilter searchText:nil];
    [self reload];
    [table setContentOffset:CGPointMake(0.0, 44.0) animated:YES];
    [self.searchBar resignFirstResponder];
  }
  else
  {
    [table setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    [self.searchBar becomeFirstResponder];
  }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)activeSearchBar
{
  [self reload];
  [activeSearchBar resignFirstResponder];
  
  [table setContentOffset:CGPointMake(0.0, 44.0) animated:NO];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchTerm
{
  [self.noteFilter searchText:searchTerm];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)activeSearchBar
{
  [self.searchBar setText:@""];
  [self.noteFilter searchText:nil];
  [self reload];
  [activeSearchBar resignFirstResponder];
  [table setContentOffset:CGPointMake(0.0, 44.0) animated:NO];
}

@end
