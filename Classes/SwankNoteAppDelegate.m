#import "TopLevelViewController.h"

@implementation SwankNoteAppDelegate

@synthesize window;
@synthesize navController;
@synthesize synchronizer;

#pragma mark -
#pragma mark Application lifecycle

- (void) applicationDidFinishLaunching:(UIApplication *)application 
{    
  // Override point for customization after app launch

  self.synchronizer = [[NoteSync alloc] init];
  [self.synchronizer updateNotes];

  TopLevelViewController *top = (TopLevelViewController *)navController.topViewController;
  [top initWithStyle:UITableViewStyleGrouped];
	[window addSubview:navController.view];
  
	[window makeKeyAndVisible];
  
  Note *note;
  NSString *text;
  NSString *tags;
  
  if ([AppSettings noteInProgress:&note withText:&text withTags:&tags])
  {
    [AppSettings clearNoteInProgress];
    
    if (note == nil)
      note = [NoteFilter newNote];
    
    note.text = text;
    note.tags = tags;
    
    EditNoteViewController *editor = [[[EditNoteViewController alloc] init] autorelease];
    editor.note = note;
    [top.navigationController pushViewController:editor animated:YES];
  }
}

- (void) applicationWillTerminate:(UIApplication *)application
{
}


#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender {
	
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }
}


#pragma mark -
#pragma mark Core Data stack
+ (NSManagedObjectContext *)context
{
  SwankNoteAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  return [appDelegate managedObjectContext];
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {	
  if (managedObjectContext != nil) {
    return managedObjectContext;
  }
	
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil) {
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];
    [managedObjectContext setRetainsRegisteredObjects:YES];
  }
  return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
  if (persistentStoreCoordinator != nil)
    return persistentStoreCoordinator;
	
  NSURL *storeUrl = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"SwankNote.sqlite"]];

  NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                           [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	
	NSError *error;
  
  persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
  
  if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                configuration:nil 
                                                          URL:storeUrl 
                                                      options:options
                                                        error:&error])
  {
    // Handle error
  }    
	
  return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navController release];
	
  [managedObjectContext release];
  [managedObjectModel release];
  [persistentStoreCoordinator release];
  
	[window release];
	[super dealloc];
}


@end

