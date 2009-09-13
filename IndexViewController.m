#import "IndexViewController.h"
#import "SwankNoteAppDelegate.h"
#import "SwankRootViewController.h"
#import "Note.h"
#import "NoteFilter.h"
#import "AppSettings.h"
#import "AccountImageView.h"

@implementation IndexViewController
@synthesize notes, searchBar, noteEditor;
@synthesize filterForTag;

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  multipleAccounts = [[Account fetchAllAccounts] count] > 1;
  [self reload];
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  EditNoteViewController *newEditor = [[EditNoteViewController alloc] init];
  self.noteEditor = newEditor;
  [newEditor release];
  
  /*
  NoteSync *noteSync = [[NoteSync alloc] init];
  [newNoteSync release];
  self.noteSync.delegate = self;
  [self.noteSync updateNotes];
   */
  
  // Don't show the search box by default.
  //[self.tableView setContentOffset:CGPointMake(0.0, 44.0) animated:NO];
}

- (void)reload
{
  if (filterForTag == nil)
    self.notes = [NoteFilter fetchAll];
  else
    self.notes = [NoteFilter fetchAllWithTag:filterForTag];
  
  [self.tableView reloadData];
}

- (void)viewDidUnload 
{
  self.searchBar = nil;
  self.notes = nil;
  self.noteEditor = nil;
  [super viewDidUnload];
}

- (void)dealloc 
{
  [searchBar release];
  [notes release];
  [noteEditor release];
  [filterForTag release];
  [super dealloc];
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  Note *note = [notes objectAtIndex:[indexPath row]];
  noteEditor.note = note;
  noteEditor.navigation = notes;
  [self.navigationController pushViewController:noteEditor animated:YES];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [notes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *tableId = @"IndexTableId";
  Note *note = [notes objectAtIndex:[indexPath row]];
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
  
  if (multipleAccounts)
    cell.accessoryView = [[[AccountImageView alloc] initWithColor:[note.account color]] autorelease];
  else
    cell.accessoryView = nil;

  return cell;
}

#pragma mark NoteSync
- (void)notesWereUpdated
{
  [self reload];
}

#pragma mark Search Bar Methods
- (IBAction)showSearchBar
{
  /*
  if ([self.searchBar isFirstResponder])
  {
    //[noteFilter searchText:nil];
    [self reload];
    [table setContentOffset:CGPointMake(0.0, 44.0) animated:YES];
    [self.searchBar resignFirstResponder];
  }
  else
  {
    [table setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    [self.searchBar becomeFirstResponder];
  }
  */
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)activeSearchBar
{
  /*
  [self reload];
  [activeSearchBar resignFirstResponder];
  
  [table setContentOffset:CGPointMake(0.0, 44.0) animated:NO];
  */
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchTerm
{
  //[self.noteFilter searchText:searchTerm];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)activeSearchBar
{
  /*
  [self.searchBar setText:@""];
  //[self.noteFilter searchText:nil];
  [self reload];
  [activeSearchBar resignFirstResponder];
  [table setContentOffset:CGPointMake(0.0, 44.0) animated:NO];
  */
}

@end
