//
//  TUIConversationCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/16.
//

#import "TUIConversationCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TIMUserProfile+DataProvider.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "TUIKit.h"
#import "THeader.h"
#import "CreatGroupAvatar.h"
#import <ImSDK/ImSDK.h>
#import "ReactiveObjC/ReactiveObjC.h"

@implementation TUIConversationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        _headImageView = [[UIImageView alloc] init];
        [self addSubview:_headImageView];

        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor lightGrayColor];
        _timeLabel.layer.masksToBounds = YES;
        [self addSubview:_timeLabel];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.layer.masksToBounds = YES;
        [self addSubview:_titleLabel];

        _unReadView = [[TUnReadView alloc] init];
        [self addSubview:_unReadView];

        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.layer.masksToBounds = YES;
        _subTitleLabel.font = [UIFont systemFontOfSize:14];
        _subTitleLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:_subTitleLabel];

        [self setSeparatorInset:UIEdgeInsetsMake(0, TConversationCell_Margin, 0, 0)];

        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        //[self setSelectionStyle:UITableViewCellSelectionStyleDefault];
    }
    return self;
}
- (void)fillWithData:(TUIConversationCellData *)convData
{
    [super fillWithData:convData];
    self.convData = convData;

    self.timeLabel.text = [convData.time tk_messageString];
    self.subTitleLabel.text = convData.subTitle;
    [self.unReadView setNum:convData.unRead];

    if (convData.isOnTop) {
        self.backgroundColor = RGB(245, 245, 248);
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }

    @weakify(self)
    [[[RACObserve(convData, title) takeUntil:self.rac_prepareForReuseSignal]
      distinctUntilChanged] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.titleLabel.text = x;
    }];
    [[RACObserve(convData, avatarUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSURL *x) {
        @strongify(self)
        if (self.convData.convType == TIM_GROUP) { //群组
            UIImage *avatar = [self getCacheGroupAvatar];
            if (avatar != nil) { //已缓存群组头像
                self.headImageView.image = avatar;
            } else { //未缓存群组头像
                [self.headImageView sd_setImageWithURL:x
                                      placeholderImage:self.convData.avatarImage];
                [self prefetchGroupMembers];
            }
        } else {//个人头像
            [self.headImageView sd_setImageWithURL:x
                                  placeholderImage:self.convData.avatarImage];
        }
    }];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat height = [self.convData heightOfWidth:self.mm_w];
    self.mm_h = height;
    CGFloat imgHeight = height-2*(TConversationCell_Margin);

    self.headImageView.mm_width(imgHeight).mm_height(imgHeight).mm_left(TConversationCell_Margin + 3).mm_top(TConversationCell_Margin);

    if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRounded) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = imgHeight / 2;
    } else if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRadiusCorner) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = [TUIKit sharedInstance].config.avatarCornerRadius;
    }

    self.timeLabel.mm_sizeToFit().mm_top(TConversationCell_Margin_Text).mm_right(TConversationCell_Margin + 4);
    self.titleLabel.mm_sizeToFitThan(120, 30).mm_top(TConversationCell_Margin_Text - 5).mm_left(self.headImageView.mm_maxX+TConversationCell_Margin);
    self.unReadView.mm_right(TConversationCell_Margin + 4).mm_bottom(TConversationCell_Margin - 1);
    self.subTitleLabel.mm_sizeToFit().mm_left(self.titleLabel.mm_x).mm_bottom(TConversationCell_Margin_Text).mm_flexToRight(self.mm_w-self.unReadView.mm_x);
}

