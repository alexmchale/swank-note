//
//  SwankNoteAppDelegate.h
//  SwankNote
//
//  Created by Alex McHale on 8/20/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

@class SwankRootViewController;

@interface SwankNoteAppDelegate : NSObject <UIApplicationDelegate> {
	SwankRootViewController *swankRootViewController;
	
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

    UIWindow *window;
}

- (IBAction)saveAction:sender;

@property (nonatomic, retain) IBOutlet SwankRootViewController *swankRootViewController;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

