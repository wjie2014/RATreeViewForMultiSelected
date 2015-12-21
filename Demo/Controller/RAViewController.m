
//The MIT License (MIT)
//
//Copyright (c) 2014 Rafał Augustyniak
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of
//this software and associated documentation files (the "Software"), to deal in
//the Software without restriction, including without limitation the rights to
//use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//the Software, and to permit persons to whom the Software is furnished to do so,
//subject to the following conditions:
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "RAViewController.h"
#import "RATreeView.h"
#import "RADataObject.h"

#import "RATableViewCell.h"


@interface RAViewController () <RATreeViewDelegate, RATreeViewDataSource>

@property (strong, nonatomic) NSArray *data;
@property (weak, nonatomic) RATreeView *treeView;

@property (strong, nonatomic) UIBarButtonItem *editButton;

@end

@implementation RAViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirm)];
    self.navigationItem.rightBarButtonItem = anotherButton;
  [self loadData];
  
  RATreeView *treeView = [[RATreeView alloc] initWithFrame:self.view.bounds];
  
  treeView.delegate = self;
  treeView.dataSource = self;
  treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLine;
  
  [treeView reloadData];
  [treeView setBackgroundColor:[UIColor colorWithWhite:0.97 alpha:1.0]];
  
  
  self.treeView = treeView;
  [self.view insertSubview:treeView atIndex:0];
  
  [self.navigationController setNavigationBarHidden:NO];
  self.navigationItem.title = NSLocalizedString(@"Things", nil);
  [self.treeView registerNib:[UINib nibWithNibName:NSStringFromClass([RATableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([RATableViewCell class])];
}

- (void) confirm{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    for (int i=0; i<self.data.count; i++) {
        RADataObject *dataw = [self.data objectAtIndex:i];
        NSArray *childData = dataw.children;
        for (int j=0; j<childData.count; j++) {
            RADataObject *nData = [childData objectAtIndex:j];
            [arr addObject:nData];

        }
    }
    for (int j=0;j<[arr count];j++) {
        RADataObject *dataObject = [arr objectAtIndex:j];
        NSLog(@"\n选中状态＝%d；name=%@",dataObject.selected,dataObject.mName);
    }
}
- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  int systemVersion = [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue];
  if (systemVersion >= 7 && systemVersion < 8) {
    CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
    float heightPadding = statusBarViewRect.size.height+self.navigationController.navigationBar.frame.size.height;
    self.treeView.contentInset = UIEdgeInsetsMake(heightPadding, 0.0, 0.0, 0.0);
    self.treeView.contentOffset = CGPointMake(0.0, -heightPadding);
  }
  self.treeView.frame = self.view.bounds;
}


#pragma mark TreeView Delegate methods

- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item
{
  return 44;
}

- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item
{
  RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
    RADataObject *dataObject = item;
    NSInteger level = [self.treeView levelForCellForItem:item];
    if (level==1) {
        NSLog(@"展开---%d__%@",dataObject.selected,dataObject.mName);
        if (dataObject.selected==1) {
            [cell.checkBox setImage:[UIImage imageNamed:@"checkbox-marked"]];
        dataObject.selected=0;
        }else{
            [cell.checkBox setImage:[UIImage imageNamed:@"checkbox-blank-outline"]];
        dataObject.selected=1;
        }
    }else if (level==0){
        
    }
}

- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item
{

  RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
    RADataObject *dataObject = item;
    NSInteger level = [self.treeView levelForCellForItem:item];
    
    if (level==1) {
    NSLog(@"折叠---%d",dataObject.selected);
    if (dataObject.selected==0) {
        [cell.checkBox setImage:[UIImage imageNamed:@"checkbox-blank-outline"]];
        dataObject.selected=1;
    }else{
        [cell.checkBox setImage:[UIImage imageNamed:@"checkbox-marked"]];
        dataObject.selected=0;
    }
    }
    
}
#pragma mark TreeView Data Source

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item
{
  RADataObject *dataObject = item;
  NSInteger level = [self.treeView levelForCellForItem:item];
  NSInteger numberOfChildren = [dataObject.children count];
    static NSString *activityCell = @"activityCell";
    Boolean nibsRegistered = NO ;
    if(!nibsRegistered){
        UINib *nib = [UINib nibWithNibName:@"RATableViewCell" bundle:nil];
        [self.treeView registerNib:nib forCellReuseIdentifier:activityCell];
        nibsRegistered = YES;
    }
    RATableViewCell *cell = [self.treeView dequeueReusableCellWithIdentifier:activityCell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (level==1) {
        cell.titleLabel.text = @"";
        cell.customTitleLabel.text=dataObject.mName;
        if (dataObject.selected==1) {
            [cell.checkBox setImage:[UIImage imageNamed:@"checkbox-blank-outline"]];
        }else{
            [cell.checkBox setImage:[UIImage imageNamed:@"checkbox-marked"]];
        }
    }else{
        cell.titleLabel.text = dataObject.mName;
        cell.customTitleLabel.text=@"";
        [cell.checkBox setImage:[UIImage imageNamed:@""]];
    }
  return cell;
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
  if (item == nil) {
    return [self.data count];
  }
  RADataObject *data = item;
//    NSLog(@"numberOfChildrenOfItem==%@",data);
  return [data.children count];
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item
{
  RADataObject *data = item;
  if (item == nil) {
    return [self.data objectAtIndex:index];
  }
//    NSLog(@"indexofItem==%@",data);

  return data.children[index];
}

#pragma mark - Helpers 

- (void)loadData
{
    RADataObject *add = [RADataObject dataObjectWithName:@"add" children:nil isSelected:1];
    RADataObject *add1 = [RADataObject dataObjectWithName:@"add1" children:nil isSelected:1];
  RADataObject *phone = [RADataObject dataObjectWithName:@"Phones"
                                            children:[NSArray arrayWithObjects:add, add1, nil] isSelected:1];
  
  RADataObject *computer1 = [RADataObject dataObjectWithName:@"Computer 1"
                                                    children:nil isSelected:1];
  RADataObject *computer2 = [RADataObject dataObjectWithName:@"Computer 2" children:nil isSelected:1];
  RADataObject *computer3 = [RADataObject dataObjectWithName:@"Computer 3" children:nil isSelected:1];
  
  RADataObject *computer = [RADataObject dataObjectWithName:@"Computers"
                                                   children:[NSArray arrayWithObjects:computer1, computer2, computer3, nil] isSelected:1];
   self.data = [NSArray arrayWithObjects:phone, computer, nil];
}

@end
