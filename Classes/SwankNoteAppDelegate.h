#import "NoteSync.h"

@class SwankRootViewController;

@interface SwankNoteAppDelegate : NSObject <UIApplicationDelegate> 
{
  UINavigationController *navController;
  
  NoteSync *synchronizer;
	
  NSManagedObjectModel *managedObjectModel;
  NSManagedObjectContext *managedObjectContext;	    
  NSPersistentStoreCoordinator *persistentStoreCoordinator;
  
  UIWindow *window;
}

+ (NSManagedObjectContext *)context;
- (IBAction)saveAction:sender;

@property (nonatomic, retain) IBOutlet UINavigationController *navController;

@property (nonatomic, retain) NoteSync *synchronizer;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

