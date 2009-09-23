#import <Foundation/Foundation.h>
#import "AccountImageView.h"

@interface Account : NSManagedObject
{
}

@property (nonatomic, retain) NSNumber *swankId;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *frob;

+ (Account *) new;
+ (Account *) create:(NSString *)username withPassword:(NSString *)password error:(NSString **)errorMessage;
+ (Account *) next:(Account *)account1;
+ (NSArray *) fetchAllAccounts;
+ (Account *) fetchDefaultAccount;
+ (Account *) fetchByUsername:(NSString *)username;

- (bool) isDefault;
- (bool) testConnection:(UIView *)progressViewParent;

- (AccountImageView *) imageView;

@end
