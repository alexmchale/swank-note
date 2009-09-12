#import <UIKit/UIKit.h>
#import "ChildViewController.h"
#import "EditAccountViewController.h"

@interface AccountSettingsViewController : ChildViewController
{
  UISwitch *swankSyncEnabled;
  bool enableSync;
  NSArray *accounts;
  
  EditAccountViewController *accountEditor;
}

@property (nonatomic, retain) IBOutlet UISwitch *swankSyncEnabled;
@property bool enableSync;
@property (nonatomic, retain) NSArray *accounts;
@property (nonatomic, retain) EditAccountViewController *accountEditor;

@end
