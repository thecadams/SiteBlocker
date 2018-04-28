//
//  ContentBlockerRequestHandler.swift
//  Blocker
//
//  Created by Chris Adams on 4/17/18.
//  Copyright © 2018 cadams. All rights reserved.
//

import CoreData
import UIKit
import MobileCoreServices

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.cadams.SiteBlocker")?.appendingPathComponent("BlockerList.json")

        let attachment = NSItemProvider(contentsOf: url)!

        let item = NSExtensionItem()
        item.attachments = [attachment]
        
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }
    
}
