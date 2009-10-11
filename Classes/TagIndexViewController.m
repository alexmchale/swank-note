#import "TagIndexViewController.h"

@implementation TagIndexViewController
@synthesize tags, indexViewController;

- (void)viewWillAppear:(BOOL)animated
{
  // Update Tags
  
  self.tags = [AppSettings allTags];
  
  [self.tableView reloadData];
}

- (void)viewDidLoad
{
  self.indexViewController = [[[IndexViewController alloc] init] autorelease];
}

- (void)viewDidUnload
{
  self.tags = nil;
  self.indexViewController = nil;
}

- (void)dealloc
{
  [tags release];
  [indexViewController release];
  [super dealloc];
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  NSString *tag = [tags objectAtIndex:indexPath.row];
  
  indexViewController.title = tag;
  indexViewController.searchPhrase = @"";
  indexViewController.searchTag = tag;
  
  [self.navigationController pushViewController:indexViewController animated:YES];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [tags count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *tableId = @"TagTableId";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableId];
  
  if (cell == nil)
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:tableId] autorelease];
  
  NSString *tagName = [tags objectAtIndex:indexPath.row];
  NSInteger noteCount = [[NoteFilter fetchWithPhrase:nil withTag:tagName] count];
  //NSString *rowText = [NSString stringWithFormat:@"%@ (%d)", tagName, noteCount];
  
  cell.textLabel.text = tagName;
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", noteCount];
  cell.accessoryType = UITableViewCellAccessoryNone; 
  
  return cell;
}

@end
