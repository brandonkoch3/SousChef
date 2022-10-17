//
//  SousChefWidgetsLiveActivity.swift
//  SousChefWidgets
//
//  Created by Brandon Koch on 10/6/22.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SousChefWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SousChefTimerAttributes.self) { context in
            
            
            HStack {
                Spacer()
                
                VStack {
                    Text("Sous Chef Timer")
                    Text(context.attributes.recipeName)
                    Text("Current Step: ") + Text(context.state.stepName)
                    
                    HStack {
                        Spacer()
                        Text(timerInterval: context.state.cookingTimer, countsDown: true, showsHours: false)
                            .contentTransition(.numericText(countsDown: true))
                    }
                    
                    
                    if let imageURL = getLocalImageURL(
                        remoteImageURL: context.state.stepImage,
                        container: context.attributes.containerName),
                       let image = UIImage(contentsOfFile: imageURL.path())
                    {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                    }
                }
                
                Spacer()
            }
            .padding()
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T")
            } minimal: {
                Text("Min")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
    
    private func getLocalImageURL(remoteImageURL: URL?, container: String) -> URL? {
        guard let remoteImageURL,
              var destination = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: container)
        else { return nil }
        
        destination = destination.appendingPathComponent(remoteImageURL.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: destination.path()) {
            return destination
        }
        return nil
    }
}
