#import <Foundation/Foundation.h>

@interface Account : NSManagedObject
{
}

@property (nonatomic, retain) NSNumber *swankId;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *frob;

+ (Account *) new;
+ (Account *) create:(NSString *)username withPassword:(NSString *)password;
+ (NSArray *) fetchAllAccounts;
+ (Account *) fetchByUsername:(NSString *)username;

- (bool) isDefault;
- (bool) testConnection:(UIView *)progressViewParent;

@end
