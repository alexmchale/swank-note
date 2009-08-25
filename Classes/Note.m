#import "Note.h"
#import "SwankNoteAppDelegate.h"

@implementation Note
@dynamic identity;
@dynamic swankId;
@dynamic text;
@dynamic createdAt;
@dynamic updatedAt;

+ (Note *)new
{
  SwankNoteAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  NSManagedObjectContext *context = [appDelegate managedObjectContext];
  Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
  note.swankId = [NSNumber numberWithInt:0];
  note.createdAt = [NSDate date];
  return note;
}

- (void)cancel
{
  SwankNoteAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  NSManagedObjectContext *context = [appDelegate managedObjectContext];
  [context rollback];
}

- (void)save  
{
  [self save:YES];
}

- (void)save:(bool)updateTimestamp
{
  if (updateTimestamp)
    self.updatedAt = [NSDate date];
  
  SwankNoteAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  NSManagedObjectContext *context = [appDelegate managedObjectContext];
  [context save:nil];  
}

- (void)destroy
{
  SwankNoteAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  NSManagedObjectContext *context = [appDelegate managedObjectContext];
  [context deleteObject:self];
  
  NSError *error;
  
  if (![context save:&error] && error != nil)
  {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Note Destroy Error"
                                                    message:@"there was an error"
                                                   delegate:nil
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];

    [alert show];
    [alert release];
  }
  
  [context reset];
}

@end
