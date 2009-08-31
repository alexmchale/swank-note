//
//  IndexViewController.m
//  SwankNote
//
//  Created by Alex McHale on 8/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "IndexViewController.h"
#import "SwankNoteAppDelegate.h"
#import "SwankRootViewController.h"
#import "Note.h"
#import "NoteFilter.h"

@implementation IndexViewController
@synthesize noteFilter, noteSync, table;

- (void)viewDidLoad
{
  NoteFilter *newNoteFilter = [[NoteFilter alloc] initWithContext];
  self.noteFilter = newNoteFilter;
  [newNoteFilter release];
  
  NoteSync *newNoteSync = [[NoteSync alloc] init];
  self.noteSync = newNoteSync;
  [newNoteSync release];
  self.noteSync.delegate = self;
  [self.noteSync updateNotes];
  
  [self reload];
  [super viewDidLoad];
}

- (IBAction)sync
{
  [noteSync updateNotes];
}

- (IBAction)composeNewMessage
{
  [self editNewNote];
}

- (void)reload
{
  [noteFilter resetContext];
  [table reloadData];
}

- (void)viewDidUnload 
{
  self.table = nil;
  self.noteFilter = nil;
  [super viewDidUnload];
}

- (void)dealloc 
{
  [table release];
  [noteFilter release];
  [super dealloc];
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  Note *note = [noteFilter atIndex:[indexPath row]];
  [self editNote:note];
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [noteFilter count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *tableId = @"IndexTableId";
  Note *note = [noteFilter atIndex:[indexPath row]];
  NSDate *date = (NSDate *)note.updatedAt;
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableId];
  
  if (cell == nil)
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tableId] autorelease];
  
  NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
  [df setDateFormat:@"MMM d, yyyy"];
  NSString *dateText = [df stringFromDate:date];
  [df setDateFormat:@"h:mma"];
  NSString *timeText = [df stringFromDate:date];
  NSString *detailText = [[[NSString alloc] initWithFormat:@"%@ on %@", timeText, dateText] autorelease];
  
  cell.textLabel.text = note.text;
  cell.detailTextLabel.text = detailText; 
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 

  return cell;
}

- (void)noteUpdated:(Note *)note
{
  [self reload];
}

@end
