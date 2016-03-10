//
//  HomeViewController.m
//  YooSee
//
//  Created by chenlei on 16/2/17.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#define SPACE_X                     10.0 * CURRENT_SCALE
#define SPACE_Y                     15.0
#define ADV_HEIGHT                  195.0 * CURRENT_SCALE

#define SECTION_HEIGHT              15.0 * CURRENT_SCALE
#define ROW1_HEIGHT                 50.0
#define ROW2_HEIGHT                 190.0 * CURRENT_SCALE
#define ROW3_HEIGHT                 90.0
#define HEADER_LABEL_WIDTH          60.0
#define HEADER_NEW_WIDTH            240.0 * CURRENT_SCALE
#define BUTTON_TITLE_HEIGHT         30.0 * CURRENT_SCALE
#define ITEM_BUTTON_TITLE_HEIGHT    25.0 * CURRENT_SCALE

#define LINE_COLOR                  RGB(239.0,239.0,239.0)

#import "HomeViewController.h"
#import "LoginViewController.h"
#import "BannerView.h"
#import "LocalWebViewController.h"
#import "AddCameraMainViewController.h"
#import "CameraMainViewController.h"
#import "LoginViewController.h"
#import "ScanViewController.h"
#import "UserCenterMainViewController.h"
#import "GetMoneryViewController.h"

@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSArray *rowHeightArray;
@property (nonatomic, strong) BannerView *bannerView;
@property (nonatomic, strong) NSArray *bannerListArray;
@property (nonatomic, strong) UIView *headNewsView;
@property (nonatomic, strong) UILabel *headNewLabel;
@property (nonatomic, strong) NSArray *headNewsListArray;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIImageView *telephoneView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int newIndex;

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNavBarItemWithImageName:@"icon_navbar_usercenter" navItemType:LeftItem selectorName:@"userCenterButtonPressed:"];
    [self setNavBarItemWithImageName:@"icon_navbar_sys" navItemType:RightItem selectorName:@"scanButtonPressed:"];
    
    _newIndex = 0;
    _rowHeightArray = @[@(ROW1_HEIGHT),@(ROW1_HEIGHT)];
    
    if (SCREEN_HEIGHT == 480.0)
    {
        _rowHeightArray = @[@(ROW1_HEIGHT),@(ROW2_HEIGHT),@(ROW3_HEIGHT)];
    }
    
    [self initUI];
    
    //获取广告
    [self getAdvRequest];
    //获取头条消息
    [self getHeadNewsRequest];
    // Do any additional setup after loading the view.
}

#pragma mark 初始化UI
- (void)initUI
{
    [self addTableView];
    [self addTelephoneView];
}

- (void)addTableView
{
    [self addTableViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) tableType:UITableViewStylePlain tableDelegate:self];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.bounces = NO;
}

- (void)addTableViewHeader
{
//    if (_bannerView)
//    {
//        _bannerView = nil;
//        [self.table setTableHeaderView:nil];
//    }
    UIImageView *headerView = [CreateViewTool createImageViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, ADV_HEIGHT + SPACE_Y) placeholderImage:nil];
    
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:0];
    
    if (self.bannerListArray && [self.bannerListArray count] > 0)
    {
        if ([self.bannerListArray count] == 1)
        {
            self.bannerListArray = @[self.bannerListArray[0],self.bannerListArray[0],self.bannerListArray[0]];
        }
        for (NSDictionary *dataDic in self.bannerListArray)
        {
            NSString *imageUrl = dataDic[@"meitiurl"];
            imageUrl = imageUrl ? imageUrl : @"";
            if (imageUrl.length > 0)
            {
                [imageArray addObject:imageUrl];
            }
            
        }
    }
    _bannerView = [[BannerView alloc] initWithFrame:CGRectMake(SPACE_X, SPACE_Y, self.view.frame.size.width - 2 * SPACE_X, ADV_HEIGHT) WithNetImages:imageArray];
    _bannerView.AutoScrollDelay = 3;
    _bannerView.placeImage = [UIImage imageNamed:@"adv_default"];
    [CommonTool clipView:_bannerView withCornerRadius:10.0];
    [_bannerView setSmartImgdidSelectAtIndex:^(NSInteger index)
    {
        NSLog(@"网络图片 %d",index);
    }];
    [headerView addSubview:_bannerView];
    
    [self.table setTableHeaderView:headerView];
}

