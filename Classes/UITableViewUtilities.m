#import "UITableViewUtilities.h"
#import "NSArrayUtilities.h"

@implementation UITableView (UITableViewUtilities)

- (UITableViewCell *)dequeueOrInit:(NSString *)identifier cellStyle:(UITableViewCellStyle)style
{
  UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:identifier];
  
  if (cell == nil)
    cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier];
  
  return cell;
}

- (UITableViewCell *)dequeueOrInitSimpleInputCell:(NSString *)identifier labelField:(UILabel **)label textField:(UITextField **)text
{
  UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:identifier];
  UILabel *labelField;
  UITextField *textField;
  
  if (cell == nil)
  {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    labelField = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
    [cell.contentView addSubview:labelField];
    [labelField release];
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(90, 12, 200, 25)];
    [cell.contentView addSubview:textField];
    [textField release];
  }
  else
  {
    labelField = [cell.contentView.subviews objectOfClass:[UILabel class]];
    textField = [cell.contentView.subviews objectOfClass:[UITextField class]];
  }
  
  labelField.textAlignment = UITextAlignmentRight;
  labelField.font = [UIFont boldSystemFontOfSize:14];
  
  textField.clearsOnBeginEditing = NO;
  textField.returnKeyType = UIReturnKeyDone;
  
  *label = labelField;
  *text = textField;
  
  return cell;
}

@end
