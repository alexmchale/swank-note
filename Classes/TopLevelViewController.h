#import <Foundation/Foundation.h>
#import "EditNoteViewController.h"

@interface TopLevelViewController : UITableViewController 
{
  NSMutableArray *controllers;
  NSMutableArray *accountControllers;
  
  NSArray *recentNotes;
  EditNoteViewController *recentNoteEditor;
  
  bool multipleAccounts;
}

@property (nonatomic, retain) NSMutableArray *controllers;
@property (nonatomic, retain) NSMutableArray *accountControllers;
@property (nonatomic, retain) NSArray *recentNotes;
@property (nonatomic, retain) EditNoteViewController *recentNoteEditor;

- (void) refreshRecentNotes;

@end