#pragma mark 新闻头条
- (void)initHeadNewView
{
    if (!_headNewsView)
    {
        _headNewsView = [[UIView alloc] initWithFrame:CGRectMake(SPACE_X, 0, self.table.frame.size.width - 2 * SPACE_X, ROW1_HEIGHT)];
        _headNewsView.backgroundColor = [UIColor whiteColor];
        [CommonTool clipView:_headNewsView withCornerRadius:10.0];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandle:)];
        [_headNewsView addGestureRecognizer:tapGesture];
        
        UILabel *titleLabel = [CreateViewTool createLabelWithFrame:CGRectMake(0, 0, HEADER_LABEL_WIDTH, _headNewsView.frame.size.height) textString:@"头条" textColor:[UIColor orangeColor] textFont:FONT(16.0)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [_headNewsView addSubview:titleLabel];
        
        float x = titleLabel.frame.origin.x + titleLabel.frame.size.width;
        float y = 5.0;
        float width = 2.0;
        float add_x = 10.0;
        UIImageView *lineImageView = [CreateViewTool createImageViewWithFrame:CGRectMake(x, y, width, _headNewsView.frame.size.height - 2 * y) placeholderImage:nil];
        lineImageView.backgroundColor = LINE_COLOR;
        [_headNewsView addSubview:lineImageView];
        
        x += lineImageView.frame.size.width + add_x;
        _headNewLabel = [CreateViewTool createLabelWithFrame:CGRectMake(x, 0, HEADER_NEW_WIDTH, _headNewsView.frame.size.height) textString:@"" textColor:[UIColor grayColor] textFont:FONT(16.0)];
        [_headNewsView addSubview:_headNewLabel];
    
    }
    
    if (self.headNewsListArray && [self.headNewsListArray count] > 0)
    {
        _headNewLabel.text = self.headNewsListArray[0][@"title"];
        [self creatTimer];
    }
}

- (void)creatTimer
{
    if (_timer)
    {
        return;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changeText) userInfo:nil repeats:YES];
}

- (void)changeText
{
    _newIndex = (_newIndex + 1) % [self.headNewsListArray count];
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"cube"];
    [animation setSubtype:kCATransitionFromTop];
    [_headNewLabel.layer addAnimation:animation forKey:nil];
    
    _headNewLabel.text = self.headNewsListArray[_newIndex][@"title"];
}

- (void)tapGestureHandle:(UITapGestureRecognizer *)gesture
{
    
}