/// 取得群组前9个用户
- (void)prefetchGroupMembers {
    @weakify(self)
    [[TIMGroupManager sharedInstance] getGroupMembers:self.convData.convId ByFilter:TIM_GROUP_MEMBER_FILTER_ALL
                                                flags:TIM_GET_GROUP_MEM_INFO_FLAG_JOIN_TIME custom:@[@"member"]
                                              nextSeq:0 succ:^(uint64_t nextSeq, NSArray *members) {
        int i = 0;
        NSMutableArray *groupMembers = [NSMutableArray arrayWithCapacity:1];
        for (TIMGroupMemberInfo* member in members) {
            NSLog(@"member:%@",member.member);
            if (member.member.length > 0) {
                [groupMembers addObject:member.member];
                i++;
            }
            if (i == 9) {
                break;
            }
        }
        [self fetchGroupMembersAvatar:groupMembers];
    } fail:^(int code, NSString *msg) {
        @strongify(self)
        [self.headImageView sd_setImageWithURL:self.convData.avatarUrl
                              placeholderImage:self.convData.avatarImage];
    }];
}

/// 根据头像生成群组图片
/// @param members 群组用户ids
- (void)fetchGroupMembersAvatar:(NSArray*)members {
    @weakify(self)
    [[TIMFriendshipManager sharedInstance] getUsersProfile:members forceUpdate:NO
                                                      succ:^(NSArray<TIMUserProfile *> *profiles) {
        NSMutableArray *groupMemberAvatars = [NSMutableArray arrayWithCapacity:1];
        for (TIMUserProfile *profile in profiles) {
            [groupMemberAvatars addObject:profile.faceURL];
        }
        [CreatGroupAvatar createGroupAvatar:groupMemberAvatars finished:^(NSData *groupAvatar) {
            @strongify(self)
            UIImage *avatar = [UIImage imageWithData:groupAvatar];
            self.headImageView.image = avatar;
            [self cacheGroupAvatar:avatar number:(UInt32)members.count];
        }];
    } fail:^(int code, NSString *msg) {
        @strongify(self)
        [self.headImageView sd_setImageWithURL:self.convData.avatarUrl
                              placeholderImage:self.convData.avatarImage];
    }];
}

/// 缓存群组头像
/// @param avatar 图片
/// 取缓存的维度是按照会议室ID & 会议室人数来定的，
/// 人数变化取不到缓存
- (void)cacheGroupAvatar:(UIImage*)avatar number:(UInt32)memberNum {
    NSString* tempPath = NSTemporaryDirectory();
    NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%d.png",tempPath,
                          self.convData.convId,memberNum];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // check to delete old file
    NSNumber *oldValue = [defaults objectForKey:self.convData.convId];
    if ( oldValue != nil) {
        UInt32 oldMemberNum = [oldValue unsignedIntValue];
        NSString *oldFilePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%d.png",tempPath,
        self.convData.convId,oldMemberNum];
         NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:oldFilePath error:nil];
    }
    
    // Save image.
    BOOL success = [UIImagePNGRepresentation(self.headImageView.image) writeToFile:filePath atomically:YES];
    if (success) {
        [defaults setObject:@(memberNum) forKey:self.convData.convId];
    }
}

/// 获取缓存群组头像
/// 缓存的维度是按照会议室ID & 会议室人数来定的，
/// 人数变化要引起头像改变
- ( UIImage* _Nullable )getCacheGroupAvatar {
    UInt32 memberNum = [self groupMemberNum];
    NSString* tempPath = NSTemporaryDirectory();
    NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%d.png",tempPath,
                          self.convData.convId,memberNum];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    UIImage *avatar = nil;
    BOOL success = [fileManager fileExistsAtPath:filePath];

    if (success) {
        avatar= [[UIImage alloc] initWithContentsOfFile:filePath];
    }
    return avatar;
}

/// 群人数
- (UInt32)groupMemberNum {
    TIMGroupInfo *info = [[TIMGroupManager sharedInstance]
                          queryGroupInfo:self.convData.convId];
    UInt32 memberNum = info.memberNum;
    //限定1-9的范围
    memberNum = MAX(1, memberNum);
    memberNum = MIN(memberNum, 9);
    return memberNum;
}

@end
