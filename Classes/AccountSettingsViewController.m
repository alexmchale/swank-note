#import "AccountSettingsViewController.h"
#import "UITableViewUtilities.h"
#import "NSArrayUtilities.h"

typedef enum
{
  kEnableSyncSection,
  kAccountListSection,
  kNewAccountSection
} AccountSettingsSections;

@implementation AccountSettingsViewController
@synthesize swankSyncEnabled, enableSync, accounts;
@synthesize accountEditor;

#pragma mark UI Methods
- (void) viewWillAppear:(BOOL)animated
{
  self.accounts = [Account fetchAllAccounts];
  self.swankSyncEnabled.on = self.enableSync;
  
  [self.tableView reloadData];
}

- (void) viewDidLoad
{
  self.enableSync = [AppSettings sync];
  self.swankSyncEnabled = [[[UISwitch alloc] init] autorelease];
  
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
  
  // Load the account editor.
  
  EditAccountViewController *newAccountEditor = [[EditAccountViewController alloc] initWithStyle:UITableViewStyleGrouped];
  self.accountEditor = newAccountEditor;
  [newAccountEditor release];
  
  [super viewDidLoad];
}

- (void)viewDidUnload 
{
  self.swankSyncEnabled = nil;
  self.accounts = nil;
  self.accountEditor = nil;
  [super viewDidUnload];
}

- (void) dealloc 
{
  [swankSyncEnabled release];
  [accounts release];
  [accountEditor release];
  [super dealloc];
}

#pragma mark Cancel and Save Actions
- (IBAction) cancel:(id)sender
{
  self.enableSync = [AppSettings sync];
  [[SwankNoteAppDelegate context] rollback];
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) save:(id)sender
{
  [AppSettings setSync:swankSyncEnabled.on];
  self.enableSync = [AppSettings sync];
  [[SwankNoteAppDelegate context] save:nil];
  [self.navigationController popViewControllerAnimated:YES];
}

// Reload the table when the sync enable switch changes.
- (void) onSyncEnableChanged:(id)sender
{ 
  self.accounts = [Account fetchAllAccounts];
  self.enableSync = self.swankSyncEnabled.on;

  [self.tableView reloadData];
  
  if (enableSync && (accounts == nil || [accounts count] == 0))
  {
    accountEditor.account = nil;
    [self.navigationController pushViewController:accountEditor animated:YES];
  }
}

#pragma mark UITableViewDelegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  switch (indexPath.section)
  {
    case kAccountListSection:
      self.accountEditor.account = [accounts objectAtIndex:indexPath.row];
      [self.navigationController pushViewController:self.accountEditor animated:YES];
      break;
      
    case kNewAccountSection:
      self.accountEditor.account = nil;
      [self.navigationController pushViewController:self.accountEditor animated:YES];
      break;
  }
}

#pragma mark UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
  return self.enableSync ? 3 : 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  if (section == kAccountListSection && accounts != nil && [accounts count] > 0)
    return @"SwankDB Accounts";
  
  return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  switch (section)
  {
    case kEnableSyncSection:  return 1;
    case kAccountListSection: return [accounts count];
    case kNewAccountSection:  return 1;
  }
  
  return 0;
}

#pragma mark Table Cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForSyncEnabled:(NSInteger)row
{
  static NSString *tableId = @"SyncEnabledTableId";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableId];
  
  if (cell == nil)
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableId] autorelease];
  
  cell.textLabel.text = @"Sync with SwankDB";
  [self.swankSyncEnabled addTarget:self action:@selector(onSyncEnableChanged:) forControlEvents:UIControlEventValueChanged];
  cell.accessoryView = self.swankSyncEnabled;
  
  self.swankSyncEnabled.on = self.enableSync;
  
  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForAccountList:(NSInteger)row
{
  static NSString *tableId = @"AccountListTableId";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableId];
  
  if (cell == nil)
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableId] autorelease];
  
  Account *account = [accounts objectAtIndex:row];

  cell.textLabel.text = account.username;
  
  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForAccountControl:(NSInteger)row
{
  static NSString *tableId = @"AccountControlTableId";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableId];
  
  if (cell == nil)
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableId] autorelease];
  
  cell.textLabel.text = @"Add SwankDB Account";
  
  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  switch (indexPath.section)
  {
    case kEnableSyncSection:  return [self tableView:tableView cellForSyncEnabled:indexPath.row];
    case kAccountListSection: return [self tableView:tableView cellForAccountList:indexPath.row];
    case kNewAccountSection:  return [self tableView:tableView cellForAccountControl:indexPath.row];
  }

  return nil;
}

@end