#pragma mark 功能视图
- (void)initMainFunctionView
{
    if (!_mainView)
    {
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(SPACE_X, 0, self.table.frame.size.width - 2 * SPACE_X, ROW2_HEIGHT)];
        _mainView.backgroundColor = [UIColor clearColor];
        _mainView.userInteractionEnabled = YES;
        
        NSArray *imageArray = @[@"icon_home_monery",@"icon_home_camera",@"icon_home_sale"];
        NSArray *titleArray = @[@"赚钱",@"家视频",@"商家优惠"];
        NSArray *itemImageArray = @[@[@"icon_home_zxj",@"icon_home_charge"],@[@"icon_home_alert",@"icon_home_more"],@[@"icon_home_shop",@"icon_home_public"]];
        NSArray *itemTitleArray = @[@[@"抢红包",@"摇一摇"],@[@"警报",@"更多"],@[@"商城",@"发广告"]];
        UIImage *image = [UIImage imageNamed:@"icon_home_monery_up"];
        float itemWidth = (_mainView.frame.size.width - 2 * SPACE_X)/[imageArray count];
        float button_wh = image.size.width/2  * CURRENT_SCALE;
        float button_space_x = (itemWidth - button_wh)/2;
        float space_y = 10.0 * CURRENT_SCALE;
        for (int i = 0; i < [imageArray count]; i++)
        {
            UIButton *button = [CreateViewTool createButtonWithFrame:CGRectMake(button_space_x + (itemWidth + SPACE_X) * i, 0, button_wh, button_wh) buttonImage:imageArray[i] selectorName:@"functionButtonPressed:" tagDelegate:self];
            button.tag = 1 + i;
            [_mainView addSubview:button];
            
            float y = button.frame.origin.y + button_wh/3;
            UIImageView *imageView = [CreateViewTool createImageViewWithFrame:CGRectMake((itemWidth + SPACE_X) * i, y, itemWidth, _mainView.frame.size.height - y) placeholderImage:nil];
            imageView.backgroundColor = [UIColor whiteColor];
            [CommonTool clipView:imageView withCornerRadius:10.0];
            [_mainView insertSubview:imageView atIndex:0];
            
            y = button.frame.origin.y + button.frame.size.height;
            UILabel *titleLabel = [CreateViewTool createLabelWithFrame:CGRectMake(imageView.frame.origin.x, y, imageView.frame.size.width, BUTTON_TITLE_HEIGHT) textString:titleArray[i] textColor:[UIColor grayColor] textFont:FONT(16.0)];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            [_mainView addSubview:titleLabel];
            
            for (int j = 0; j < [itemImageArray[i] count]; j++)
            {
                float itemTitleLabel_width = imageView.frame.size.width/[itemImageArray[i] count];
                y = _mainView.frame.size.height - space_y - ITEM_BUTTON_TITLE_HEIGHT;
                UILabel *itemTitleLabel = [CreateViewTool createLabelWithFrame:CGRectMake(imageView.frame.origin.x + j * itemTitleLabel_width, y, itemTitleLabel_width, ITEM_BUTTON_TITLE_HEIGHT) textString:itemTitleArray[i][j] textColor:[UIColor lightGrayColor] textFont:FONT(12.0)];
                itemTitleLabel.textAlignment = NSTextAlignmentCenter;
                [_mainView addSubview:itemTitleLabel];
                
                UIImage *itemImage = [UIImage imageNamed:@"icon_home_zxj_up"];
                float item_button_wh = itemImage.size.width/2  * CURRENT_SCALE;
                float item_button_space_x = (itemWidth/2 - item_button_wh)/2.0;
                y -=  item_button_wh;
                UIButton *itemButton = [CreateViewTool createButtonWithFrame:CGRectMake(item_button_space_x + (itemWidth/2) * j + imageView.frame.origin.x, y, item_button_wh, item_button_wh) buttonImage:itemImageArray[i][j] selectorName:@"itemButtonPressed:" tagDelegate:self];
                itemButton.tag = 10 + i * 10 + j;
                [_mainView addSubview:itemButton];

            }
        }
    }
}

#pragma mark 电话视图
- (void)addTelephoneView
{
    if (!_telephoneView)
    {
        UIImage *image = [UIImage imageNamed:@"icon_home_phone_bg"];
        float width = image.size.width/2 * CURRENT_SCALE;
        float height = image.size.height/2 * CURRENT_SCALE;
        float x = (self.table.frame.size.width - width)/2;
        float y = self.table.frame.size.height - height;
        _telephoneView = [CreateViewTool createImageViewWithFrame:CGRectMake(x, y, width, height) placeholderImage:image];
        
        if (SCREEN_HEIGHT == 480.0)
        {
            y = ROW3_HEIGHT - height;
            _telephoneView.frame = CGRectMake(x, y, width, height);
        }
        else
        {
            [self.view addSubview:_telephoneView];
        }
        
        UIImage *buttonImage = [UIImage imageNamed:@"icon_home_phone_up"];
        float button_width = buttonImage.size.width/2 * CURRENT_SCALE;
        float button_height = buttonImage.size.height/2 * CURRENT_SCALE;
        x = (width - button_width)/2;
        y = x;
        UIButton *button = [CreateViewTool createButtonWithFrame:CGRectMake(x, y, button_width, button_height) buttonImage:@"icon_home_phone" selectorName:@"" tagDelegate:self];
        [_telephoneView addSubview:button];
    
    }
}


#pragma mark 获取广告
- (void)getAdvRequest
{
    __weak typeof(self) weakSelf = self;
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    int pos = 4;
    NSDictionary *requestDic = @{@"uid":uid,@"pos":@(pos)};
    [[RequestTool alloc] desRequestWithUrl:GET_ADV_URL
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"GET_ADV_URL===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         if (errorCode == 1)
         {
             //[weakSelf setDataWithDictionary:dataDic];
             weakSelf.bannerListArray = dataDic[@"body"];
             if (weakSelf.bannerListArray && [weakSelf.bannerListArray count] > 0)
             {
                 [weakSelf addTableViewHeader];
             }
         }
         else
         {
             //[SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"GET_ADV_URL====%@",error);
         //[SVProgressHUD showErrorWithStatus:LOADING_FAIL];
     }];
}

