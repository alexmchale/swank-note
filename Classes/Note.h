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
@property (nonatomic, retain) NSDate *swankTime;
@property (nonatomic, retain) NSNumber *dirty;

- (void)cancel;
- (void)save:(bool)markAsDirty;
- (void)save:(bool)markAsDirty updateTimestamp:(bool)updateTimestamp;
- (void)destroy;

@end
