#import "Note.h"
#import "SwankNoteAppDelegate.h"

@implementation Note
@dynamic identity, swankId;
@dynamic text, tags;
@dynamic createdAt, updatedAt, swankTime, dirty;

+ (Note *)new
{
  SwankNoteAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  NSManagedObjectContext *context = [appDelegate managedObjectContext];
  Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
  note.swankId = [NSNumber numberWithInt:0];
  note.createdAt = [NSDate date];
  note.dirty = [NSNumber numberWithBool:YES];
  return note;
}

- (void)cancel
{
  SwankNoteAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  NSManagedObjectContext *context = [appDelegate managedObjectContext];
  [context rollback];
}

- (void)save:(bool)markAsDirty
{
  [self save:markAsDirty updateTimestamp:YES];
}

- (void)save:(bool)markAsDirty updateTimestamp:(bool)updateTimestamp
{
  if (updateTimestamp)
    self.updatedAt = [NSDate date];
  
  if (markAsDirty)
    self.dirty = [NSNumber numberWithBool:YES];
  
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
