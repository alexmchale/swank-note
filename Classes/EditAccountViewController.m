#import "EditAccountViewController.h"

typedef enum
{
  kSectionCredentials,
  kSectionUseAsDefault,
  kSectionDeleteAccount
} AccountSettingsSection;

typedef enum
{
  kCredentialsUsernameRow,
  kCredentialsPasswordRow,
  kCredentialsNewUserRow
} AccountCredentialsRow;

typedef enum
{
  kUsernameFieldTag = 5170,
  kPasswordFieldTag,
  kDestroySheetTag
} InterfaceElementTags;

enum 
{
  kDestructiveButton = 0
};

@implementation EditAccountViewController
@synthesize account, username, password, isNewAccount;

#pragma mark UI Methods
- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  markAsDefault = false;
  
  [self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated
{
  isNewAccount.on = NO;
  
  if (account == nil)
  {
    [username becomeFirstResponder];
  }
  else
  {
    [username resignFirstResponder];
    [password resignFirstResponder];
  }
}

- (void) viewDidLoad
{
  [super viewDidLoad];

  
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
  
  // Build the isNetAccount switch.
  
  self.isNewAccount = [[[UISwitch alloc] init] autorelease];
}

- (void) viewDidUnload
{
  self.account = nil;
  self.username = nil;
  self.password = nil;
}

- (void) dealloc
{
  [account release];
  [username release];
  [password release];
  [super dealloc];
}

#pragma mark Cancel and Save Nav Buttons
- (void) cancel:(id)sender
{
  [[SwankNoteAppDelegate context] rollback];
  [self.navigationController popViewControllerAnimated:YES];
}

- (void) save:(id)sender
{
  // Try to create a new account, if requested.
  
  if (isNewAccount.on)
  {
    NSString *error;
    
    self.account = [Account create:username.text withPassword:password.text error:&error];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Account Error" 
                                                    message:error
                                                   delegate:nil 
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    if (account == nil)
      return;
  }
  
  // Verify that no other account has that username.
  
  if (self.account == nil)
  {
    if ([Account fetchByUsername:username.text] != nil)
    {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Account Error" 
                                                      message:@"An account with that username already exists in SwankNote."
                                                     delegate:nil 
                                            cancelButtonTitle:@"Okay"
                                            otherButtonTitles:nil];
      [alert show];
      [alert release];
      
      return;
    }
    
    self.account = [Account new];
  }
  
  self.account.username = username.text;
  self.account.password = password.text;
  
  if ([self.account testConnection:self.view])
  {
    if (markAsDefault || ([Account fetchDefaultAccount] == nil && [account.swankId intValue] > 0))
      [AppSettings setDefaultAccountSwankId:[account.swankId intValue]];
    
    [[SwankNoteAppDelegate context] save:nil];
    [self.navigationController popViewControllerAnimated:YES];
  }
  else
  {
    self.account = nil;
    [[SwankNoteAppDelegate context] rollback];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication Error" 
                                                    message:@"SwankNote could not authenticate that username and password with SwankDB."
                                                   delegate:nil 
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
  }
}

#pragma mark Account Control Buttons
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (actionSheet.tag == kDestroySheetTag && buttonIndex == kDestructiveButton)
  {
    if (account != nil)
    {
      [[SwankNoteAppDelegate context] deleteObject:account];
      [[SwankNoteAppDelegate context] save:nil];
      // TODO: Delete all notes associated with this account.
      self.account = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
  }
}

- (void) destroy
{
  if (account != nil)
  {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this account?  All notes associated with it will be deleted!"
                                                       delegate:self
                                              cancelButtonTitle:@"No, don't delete"
                                         destructiveButtonTitle:@"Yes, delete it!"
                                              otherButtonTitles:nil];
    [sheet setTag:kDestroySheetTag];
    [sheet showInView:self.view];
    [sheet release];
  }
}

#pragma mark UITextFieldDelegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
  if (textField == username)
    [password becomeFirstResponder];
  else if (textField == password)
    [password resignFirstResponder];
  
  return YES;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  switch (indexPath.section)
  {
    case kSectionCredentials:
      if (indexPath.row == kCredentialsUsernameRow)
        [username becomeFirstResponder];
      else if (indexPath.row == kCredentialsPasswordRow)
        [password becomeFirstResponder];
      break;
      
    case kSectionUseAsDefault:
      markAsDefault = true;
      [tableView reloadData];
      break;
      
    case kSectionDeleteAccount:
      [self destroy];
      break;
  }
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return (account == nil) ? 1 : 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  switch (section)
  {
    case kSectionCredentials:   
      return (account == nil) ? 3 : 2;
    
    case kSectionUseAsDefault:
      return (account == nil || [account.swankId intValue] == 0) ? 0 : 1;
    
    case kSectionDeleteAccount:
      return (account == nil) ? 0 : 1;
  }
  
  return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  switch (section)
  {
    case kSectionCredentials: return @"SwankDB Account";
  }
  
  return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  switch (indexPath.section)
  {
    case kSectionCredentials:
    {     
      if (indexPath.row == kCredentialsUsernameRow)
      {
        UILabel *label;
        UITableViewCell *cell = [tableView dequeueOrInitSimpleInputCell:@"Credentials" labelField:&label textField:&username]; 
      
        username.returnKeyType = UIReturnKeyNext;
        username.autocapitalizationType = UITextAutocapitalizationTypeNone;
        username.autocorrectionType = UITextAutocorrectionTypeNo;
        username.delegate = self;
        
        label.text = @"Username:";
        username.text = (account == nil) ? @"" : account.username;
        
        return cell;
      }
      else if (indexPath.row == kCredentialsPasswordRow)
      {
        UILabel *label;
        UITableViewCell *cell = [tableView dequeueOrInitSimpleInputCell:@"Credentials" labelField:&label textField:&password]; 
        
        password.returnKeyType = UIReturnKeyDone;
        password.autocapitalizationType = UITextAutocapitalizationTypeNone;
        password.autocorrectionType = UITextAutocorrectionTypeNo;
        password.delegate = self;
        
        label.text = @"Password:";
        password.text = (account == nil) ? @"" : account.password;
        password.secureTextEntry = YES;
        
        return cell;
      }
      else if (indexPath.row == kCredentialsNewUserRow)
      {
        UITableViewCell *cell = [tableView dequeueOrInit:@"IsNewAccount" cellStyle:UITableViewCellStyleDefault];        
        
        cell.textLabel.text = @"Create New Account";
        cell.accessoryView = self.isNewAccount;
        
        self.isNewAccount.on = NO;
        
        return cell;
      }
      
      return nil;
    }
      
    case kSectionUseAsDefault:
    case kSectionDeleteAccount:
    {
      UITableViewCell *cell = [tableView dequeueOrInit:@"AccountControl" cellStyle:UITableViewCellStyleDefault];
      
      if (indexPath.section == kSectionUseAsDefault)
      {
        cell.textLabel.text = @"Use as Default Account";
        
        if ([account isDefault] || markAsDefault)
          cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
          cell.accessoryType = UITableViewCellAccessoryNone;
      }
      else if (indexPath.section == kSectionDeleteAccount)
      {
        cell.textLabel.text = @"Delete This Account";
      }
      
      return cell;
    }
  }
  
  return nil;
}

@end
