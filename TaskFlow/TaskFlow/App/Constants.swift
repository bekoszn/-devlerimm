//
//  Constants.swift
//  TaskFlow
//
//  Created by Berke Özgüder on 22.10.2025.
//


//
//  Constants.swift
//  TaskFlow
//

import Foundation

enum Constants {
    enum SLA {
        /// SLA uyarı eşiği (saat) – kalan süre bu değerin altına inerse “amber/kırmızı” uyarı
        static let warningThresholdHours: Int = 6
        static let criticalThresholdHours: Int = 2
    }

    enum FeatureFlags {
        static let enableOffline = true     // Step 2
        static let enableSignature = true   // Step 2
        static let enableNotifications = true
    }
}
