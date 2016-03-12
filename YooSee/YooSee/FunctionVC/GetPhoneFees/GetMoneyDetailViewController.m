//
//  GetMoneyDetailViewController.m
//  YooSee
//
//  Created by Shaun on 16/3/11.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "GetMoneyDetailViewController.h"
#import "YCMoneyAnimation.h"
#import <AVFoundation/AVFoundation.h>

@interface GetMoneyDetailViewController ()
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *getMoneyButton;
@property (nonatomic, strong) YCMoneyAnimation *moneyAniView;
@property (nonatomic, strong) AVAudioPlayer *avPlayer;
@end

@implementation GetMoneyDetailViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.dataDic[@"title"];
    
    [self addBackItem];
    
    // Do any additional setup after loading the view.
    [self addTableViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) tableType:UITableViewStylePlain tableDelegate:self];
    __weak typeof(self) weakSelf = self;
    self.logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.logoImageView setImageWithURL:[NSURL URLWithString:self.dataDic[@"largepic"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [weakSelf updateViews:image];
    }];
    UIView *footView = [[UIView alloc] init];
    UIView *footBg = [[UIView alloc] init];
    ;
    [footView addSubview:footBg];
    self.descLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 20, 20)];
    self.descLabel.numberOfLines = 0;
    self.descLabel.font = FONT(14);
    self.descLabel.text = [NSString stringWithFormat:@"详情介绍：\n\t%@", self.dataDic[@"info"]];
    [self.descLabel sizeToFit];
    [footView addSubview:self.descLabel];
    footBg.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.descLabel.frame.size.height + 20);
    footBg.backgroundColor = [UIColor whiteColor];
    NSString *money1 = self.dataDic[@"money1"];
    NSString *title = nil;
    
    int moneyType = [self.dataDic[@"moneytype"] intValue];
    
    if(moneyType == 2)
        title = [NSString stringWithFormat:@"立即获取亮币 +%@",money1];
    else
        title = [NSString stringWithFormat:@"立即获取金币 +%@",money1];
    
    self.getMoneyButton = [[UIButton alloc] initWithFrame:CGRectMake(40, self.descLabel.frame.size.height + 40, SCREEN_WIDTH - 80, 50)];
    [self.getMoneyButton setBackgroundImage:[UIImage imageNamed:@"zjf-bottom@2x.png"] forState:UIControlStateNormal];
    [self.getMoneyButton setTitle:title forState:UIControlStateNormal];
    [self.getMoneyButton addTarget:self action:@selector(getMoneyClick:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:self.getMoneyButton];
    footView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.descLabel.frame.size.height + 30 + 60);
    self.table.tableFooterView = footView;
}

- (void)updateViews:(UIImage*)image {
    if (!image) {
        return;
    }
    if (image.size.width == 0 || image.size.height == 0) {
        return;
    }
    CGFloat imageH = image.size.height/image.size.width*SCREEN_WIDTH;
    self.logoImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, imageH);
    self.table.tableHeaderView = self.logoImageView;
}

- (void)getMoneyClick:(UIButton*)sender {
    [self getAdRewardRequest];
}

- (void)getAdRewardRequest {
    NSString *uid = [YooSeeApplication shareApplication].uid;
    uid = uid ? uid : @"";
    NSString *ggid = self.dataDic[@"ggid"];
    ggid = ggid ? ggid : @"";
    NSDictionary *requestDic = @{@"uid":uid,@"ggid":ggid,@"grade":@"1"};
    [[RequestTool alloc] desRequestWithUrl:GET_AD_REWARD
                            requestParamas:requestDic
                               requestType:RequestTypeAsynchronous
                             requestSucess:^(AFHTTPRequestOperation *operation, id responseDic)
     {
         NSLog(@"GET_AD_REWARD===%@",responseDic);
         NSDictionary *dataDic = (NSDictionary *)responseDic;
         int errorCode = [dataDic[@"returnCode"] intValue];
         NSString *errorMessage = dataDic[@"returnMessage"];
         errorMessage = errorMessage ? errorMessage : @"";
         if (errorCode == 1)
         {
             NSString *moneyName = nil;
             switch ([self.dataDic[@"moneytype"] integerValue])
             {
                 case 1:
                     moneyName = @"积分";
                     break;
                 case 2:
                     moneyName = @"亮币";
                     break;
                 case 3:
                     moneyName = @"金币";
                     break;
                 default:
                     break;
             }
                 [self startMoneyAnimation:nil];//显示金钱下落动画
                 
                 if ([self.dataDic[@"grade"] isEqualToString:@"1"])
                 {
                     moneyName = [NSString stringWithFormat:@"您本次看一看获得%@%@",[self.dataDic objectForKey:@"money1"],moneyName];
                 }
                 else
                 {
                     moneyName = [NSString stringWithFormat:@"您本次看一看获得%@%@",[self.dataDic objectForKey:@"money2"],moneyName];
                 }
                [SVProgressHUD showSuccessWithStatus:moneyName duration:2.0];
         }
         else
         {
             [SVProgressHUD showErrorWithStatus:errorMessage duration:2.5];
         }
     }
                               requestFail:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
     }];
}

#pragma mark - 下金钱动画效果
- (void)startMoneyAnimation:(void(^)())didBlock
{
    
    if (!self.avPlayer)
    {
        NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"shake_match" ofType:@"mp3"];
        NSURL *url = [NSURL fileURLWithPath:audioPath];
        NSError *error = nil;
        AVAudioPlayer *avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [avPlayer prepareToPlay];
        [avPlayer setNumberOfLoops:0];
        [self setAvPlayer:avPlayer];
    }
    
    if (!self.moneyAniView) {
        __weak typeof(self) weakSelf = self;
        YCMoneyAnimation *moneyAn = [[YCMoneyAnimation alloc] initWithAnimation:^{
            [self.avPlayer play];
        } :nil];
        moneyAn.didAnimation = ^(){
            [weakSelf.avPlayer pause];
            [weakSelf.moneyAniView removeFromSuperview];
            if(didBlock) didBlock();
        };
        [self setMoneyAniView:moneyAn];
    }
    
    if ([self.dataDic[@"moneytype"] isEqualToString:@"3"])
    {
        [self.moneyAniView.bagView setImage:[UIImage imageNamed:@"hongbao"]];
    }
    
    [self.moneyAniView getCoinAction];
}
@end
