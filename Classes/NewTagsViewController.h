#import <Foundation/Foundation.h>

@interface NewTagsViewController : ChildViewController <UITextFieldDelegate>
{
  UITextField *textField;
  
  NSMutableArray *tags;
}

@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) NSMutableArray *tags;

@end
