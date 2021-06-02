//
//  KPConstants.swift
//  KnowPro
//
//  Created by John Gabelmann on 5/27/19.
//  Copyright © 2019 KnowPro. All rights reserved.
//

import Foundation

struct KPConstants {
    
    struct Contentful {
        #if DEVELOPMENT
        static let SpaceID = "yx2a49crvee2"
        static let AccessToken = "SR7hXAdV2Gi3FHJKahw5-u_HF7mOwu6S_IWsJ-n-ya0"
        #else
        static let SpaceID = "yx2a49crvee2"
        static let AccessToken = "ie8BaI5sE5jkcGX45u29e_UiXQcX0Z2wpGnxwD7S1mk"
        #endif
    }
    
    struct OneSignal {
        static let AppID = "59d1fdb1-1d5a-4049-81e6-61e1d918975e"
    }
    
    struct Color {
        static let GlobalBlack = "Global Black"
        static let GlobalYellow = "Global Yellow"
        static let GlobalGrey = "Global Grey"
        static let GlobalFaintGrey = "Global Faint Grey"
        static let LogoRed = "Logo Red"
        static let RequestSamples = "Request Samples"
        static let RequestMsl = "Request MSL"
        static let RequestLiterature = "Request Literature"
        static let RequestMarketingMaterials = "Request Marketing Materials"
        static let OtherRequest = "Other Request"
        static let SeparatorGrey = "Detail Separator Grey"
        static let TabBarTint = "Tab Bar Tint"
    }
    
    struct Defaults {
        static let LastFullScreenAd = "KP_LAST_FULL_SCREEN_AD"
        static let OnboardingComplete = "KP_ONBOARDING_COMPLETE"
        static let ProfileComplete = "KP_PROFILE_COMPLETE"
        static let PracticeInfoComplete = "KP_PRACTICE_INFO_COMPLETE"
    }
    
    struct Analytics {
        static let ViewItemUnique = "view_item_unique"
        static let ItemImpression = "item_impression"
        static let ItemImpressionUnique = "item_impression_unique"
        static let ParameterDuration = "view_duration"
    }
    
    struct Notifications {
        static let TabSelected = Notification(name: .init(rawValue: "KP_TAB_SELECTED_NOTIFICATION"))
    }
}
