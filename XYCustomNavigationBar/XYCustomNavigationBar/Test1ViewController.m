//
//  Test1ViewController.m
//  XYCustomNavigationBar
//
//  Created by Swae on 10/09/2017.
//  Copyright © 2017 com.test.demo. All rights reserved.
//

#import "Test1ViewController.h"

@interface Test1ViewController ()

@end

@implementation Test1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)push:(id)sender {
    
    UITableViewController *nextVc = [UITableViewController new];
    nextVc.view.backgroundColor = [UIColor whiteColor];
    nextVc.xy_navigationBar.backgroundColor = [UIColor colorWithRed:57/255.0 green:217/255.0 blue:146/255.0 alpha:0.8];
    
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleButton setTitle:@"table view controller" forState:UIControlStateNormal];
    nextVc.xy_navigationBar.titleView = titleButton;
    [self.navigationController pushViewController:nextVc animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}


@end