#pragma mark 获取头条消息
- (void)getHeadNewsRequest
{
    __weak typeof(self) weakSelf = self;
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    NSDictionary *requestDic = @{@"uid":uid};
    [[RequestTool alloc] desRequestWithUrl:GET_HEADNEWS_URL
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"GET_HEADNEWS_URL===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         if (errorCode == 1)
         {
             //[weakSelf setDataWithDictionary:dataDic];
             weakSelf.headNewsListArray = dataDic[@"body"];
             [weakSelf.table reloadData];
         }
         else
         {
             //[SVProgressHUD showErrorWithStatus:errorMessage];
         }
     }
     requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"GET_HEADNEWS_URL====%@",error);
         //[SVProgressHUD showErrorWithStatus:LOADING_FAIL];
     }];
}

#pragma mark 个人中心
- (void)userCenterButtonPressed:(UIButton *)sender
{
    if (![YooSeeApplication shareApplication].isLogin)
    {
        LoginViewController *loginViewController = [[LoginViewController alloc] init];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        [self presentViewController:loginNav animated:YES completion:Nil];
        return;
    }
    UserCenterMainViewController *userCenterMainViewController = [[UserCenterMainViewController alloc] init];
    userCenterMainViewController.bannerListArray = self.bannerListArray;
    [self.navigationController pushViewController:userCenterMainViewController animated:YES];
}

#pragma mark 扫描
- (void)scanButtonPressed:(UIButton *)sender
{
    ScanViewController *scanViewController = [[ScanViewController alloc] init];
    scanViewController.tipString = @"若扫描没有反应，请将二维码远离手机";
    [self.navigationController pushViewController:scanViewController animated:YES];
}

#pragma mark 功能按钮 
- (void)functionButtonPressed:(UIButton *)sender
{
    BOOL isLogin = [YooSeeApplication shareApplication].isLogin;
    if (!isLogin)
    {
        [self addLoginView];
        return;
    }
    int tag = (int)sender.tag - 1;
    UIViewController *viewController = nil;
    if (tag == 0)
    {
        GetMoneryViewController *getMoneryViewController = [[GetMoneryViewController alloc] init];
        viewController = getMoneryViewController;
    }
    if (tag == 2)
    {
        LocalWebViewController *storeDiscountViewController = [[LocalWebViewController alloc] init];
        storeDiscountViewController.urlString = @"shopsDiscount";
        viewController = storeDiscountViewController;
    }
    if (tag == 1)
    {
        //AddCameraMainViewController *addCameraMainViewController = [[AddCameraMainViewController alloc] init];
        //viewController = addCameraMainViewController;
        CameraMainViewController *cameraMainViewController = [[CameraMainViewController alloc] init];
        viewController = cameraMainViewController;
    }
    
    if (viewController)
    {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark item功能按钮
- (void)itemButtonPressed:(UIButton *)sender
{
    int type = (int)sender.tag/10;
    int tag = (int)sender.tag%10;
    //商城
    if (type == 3)
    {
        LocalWebViewController *storeDiscountViewController = [[LocalWebViewController alloc] init];
        storeDiscountViewController.urlString = (tag == 0) ? @"mall" : @"merchantRegister";
        [self.navigationController pushViewController:storeDiscountViewController animated:YES];
    }
}

#pragma mark 添加登录界面
- (void)addLoginView
{
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    [self presentViewController:nav animated:YES completion:Nil];
}


#pragma mark UITableViewDelegate&UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.rowHeightArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SECTION_HEIGHT;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.rowHeightArray[indexPath.section] floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    
    if (indexPath.section == 0)
    {
        [self initHeadNewView];
        [cell.contentView addSubview:self.headNewsView];
    }
    else if (indexPath.section == 1)
    {
        [self initMainFunctionView];
        [cell.contentView addSubview:self.mainView];
    }
    else if (indexPath.section == 2)
    {
        [self addTelephoneView];
        [cell.contentView addSubview:self.telephoneView];
    }
    

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end