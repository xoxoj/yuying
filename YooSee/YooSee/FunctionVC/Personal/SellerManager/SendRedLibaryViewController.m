//
//  SendRedLibaryViewController.m
//  YooSee
//
//  Created by 周后云 on 16/3/23.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import "SendRedLibaryViewController.h"

#import "PublishAdvertisementTableViewCell.h"

#define ContentViewHeight 80
#define CompressionRatio 0.8
#define Hud_uploadFail @"上传失败,请您重试"

typedef NS_OPTIONS(NSUInteger, ActionSheetTag) {
    ActionSheetTag_area = 1 << 0,
    ActionSheetTag_addPicture = 1 << 1,
};

typedef NS_ENUM(NSUInteger, PulishArea) {
    PulishArea_localCity = 0,
    PulishArea_localProvince,
    PulishArea_country,
};

#define CellDefaultHeight 50
#define ContentDefaultText2 @"请输入红包1内容描述文字。（选填项，可不填）"
#define ContentDefaultText3 @"请输入红包2内容描述文字。（选填项，可不填）"
#define ContentDefaultText4 @"请输入红包3内容描述文字。（选填项，可不填）"

@interface SendRedLibaryViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>

@property(nonatomic,strong)NSArray *cellTextArray;
@property(nonatomic,strong)UITextField *totalMoneyField;
@property(nonatomic,strong)UITextField *oneMoneyField;
@property(nonatomic,strong)UITextField *titleField;
@property(nonatomic,weak)IBOutlet UITableView *tableView;

@property(nonatomic,strong)UIButton *areaButton;
@property(nonatomic,strong)UIButton *endDateButton;
@property(nonatomic,strong)UIButton *startButton;

@property(nonatomic,strong)UITextView *contentView2;
@property(nonatomic,strong)UITextView *contentView3;
@property(nonatomic,strong)UITextView *contentView4;

@property(nonatomic,strong)UIImage *coverImage;
@property(nonatomic,strong)UIImage *advertisementImage1;
@property(nonatomic,strong)UIImage *advertisementImage2;
@property(nonatomic,strong)UIImage *advertisementImage3;

@property(nonatomic,strong)NSString *uuid1;
@property(nonatomic,strong)NSString *uuid2;
@property(nonatomic,strong)NSString *uuid3;
@property(nonatomic,strong)NSString *uuid4;

@property(nonatomic,strong)NSString *url1;
@property(nonatomic,strong)NSString *url2;
@property(nonatomic,strong)NSString *url3;
@property(nonatomic,strong)NSString *url4;

@property(nonatomic)NSInteger buttonTag;

@property(nonatomic)float rates;
@property(nonatomic)float commissionMoney;
@property(nonatomic)PulishArea publishArea;

@end

@implementation SendRedLibaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.type == RedLibaryType_immediate){
        self.title = @"即时红包";
        self.cellTextArray = @[@"总金额",@"红包个数",@"发布区域",@"结束时间"];
    }else if (self.type == RedLibaryType_qrCode){
        self.title = @"扫码红包";
        self.cellTextArray = @[@"总金额",@"红包个数",@"发布区域",@"结束时间"];
    }else if (self.type == RedLibaryType_shake){
        self.title = @"摇一摇红包";
        self.cellTextArray = @[@"总金额",@"红包个数",@"发布区域",@"结束时间",@"开始时间"];
    }
    
    UINib *nib = [UINib nibWithNibName:@"PublishAdvertisementTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
    [self setTableFootView];
    [self systemRateRequest];
}

#pragma mark -
-(void)setTableFootView{
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    footView.backgroundColor = VIEW_BG_COLOR;
    self.tableView.tableFooterView = footView;
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitButton setTitle:@"提交" forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:submitButton];
    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(footView.mas_top).with.offset(20);
        make.leading.equalTo(footView.mas_leading).with.offset(20);
        make.trailing.equalTo(footView.mas_trailing).with.offset(-20);
        make.height.mas_equalTo(40);
    }];
    [submitButton viewRadius:ButtonRadius_Common backgroundColor:ButtonColor_Common];
}

