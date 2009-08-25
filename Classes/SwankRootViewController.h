//
//  SwankRootViewController.h
//  SwankNote
//
//  Created by Alex McHale on 8/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndexViewController.h"
#import "EditNoteViewController.h"

@interface SwankRootViewController : UIViewController 
{
	IndexViewController *indexViewController;
	EditNoteViewController *editNoteViewController;
}

@property (nonatomic, retain) IBOutlet IndexViewController *indexViewController;
@property (nonatomic, retain) IBOutlet EditNoteViewController *editNoteViewController;

- (void)showEditor;

@end
