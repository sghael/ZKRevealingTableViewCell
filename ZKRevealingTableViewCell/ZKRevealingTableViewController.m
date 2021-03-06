//
//  ZKViewController.m
//  ZKRevealingTableViewCell
//
//  Created by Alex Zielenski on 4/29/12.
//  Copyright (c) 2012 Alex Zielenski.
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense,  and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "ZKRevealingTableViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ZKRevealingTableViewController () {
	ZKRevealingTableViewCell *_currentlyRevealedCell;
}
@property (nonatomic, strong) NSArray *objects;
@end

@implementation ZKRevealingTableViewController

@synthesize objects;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.objects = [NSArray arrayWithObjects:@"Right", @"Left", @"Both", @"None", nil];
	self.tableView = (UITableView *)self.view;
	self.tableView.rowHeight      = 52.0f;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Accessors

- (void)setCurrentlyRevealedCell:(ZKRevealingTableViewCell *)currentlyRevealedCell
{
	if (_currentlyRevealedCell == currentlyRevealedCell)
		return;
	
	[_currentlyRevealedCell setRevealing:NO];

    UILabel *starLabel = (UILabel *)_currentlyRevealedCell.revealedView.subviews[0];
    starLabel.textColor = [UIColor whiteColor];

	_currentlyRevealedCell = currentlyRevealedCell;
}

- (UIView *)revealedView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    view.autoresizesSubviews = YES;

    UILabel *starLabel = [[UILabel alloc] init];
    starLabel.text = @"★";
    starLabel.font = [UIFont boldSystemFontOfSize:30];
    starLabel.textColor = [UIColor whiteColor];
    starLabel.shadowColor = [UIColor blackColor];
    starLabel.backgroundColor = [UIColor clearColor];

    [starLabel sizeToFit];
    CGRect rect = CGRectMake(4, 0, starLabel.frame.size.width, view.frame.size.height);
    starLabel.frame = rect;
    starLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    [view addSubview:starLabel];

    return view;
}

#pragma mark - ZKRevealingTableViewCellDelegate

- (BOOL)cellShouldReveal:(ZKRevealingTableViewCell *)cell
{
	return YES;
}

- (void)cellDidReveal:(ZKRevealingTableViewCell *)cell
{
	NSLog(@"Revealed Cell with title: %@", cell.textLabel.text);
	self.currentlyRevealedCell = cell;
}

- (void)cellDidBeginPan:(ZKRevealingTableViewCell *)cell
{
	if (cell != self.currentlyRevealedCell)
		self.currentlyRevealedCell = nil;
}

- (void)cellDidPan:(ZKRevealingTableViewCell *)cell
{
    UILabel *starLabel = (UILabel *)cell.revealedView.subviews[0];
    if (cell.pannedAmount == 1) {
        starLabel.textColor = [UIColor orangeColor];
    } else {
        starLabel.textColor = [UIColor whiteColor];
    }
}

- (void)cellWillSnapBack:(ZKRevealingTableViewCell *)cell
{
    NSLog(@"Will snap back");
    self.currentlyRevealedCell = nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	self.currentlyRevealedCell = nil;
}

#pragma mark - UITableViewDataSource
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return @[ @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9" ];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return (section == 0) ? @"Bounce" : @"No Bounce";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	ZKRevealingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
	
	if (!cell) {
		cell = [[ZKRevealingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
		cell.delegate       = self;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];

        cell.revealedView = [self revealedView];

        cell.pixelsToReveal = 40;
	}
	
	cell.textLabel.text = [self.objects objectAtIndex:indexPath.row];
    switch (indexPath.row) {
        case 0:
            cell.direction = ZKRevealingTableViewCellDirectionRight;
            break;
        case 1:
            cell.direction = ZKRevealingTableViewCellDirectionLeft;
            break;
        case 2:
            cell.direction = ZKRevealingTableViewCellDirectionBoth;
            break;
        case 3:
            cell.direction = ZKRevealingTableViewCellDirectionNone;
            break;
    }
	cell.shouldBounce   = (BOOL)!indexPath.section;
    cell.shouldAutoSnapBack = indexPath.section == 0;

	return cell;
	
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger row = [indexPath row];
	if (row % 2 == 0) {
		cell.backgroundView.backgroundColor = [UIColor whiteColor];
	} else {
		cell.backgroundView.backgroundColor = [UIColor colorWithRed:0.892 green:0.893 blue:0.892 alpha:1.0];
	}
	cell.textLabel.backgroundColor = cell.backgroundView.backgroundColor;
}

@end
