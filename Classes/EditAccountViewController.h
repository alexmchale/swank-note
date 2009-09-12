#import <Foundation/Foundation.h>

@interface EditAccountViewController : ChildViewController <UITextFieldDelegate, UIActionSheetDelegate>
{
  Account *account;
  
  UITextField *username;
  UITextField *password;
  UISwitch *isNewAccount;
}

@property (nonatomic, retain) Account *account;
@property (nonatomic, retain) UITextField *username;
@property (nonatomic, retain) UITextField *password;
@property (nonatomic, retain) UISwitch *isNewAccount;

@end
