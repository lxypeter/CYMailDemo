//
//  MainMacro.h
//  ZTESoftProject
//
//  Created by YYang on 16/2/7.
//  Copyright © 2016年 YYang. All rights reserved.
//

#ifndef MainMacro_h
#define MainMacro_h

#ifdef DEBUG
#define NSLog(format, ...) printf("\n[%s] %s [第%d行] %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define NSLog(format, ...)
#endif

#pragma mark - Constants
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

#pragma mark - Message
#define MsgMailBox NSLocalizedString(@"Mail Box", nil)
#define MsgCompleted NSLocalizedString(@"Completed", nil)
#define MsgSuccess NSLocalizedString(@"Success", nil)
#define MsgReplyNForward NSLocalizedString(@"Reply/Forward", nil)
#define MsgReply NSLocalizedString(@"Reply", nil)
#define MsgForward NSLocalizedString(@"Forward", nil)
#define MsgDelete NSLocalizedString(@"Delete", nil)
#define MsgMove NSLocalizedString(@"Move", nil)
#define MsgAttachment NSLocalizedString(@"Attachment", nil)
#define MsgCancel NSLocalizedString(@"Cancel", nil)
#define MsgConfirmDelete NSLocalizedString(@"Confirm to delete the mail?", nil)
#define MsgYes NSLocalizedString(@"Yes", nil)
#define MsgNo NSLocalizedString(@"No", nil)
#define MsgFrom NSLocalizedString(@"From", nil)
#define MsgTo NSLocalizedString(@"To", nil)
#define MsgCc NSLocalizedString(@"Cc", nil)
#define MsgBcc NSLocalizedString(@"Bcc", nil)
#define MsgDate NSLocalizedString(@"Date", nil)
#define MsgLoading NSLocalizedString(@"Loading", nil)
#define MsgContent NSLocalizedString(@"Content", nil)
#define MsgPreviewInOtherApp NSLocalizedString(@"Not support to preview this kind of file, try to open in other app?", nil)
#define MsgDownloading NSLocalizedString(@"Downloading", nil)
#define MsgChooseFolder NSLocalizedString(@"Choose folder", nil)
#define MsgConfirm NSLocalizedString(@"Confirm", nil)
#define MsgConfirmFolder NSLocalizedString(@"Please choose folder you want to move to!", nil)
#define MsgSend NSLocalizedString(@"Send", nil)
#define MsgOrigin NSLocalizedString(@"Origin", nil)
#define MsgSubject NSLocalizedString(@"Subject", nil)
#define MsgSending NSLocalizedString(@"Sending", nil)
#define MsgAddrPlaceholder NSLocalizedString(@"Please seperate the address with \",\"", nil)
#define MsgContainAttachments NSLocalizedString(@"Contain attachments?", nil)


#pragma mark - Error Message
#define ErrorMsgCoreData NSLocalizedString(@"Local cache error, please refresh and try again", nil)

#pragma mark - Image name
#define ImageNaviBack @"nav_back_w"
#define ImageReply @"tab_reply"
#define ImageDelete @"tab_delete"
#define ImageMove @"tab_move"
#define ImageAttachment @"tab_attachment"
#define ImageFold @"M_Fold"
#define ImageUnfold @"M_Unfold"
#define ImageDownloaded @"download_open"
#define ImageDownload @"download_nor"
#define ImageDownloadHL @"download_pre"
#define ImageWriteMail @"send"

#endif /* MainMacro_h */
