//
//  ConstValue.h
//  BandHealth
//
//  Created by Coofeel on 15/11/30.
//  Copyright © 2015年 Coofeel. All rights reserved.
//

#ifndef ConstValue_h
#define ConstValue_h

#define MS_CLIENTID @"<Microsoft App Client ID>"
#define MS_SCOPE @"offline_access mshealth.ReadProfile mshealth.ReadActivityHistory mshealth.ReadActivityLocation mshealth.ReadDevices"
#define MS_APPSECRET @"<Microsoft App secret>"
#define MS_APP_RESULT_REDIRECT @"https://login.live.com/oauth20_desktop.srf"
#define MS_APP_TOKEN_URL @"https://login.live.com/oauth20_token.srf"
#define MS_APP_LOGINURL @"https://login.live.com/oauth20_authorize.srf?client_id=%@&scope=%@&response_type=code&redirect_uri=%@"

#define MS_APP_LOCAL_TOKEN @"MS_APP_LOCAL_TOKEN"
#define MS_APP_LOCAL_REFRESHTOKEN @"MS_APP_LOCAL_REFRESHTOKEN"

#define MS_ACTIVITY_TYPE_RUN  @"Run"

#define MS_ACTIVITY_TYPE_BIKE @"Bike"


#define MS_API_HEALTH_URL_ACTIVITIES @"me/Activities"

#define MS_API_HEALTH_HOST @"https://api.microsofthealth.net"
#define MS_API_HEALTH_VERSION @"v1"

#define FOMAT_DURATION_HOUR @"%d小时%d分%d秒"
#define FOMAT_DURATION_MINUTE @"%d分%d秒"
#define FOMAT_DURATION_SECOND @"%d秒"

#define THEME_BLUE [UIColor colorWithRed:0.0f green:90.0f/255.0f blue:161.0f/255.0f alpha:1.0f]

#endif /* ConstValue_h */
