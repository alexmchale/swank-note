#import <UIKit/UIKit.h>
#import "SwankNavigator.h"
#import "NoteFilter.h"
#import "NoteSync.h"

@interface IndexViewController : SwankNavigator <UITableViewDelegate, UITableViewDataSource, NoteSyncDelegate, UISearchBarDelegate>
{
  UITableView *table;
  UISearchBar *searchBar;
  NoteFilter *noteFilter;
  NoteSync *noteSync;
}

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) NoteFilter *noteFilter;
@property (nonatomic, retain) NoteSync *noteSync;

- (IBAction)sync;
- (IBAction)composeNewMessage;
- (IBAction)showSearchBar;
- (void)reload;

@end
