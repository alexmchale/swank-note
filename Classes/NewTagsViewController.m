#import "NewTagsViewController.h"

@implementation NewTagsViewController
@synthesize textField, tags;

- (void)viewWillAppear:(BOOL)animated
{
  if (self.tags == nil)
    textField.text = @"";
  else
    textField.text = [tags componentsJoinedByString:@" "];
  
  [textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
  self.tags = [NSMutableArray arrayWithArray:[textField.text splitForTags]];
  [tags sortUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (void)viewDidLoad
{
  UITextField *newTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 12, 275, 25)];
  self.textField = newTextField;
  [newTextField release];
  
  textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  textField.clearsOnBeginEditing = NO;
  textField.returnKeyType = UIReturnKeyDone;    
  [textField addTarget:self action:@selector(tagFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
}

- (void)viewDidUnload
{
  self.textField = nil;
  self.tags = nil;
}

- (void)dealloc
{
  [textField release];
  [tags release];
  [super dealloc];
}

- (void)tagFieldDone:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return @"New Tags";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
  return @"Enter as many new tags as you would like, separated by spaces.";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *identifier = @"NewTagTableId";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  
  if (cell == nil)
  {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    [cell.contentView addSubview:textField];
  }
  
  return cell;
}

@end