#pragma mark - init
-(UITextField *)totalMoneyField{
    if (!_totalMoneyField) {
        _totalMoneyField = Alloc(UITextField);
        _totalMoneyField.font = [UIFont systemFontOfSize:16];
        _totalMoneyField.placeholder = @"填写总金额";
        _totalMoneyField.width = 200;
        _totalMoneyField.height = CellDefaultHeight;
        _totalMoneyField.textAlignment = NSTextAlignmentRight;
        _totalMoneyField.keyboardType = UIKeyboardTypeDecimalPad;
        _totalMoneyField.delegate = self;
    }
    
    return _totalMoneyField;
}

-(UITextField *)oneMoneyField{
    if (!_oneMoneyField) {
        _oneMoneyField = Alloc(UITextField);
        _oneMoneyField.font = [UIFont systemFontOfSize:16];
        _oneMoneyField.placeholder = @"红包个数";
        _oneMoneyField.width = 180;
        _oneMoneyField.height = CellDefaultHeight;
        _oneMoneyField.textAlignment = NSTextAlignmentRight;
        _oneMoneyField.keyboardType = UIKeyboardTypeNumberPad;
        _oneMoneyField.delegate = self;
    }
    
    return _oneMoneyField;
}

-(UIButton *)areaButton{
    if (!_areaButton) {
        _areaButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_areaButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        NSString *string = [NSString stringWithFormat:@"本市(%@)",@"XXXX"];
        [_areaButton setTitle:string forState:UIControlStateNormal];
        _areaButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _areaButton.height = CellDefaultHeight;
        _areaButton.width = 120;
        [_areaButton addTarget:self action:@selector(areaButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _areaButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _areaButton.contentEdgeInsets = UIEdgeInsetsMake(0,0, 0, 20);
        
        UILabel *downLabel = Alloc(UILabel);
        downLabel.text = @"▼";
        downLabel.frame = CGRectMake(105, 0, 20, CellDefaultHeight);
        [_areaButton addSubview:downLabel];
    }
    
    return _areaButton;
}

-(UIButton *)endDateButton{
    if (!_endDateButton) {
        _endDateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_endDateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_endDateButton setTitle:@"2016-03-08" forState:UIControlStateNormal];
        _endDateButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _endDateButton.height = CellDefaultHeight;
        _endDateButton.width = 120;
        _endDateButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _endDateButton.contentEdgeInsets = UIEdgeInsetsMake(0,0, 0, 20);
        [_endDateButton addTarget:self action:@selector(endDateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *downLabel = Alloc(UILabel);
        downLabel.text = @"▼";
        downLabel.frame = CGRectMake(105, 0, 20, CellDefaultHeight);
        [_endDateButton addSubview:downLabel];
    }
    
    return _endDateButton;
}

-(UIButton *)startButton{
    if (!_startButton) {
        _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_startButton setTitle:@"2016-03-18" forState:UIControlStateNormal];
        _startButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _startButton.height = CellDefaultHeight;
        _startButton.width = 120;
        _startButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _startButton.contentEdgeInsets = UIEdgeInsetsMake(0,0, 0, 20);
        [_startButton addTarget:self action:@selector(startDateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *downLabel = Alloc(UILabel);
        downLabel.text = @"▼";
        downLabel.frame = CGRectMake(105, 0, 20, CellDefaultHeight);
        [_startButton addSubview:downLabel];
    }
    
    return _startButton;
}

-(UITextField *)titleField{
    if (!_titleField) {
        _titleField = Alloc(UITextField);
        _titleField.font = [UIFont systemFontOfSize:16];
        _titleField.placeholder = @"请输入红包标题(必填项)";
        _titleField.width = 200;
        _titleField.height = CellDefaultHeight;
        _titleField.textAlignment = NSTextAlignmentRight;
    }
    
    return _titleField;
}

-(UITextView *)contentView2{
    if (!_contentView2) {
        _contentView2 = Alloc(UITextView);
        _contentView2.font = [UIFont systemFontOfSize:16];
        _contentView2.text = ContentDefaultText2;
        _contentView2.textColor = [UIColor lightGrayColor];
        _contentView2.width = SCREEN_WIDTH-40;
        _contentView2.height = ContentViewHeight;
        _contentView2.delegate = self;
        _contentView2.backgroundColor = [UIColor clearColor];
    }
    
    return _contentView2;
}

-(UITextView *)contentView3{
    if (!_contentView3) {
        _contentView3 = Alloc(UITextView);
        _contentView3.font = [UIFont systemFontOfSize:16];
        _contentView3.text = ContentDefaultText3;
        _contentView3.textColor = [UIColor lightGrayColor];
        _contentView3.width = SCREEN_WIDTH-40;
        _contentView3.height = ContentViewHeight;
        _contentView3.delegate = self;
        _contentView3.backgroundColor = [UIColor clearColor];
    }
    
    return _contentView3;
}

-(UITextView *)contentView4{
    if (!_contentView4) {
        _contentView4 = Alloc(UITextView);
        _contentView4.font = [UIFont systemFontOfSize:16];
        _contentView4.text = ContentDefaultText4;
        _contentView4.textColor = [UIColor lightGrayColor];
        _contentView4.width = SCREEN_WIDTH-40;
        _contentView4.height = ContentViewHeight;
        _contentView4.delegate = self;
        _contentView4.backgroundColor = [UIColor clearColor];
    }
    
    return _contentView4;
}

#pragma mark -
-(void)areaButtonClick:(UIButton *)button{
    [self allTextFieldResignFirstResponder];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"发布区域"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"本市",@"本省", @"全国",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    actionSheet.tag = ActionSheetTag_area;
}

-(void)endDateButtonClick:(UIButton *)button{
    [self allTextFieldResignFirstResponder];
    
    
}

-(void)startDateButtonClick:(UIButton *)button{
    
}

-(void)rightItemClick:(id)sender{
    [self allTextFieldResignFirstResponder];
    
    
}

-(void)addPictureButtonClick:(UIButton *)button{
    [self allTextFieldResignFirstResponder];
    
    self.buttonTag = button.tag;
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"拍照",@"从相册中选取",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    actionSheet.tag = ActionSheetTag_addPicture;
}

-(void)submitButtonClick:(UIButton *)button{
    NSString *message;
    if (self.totalMoneyField.text.length == 0) {
        message = @"请填写总金额";
        [CommonTool addPopTipWithMessage:message];
    }else if(self.oneMoneyField.text.length == 0){
        message = @"请填写红包个数";
        [CommonTool addPopTipWithMessage:message];
    }else if (self.titleField.text.length == 0){
        message = @"请填写红包标题";
        [CommonTool addPopTipWithMessage:message];
    }else if ([self.totalMoneyField.text floatValue] < [self.oneMoneyField.text intValue]*0.01){
        message = @"总金额不够分";
        [CommonTool addPopTipWithMessage:message];
    }else if(self.coverImage == nil){
        message = @"请选择红包封面";
        [CommonTool addPopTipWithMessage:message];
    }else if(self.advertisementImage1 == nil && self.advertisementImage2 == nil && self.advertisementImage3 == nil){
        message = @"请至少选择一张红包内容图片";
        [CommonTool addPopTipWithMessage:message];
    }else if([self.totalMoneyField.text floatValue] == 0.0){
        message = @"总金额必须大于0";
        [CommonTool addPopTipWithMessage:message];
    }else if([self.oneMoneyField.text intValue] == 0){
        message = @"红包个数必须大于0";
        [CommonTool addPopTipWithMessage:message];
    }else{
        [self uploadImageRequest];
    }
}

#pragma mark -
-(void)sendSubmitRequest{
    //TODO:修改数据
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"145871915307239174" forKey:@"shop_number"];
    [dic setObject:@"1" forKey:@"area_city_role_id"];
    [dic setObject:@"2016-04-25 12:23:00" forKey:@"end_time"];
    
    [dic setObject:self.titleField.text forKey:@"content_1"];
    [dic setObject:self.totalMoneyField.text forKey:@"guanggao_money"];
    [dic setObject:[NSString stringWithFormat:@"%.2f",self.commissionMoney] forKey:@"rate_money"];
    [dic setObject:self.oneMoneyField.text forKey:@"fa_sum_number"];
    
    NSString *content2 = @"";
    if(![self.contentView2.text isEqualToString:ContentDefaultText2]){
        content2 = self.contentView2.text;
    }
    [dic setObject:content2 forKey:@"content_2"];
    
    NSString *content3 = @"";
    if(![self.contentView3.text isEqualToString:ContentDefaultText3]){
        content3 = self.contentView3.text;
    }
    [dic setObject:content3 forKey:@"content_3"];
    
    NSString *content4 = @"";
    if(![self.contentView4.text isEqualToString:ContentDefaultText4]){
        content4 = self.contentView4.text;
    }
    [dic setObject:content4 forKey:@"content_4"];
    
    if(self.url1 == nil){
        self.url1 = @"";
    }else{
        [dic setObject:self.url1 forKey:@"url_1"];
    }
    if(self.url2 == nil){
        self.url2 = @"";
    }else{
        [dic setObject:self.url2 forKey:@"url_2"];
    }
    if(self.url3 == nil){
        self.url3 = @"";
    }else{
        [dic setObject:self.url3 forKey:@"url_3"];
    }
    if(self.url4 == nil){
        self.url4 = @"";
    }else{
        [dic setObject:self.url4 forKey:@"url_4"];
    }
    
    if(self.uuid1 == nil){
        self.uuid1 = @"";
    }else{
        [dic setObject:self.uuid1 forKey:@"url_uuid_1"];
    }
    if(self.uuid2 == nil){
        self.uuid2 = @"";
    }else{
        [dic setObject:self.uuid2 forKey:@"url_uuid_2"];
    }
    if(self.uuid3 == nil){
        self.uuid3 = @"";
    }else{
        [dic setObject:self.uuid3 forKey:@"url_uuid_3"];
    }
    if(self.uuid4 == nil){
        self.uuid4 = @"";
    }else{
        [dic setObject:self.uuid4 forKey:@"url_uuid_4"];
    }
    
    NSString *urlString = Url_sendLuckRedLibary;
    
    if (self.type == RedLibaryType_qrCode) {
        urlString = Url_sendQRcodeRedLibary;
    }else if (self.type == RedLibaryType_shake){
        urlString = Url_sendShakeRedLibary;
        [dic setObject:@"2016-04-25 12:23:00" forKey:@"begin_time"];
    }
    
    NSString *aesString = [Utils aesStingDictionary:dic];
    
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:aesString forKey:@"requestmessage"];
    WeakSelf(weakSelf);

    [HttpManager postUrl:urlString parameters:requestDic success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonObject) {
        [LoadingView dismissLoadingView];
        
        ZHYBaseResponse *message = [ZHYBaseResponse yy_modelWithDictionary:jsonObject];
        if([message.returnCode intValue] == SucessFlag){
            [SVProgressHUD showSuccessWithStatus:@"上传成功"];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else if ([message.returnCode intValue] == 3){
            [SVProgressHUD showSuccessWithStatus:@"余额不足"];
        }else if ([message.returnCode intValue] == 1){
            [SVProgressHUD showSuccessWithStatus:@"参数为空"];
        }else if ([message.returnCode intValue] == 2){
            [SVProgressHUD showSuccessWithStatus:@"参数错误"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingView dismissLoadingView];
        [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
    }];
}

-(void)uploadImageRequest{
    if(![HttpManager haveNetwork]){
        [SVProgressHUD showErrorWithStatus:Hud_NoNetworkConnection];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    int totalCount = 0;
    __block int sendCount = 0;
    if (self.coverImage != nil) {
        totalCount++;
    }
    if (self.advertisementImage1 != nil) {
        totalCount++;
    }
    if (self.advertisementImage2 != nil) {
        totalCount++;
    }
    if (self.advertisementImage3 != nil) {
        totalCount++;
    }
    
    if (self.coverImage != nil) {
        NSData *data =  UIImageJPEGRepresentation(self.coverImage, CompressionRatio);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:Url_uploadImage parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:@"attach" fileName:@"image.png" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            ResponseUploadImage *response = [ResponseUploadImage yy_modelWithDictionary:responseObject];
            if ([response.returnCode intValue] == SucessFlag) {
                self.uuid1 = response.uuid;
                self.url1 = response.access_url;
                sendCount++;
                if(sendCount == totalCount){
                    [self sendSubmitRequest];
                }
            }else{
                [LoadingView dismissLoadingView];
                [SVProgressHUD showErrorWithStatus:Hud_uploadFail];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [LoadingView dismissLoadingView];
            [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
        }];
    }
    if (self.advertisementImage1 != nil) {
        NSData *data =  UIImageJPEGRepresentation(self.advertisementImage1, CompressionRatio);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:Url_uploadImage parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:@"attach" fileName:@"image.png" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            ResponseUploadImage *response = [ResponseUploadImage yy_modelWithDictionary:responseObject];
            if ([response.returnCode intValue] == SucessFlag) {
                self.uuid2 = response.uuid;
                self.url2 = response.access_url;
                sendCount++;
                if(sendCount == totalCount){
                    [self sendSubmitRequest];
                }
            }else{
                [LoadingView dismissLoadingView];
                [SVProgressHUD showErrorWithStatus:Hud_uploadFail];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [LoadingView dismissLoadingView];
            [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
        }];
    }
    if (self.advertisementImage2 != nil) {
        NSData *data =  UIImageJPEGRepresentation(self.advertisementImage2, CompressionRatio);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:Url_uploadImage parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:@"attach" fileName:@"image.png" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            ResponseUploadImage *response = [ResponseUploadImage yy_modelWithDictionary:responseObject];
            if ([response.returnCode intValue] == SucessFlag) {
                self.uuid3 = response.uuid;
                self.url3 = response.access_url;
                sendCount++;
                if(sendCount == totalCount){
                    [self sendSubmitRequest];
                }
            }else{
                [LoadingView dismissLoadingView];
                [SVProgressHUD showErrorWithStatus:Hud_uploadFail];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [LoadingView dismissLoadingView];
            [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
        }];

    }
    if (self.advertisementImage3 != nil) {
        NSData *data =  UIImageJPEGRepresentation(self.advertisementImage3, CompressionRatio);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:Url_uploadImage parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:data name:@"attach" fileName:@"image.png" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            ResponseUploadImage *response = [ResponseUploadImage yy_modelWithDictionary:responseObject];
            if ([response.returnCode intValue] == SucessFlag) {
                self.uuid4 = response.uuid;
                self.url4 = response.access_url;
                sendCount++;
                if(sendCount == totalCount){
                    [self sendSubmitRequest];
                }
            }else{
                [LoadingView dismissLoadingView];
                [SVProgressHUD showErrorWithStatus:Hud_uploadFail];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [LoadingView dismissLoadingView];
            [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
        }];
    }
}

-(void)systemRateRequest{
    if(![HttpManager haveNetwork]){
        [SVProgressHUD showErrorWithStatus:Hud_NoNetworkConnection];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [LoadingView showLoadingView];
    [HttpManager postUrl:Url_systemRate parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *jsonObject) {
        [LoadingView dismissLoadingView];
        
        if ([jsonObject[@"returnCode"] intValue] == SucessFlag) {
            NSArray *array = jsonObject[@"resultList"];
            NSDictionary *dic = [array firstObject];
            if (self.type == RedLibaryType_immediate) {
                self.rates = [dic[@"rate_hb_js"] floatValue];
            }else if (self.type == RedLibaryType_qrCode){
                self.rates = [dic[@"rate_hb_sm"] floatValue];
            }else if (self.type == RedLibaryType_shake){
                self.rates = [dic[@"rate_hb_yyy"] floatValue];
            }
            
            [self.tableView reloadData];
        }else{
            [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionError];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LoadingView dismissLoadingView];
        [SVProgressHUD showErrorWithStatus:Hud_NetworkConnectionFail];
    }];
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.cellTextArray.count;
    }else if(section == 1){
        return 1;
    }else{
        return 5;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdent = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdent];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = self.cellTextArray[indexPath.row];
        
        switch (indexPath.row) {
            case 0:{
                UIView *view = Alloc(UIView);
                view.width = self.totalMoneyField.width+20;
                view.height = CellDefaultHeight;
                [view addSubview:self.totalMoneyField];
                UILabel *label = Alloc(UILabel);
                label.text = @"元";
                label.font = [UIFont systemFontOfSize:16];
                label.textColor = [UIColor blackColor];
                label.textAlignment = NSTextAlignmentRight;
                label.frame = CGRectMake(view.width-20, 0, 20, CellDefaultHeight);
                [view addSubview:label];
                cell.accessoryView = view;
            }
                break;
                
            case 1:{
                cell.accessoryView = self.oneMoneyField;
            }
                break;
                
            case 2:{
                cell.accessoryView = self.areaButton;
            }
                break;
                
            case 3:{
                cell.accessoryView = self.endDateButton;
            }
                break;
                
            case 4:{
                cell.accessoryView = self.startButton;
            }
                
            default:
                break;
        }
    }else if(indexPath.section == 1){
        cellIdent = @"CELL1";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdent];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.commissionMoney = [self.totalMoneyField.text floatValue]*self.rates/100;
        float totalMoney = [self.totalMoneyField.text floatValue]+self.commissionMoney;
        NSString *string = [NSString stringWithFormat:@"总支付  ¥%.2f",totalMoney];
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
        UIColor *color =[ UIColor blackColor];
        [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, 6)];
        color = [UIColor redColor];
        [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(6,string.length-6)];
        cell.textLabel.attributedText = attrString;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        
        string = [NSString stringWithFormat:@"其中包含收取手续费%.2f%@,合计%.2f元",self.rates,@"%",self.commissionMoney];
        attrString = [[NSMutableAttributedString alloc] initWithString:string];
        color =[ UIColor blackColor];
        [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, 9)];
        [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(13, string.length-13)];
        color = [UIColor redColor];
        [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(9,4)];
        cell.detailTextLabel.attributedText = attrString;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    }else{
        switch (indexPath.row) {
            case 0:
            {
                cell.accessoryView = self.titleField;
                cell.textLabel.text = @"标题";
            }
                break;
                
            case 1:{
                PublishAdvertisementTableViewCell *cell = (PublishAdvertisementTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryView = nil;
                cell.titleLabel.text = @"红包封面";
                cell.contentLabel.text = @"红包内容图片";
                [cell.addPicture1 addTarget:self action:@selector(addPictureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                [cell.addPicture2 addTarget:self action:@selector(addPictureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                [cell.addPicture3 addTarget:self action:@selector(addPictureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                [cell.coverButton addTarget:self action:@selector(addPictureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                return cell;
            }
                break;
                
            case 2:{
                cell.accessoryView = self.contentView2;
            }
                break;
                
            case 3:{
                cell.accessoryView = self.contentView3;
            }
                break;
                
            case 4:{
                cell.accessoryView = self.contentView4;
            }
                break;
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = CellDefaultHeight;
    
    if(indexPath.section == 2 && indexPath.row == 1){
        height = 105;
    }else if(indexPath.section == 2 && indexPath.row == 2){
        height = ContentViewHeight;
    }else if(indexPath.section == 2 && indexPath.row == 3){
        height = ContentViewHeight;
    }else if(indexPath.section == 2 && indexPath.row == 4){
        height = ContentViewHeight;
    }else if(indexPath.section == 1){
        height = 70;
    }
    
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        if (tableView == self.tableView) {
            CGFloat cornerRadius = 5.f;
            cell.backgroundColor = UIColor.clearColor;
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGRect bounds = CGRectInset(cell.bounds, 0, 0);
            BOOL addLine = NO;
            if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
            } else if (indexPath.row == 0) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                addLine = YES;
            } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
            } else {
                CGPathAddRect(pathRef, nil, bounds);
                addLine = YES;
            }
            layer.path = pathRef;
            CFRelease(pathRef);
            layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
            
            if (addLine == YES) {
                CALayer *lineLayer = [[CALayer alloc] init];
                CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
                lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+0, bounds.size.height-lineHeight, bounds.size.width-0, lineHeight);
                lineLayer.backgroundColor = tableView.separatorColor.CGColor;
                [layer addSublayer:lineLayer];
            }
            UIView *testView = [[UIView alloc] initWithFrame:bounds];
            [testView.layer insertSublayer:layer atIndex:0];
            testView.backgroundColor = UIColor.clearColor;
            cell.backgroundView = testView;
        }
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == ActionSheetTag_area) {
        if (buttonIndex == 3) {
            return;
        }
        
        self.publishArea = buttonIndex;
        if(buttonIndex == 0){
            NSString *string = [NSString stringWithFormat:@"本市(%@)",@"ccc"];
            [self.areaButton setTitle:string forState:UIControlStateNormal];
        }else{
            [self.areaButton setTitle:[actionSheet buttonTitleAtIndex:buttonIndex] forState:UIControlStateNormal];
        }
    }else{
        if (buttonIndex == 0) {
            // 拍照
            if ([Utils isCameraAvailable] && [Utils doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                if ([Utils isFrontCameraAvailable]) {
                    controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                }
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        } else if (buttonIndex == 1) {
            // 从相册中选取
            if ([Utils isPhotoLibraryAvailable]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:2];
    PublishAdvertisementTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [picker dismissViewControllerAnimated:YES completion:^() {
        
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        switch (self.buttonTag) {
            case 1:
            {
                [cell.coverButton setImage:image forState:UIControlStateNormal];
                self.coverImage = image;
            }
                break;
                
            case 2:{
                [cell.addPicture1 setImage:image forState:UIControlStateNormal];
                self.advertisementImage1 = image;
            }
                break;
                
            case 3:{
                [cell.addPicture2 setImage:image forState:UIControlStateNormal];
                self.advertisementImage2 = image;
            }
                break;
                
            case 4:{
                [cell.addPicture3 setImage:image forState:UIControlStateNormal];
                self.advertisementImage3 = image;
            }
                break;
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == self.contentView2) {
        if([_contentView2.text isEqualToString:ContentDefaultText2]){
            _contentView2.text = @"";
        }
        _contentView2.textColor = [UIColor blackColor];
    }else if (textView == self.contentView3){
        if([_contentView3.text isEqualToString:ContentDefaultText3]){
            _contentView3.text = @"";
        }
        _contentView3.textColor = [UIColor blackColor];
    }else if (textView == self.contentView4){
        if([_contentView4.text isEqualToString:ContentDefaultText4]){
            _contentView4.text = @"";
        }
        _contentView4.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if (textView == self.contentView2) {
        if([self.contentView2.text isEqualToString:@""]){
            textView.text = ContentDefaultText2;
            textView.textColor = [UIColor lightGrayColor];
        }
    }else if (textView == self.contentView3){
        if([self.contentView3.text isEqualToString:@""]){
            textView.text = ContentDefaultText3;
            textView.textColor = [UIColor lightGrayColor];
        }
    }else if (textView == self.contentView4){
        if([self.contentView4.text isEqualToString:@""]){
            textView.text = ContentDefaultText4;
            textView.textColor = [UIColor lightGrayColor];
        }
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    NSString *willString;
    willString = [NSString stringWithFormat:@"%@%@%@",[textField.text substringToIndex:range.location],string,[textField.text substringFromIndex:range.location]];
    
    if ([willString isEqualToString:@"00"]) {
        return NO;
    }
    
    //两个小数点
    NSRange rangNow = [textField.text rangeOfString:@"."];
    if (rangNow.location != NSNotFound && [string isEqualToString:@"."]) {
        return NO;
    }
    
    //小数点超过两位
    rangNow = [willString rangeOfString:@"."];
    if (rangNow.location != NSNotFound && 3<(willString.length-rangNow.location)) {
        return NO;
    }
    
    if([willString isEqualToString:@"0"] && textField == self.oneMoneyField){
        return NO;
    }
    
    if ([willString intValue] > 99999 && textField == self.oneMoneyField) {
        return NO;
    }
    
    if ([willString floatValue] > 999999.99 && textField == self.totalMoneyField) {
        return NO;
    }
    
    return YES;
}

#pragma mark -
-(void)allTextFieldResignFirstResponder{
    [self.totalMoneyField resignFirstResponder];
    [self.oneMoneyField resignFirstResponder];
    [self.titleField resignFirstResponder];
    [self.contentView2 resignFirstResponder];
    [self.contentView3 resignFirstResponder];
    [self.contentView4 resignFirstResponder];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.totalMoneyField) {
        [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
}

@end