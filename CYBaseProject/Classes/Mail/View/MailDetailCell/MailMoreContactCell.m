//
//  MailMoreContactCell.m
//  GXMoblieOA
//
//  Created by YYang on 16/3/24.
//  Copyright © 2016年 YYang. All rights reserved.
//

#import "MailMoreContactCell.h"
#import "Masonry.h"

@interface MailMoreContactCell()

@property(nonatomic,strong)NSArray*dataSource;
@property(nonatomic,strong)UIFont *font;
@property(nonatomic,assign)BOOL hasUpdatedContrains;
@property(nonatomic,strong)NSMutableArray *labels;
/**
 *  @author YYang, 16-03-25 11:03:20
 *
 *  每行第一列游标label
 */
@property(nonatomic,strong)UILabel * referenceLabel;
/**
 *  @author YYang, 16-03-25 11:03:35
 *
 *  左边一个游标 label
 */
@property(nonatomic,strong)UILabel *perLabel;
@end

@implementation MailMoreContactCell



-(instancetype)initWithDataSource:(NSArray *)dataSource andTextFont:(UIFont*)font
{
    self = [super init];
    if(self)
    {
        self.dataSource = dataSource;
        self.font = font;
        [self generateSubview];
    }
    return self;
}
#pragma mark - InitSubviews
-(void)generateSubview
{
    self.labels = [NSMutableArray array];
    for (int i = 0; i<self.dataSource.count; i++) {
        UILabel *lab = [UILabel new];
        lab.translatesAutoresizingMaskIntoConstraints = NO;
        lab.font = self.font;
        lab.textColor = [UIColor colorWithRed:0.102 green:0.596 blue:0.894 alpha:1.000];
        lab.text = self.dataSource[i];
        lab.tag = i;
        lab.textAlignment = NSTextAlignmentCenter;
        lab.adjustsFontSizeToFitWidth = YES;
        lab.minimumScaleFactor = 0.8;
        [self.contentView addSubview:lab];
        [self.labels addObject:lab];
    }

    [self setNeedsUpdateConstraints];
}


#pragma mark - CustomMethod

#pragma mark - AddConstaints
-(void)updateConstraints
{
    if(!_hasUpdatedContrains)
    {
        NSInteger count = self.labels.count;
        NSInteger rowMax = count/2;// 最大行
       for (int i = 0; i<self.labels.count; i++)
        {
            NSInteger column =i%2;//列
            NSInteger row = i/2;// 行

            UILabel *lab = self.labels[i];

            if(column == 0){
                
                [lab mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo((ScreenWidth-42)/2);
                    make.left.equalTo(self.contentView.mas_left).offset(16);
                    if (lab.tag == 0) {
                        make.top.mas_equalTo(0);
                    }else{
                        make.top.equalTo(self.referenceLabel.mas_bottom).offset(5);
                    }
                    //最后一个 和 contentview 底部约束
                    if (row==rowMax)
                    {
                        make.bottom.mas_equalTo(-15);
                    }
                }];

                //保存游标
                self.referenceLabel = lab;
                self.perLabel = lab;
            }
            else
            {
                [lab mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo((ScreenWidth-42)/2);
                    make.left.equalTo(self.perLabel.mas_right).offset(5);
                    make.centerY.equalTo(self.referenceLabel.mas_centerY);
                    //最后一个 和 contentview 底部约束
                    if (row==rowMax)
                    {
                        make.bottom.mas_equalTo(-15);
                    }
                }];
                
                //保存游标
                self.perLabel = lab;
            }
            
        }
    
        _hasUpdatedContrains = YES;
    }
    [super updateConstraints];
}




@end
