#import "SwankRootViewController.h"

@implementation SwankRootViewController
@synthesize indexViewController;
@synthesize editNoteViewController;
@synthesize accountSettingsViewController;

- (void)showEditor
{
	if (self.editNoteViewController == nil)
	{
		EditNoteViewController *edit = [[EditNoteViewController alloc] initWithNibName:@"EditNoteViewController" bundle:nil];
		self.editNoteViewController = edit;
		[edit release];
	}

  [self presentModalViewController:editNoteViewController animated:YES];
}

- (void)showSettings
{
  if (self.accountSettingsViewController == nil)
  {
    AccountSettingsViewController *settings = [[AccountSettingsViewController alloc] initWithNibName:@"AccountSettingsViewController" bundle:nil];
    self.accountSettingsViewController = settings;
    [settings release];
  }
  
  [self presentModalViewController:accountSettingsViewController animated:YES];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	if (self.indexViewController == nil)
	{
		IndexViewController *index = [[IndexViewController alloc] initWithNibName:@"IndexViewController" bundle:nil];
		self.indexViewController = index;
		[index release];
	}
  
  [self.view addSubview:indexViewController.view];
  [indexViewController reload];
}

- (void)dealloc
{
	[indexViewController release];
  [editNoteViewController release];
	[super dealloc];
}

@end
