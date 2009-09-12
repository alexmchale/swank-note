#import <Foundation/Foundation.h>

@interface UITableView (UITableViewUtilities)

- (UITableViewCell *)dequeueOrInit:(NSString *)identifier cellStyle:(UITableViewCellStyle)style;
- (UITableViewCell *)dequeueOrInitSimpleInputCell:(NSString *)identifier labelField:(UILabel **)label textField:(UITextField **)text;

@end
