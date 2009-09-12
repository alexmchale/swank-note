#import "TagIndexViewController.h"

@implementation TagIndexViewController
@synthesize tags, indexViewController;

- (void)viewWillAppear:(BOOL)animated
{
  // Update Tags
  
  self.tags = [NoteFilter fetchAllTags];
  
  [self.tableView reloadData];
}

- (void)viewDidLoad
{
  IndexViewController *index = [[IndexViewController alloc] init];
  self.indexViewController = index;
  [index release];
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
  indexViewController.filterForTag = tag;
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
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableId] autorelease];
  
  cell.textLabel.text = [tags objectAtIndex:indexPath.row];
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
  
  return cell;
}

@end
