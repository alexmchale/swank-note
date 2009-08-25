//
//  IndexViewController.h
//  SwankNote
//
//  Created by Alex McHale on 8/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwankNavigator.h"
#import "NoteFilter.h"
#import "NoteSync.h"

@interface IndexViewController : SwankNavigator <UITableViewDelegate, UITableViewDataSource, NoteSyncDelegate>
{
  UITableView *table;
  NoteFilter *noteFilter;
  NoteSync *noteSync;
}

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) NoteFilter *noteFilter;
@property (nonatomic, retain) NoteSync *noteSync;

- (IBAction)composeNewMessage;
- (void)reload;

@end
