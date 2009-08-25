#import <Foundation/Foundation.h>

@interface Note : NSManagedObject
{
}

@property (nonatomic, retain) NSNumber *identity;
@property (nonatomic, retain) NSNumber *swankId;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *tags;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;

- (void)cancel;
- (void)save;
- (void)save:(bool)updateTimestamp;
- (void)destroy;

@end
