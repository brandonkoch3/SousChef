//
//  LiveActivityViewModel.swift
//  SousChef
//
//  Created by Brandon Koch on 10/6/22.
//

import ActivityKit
import Foundation
import Combine

struct EggsBeneditConstants {
    static let containerName = "group.com.brandonk.souschefliveactivity"
}

struct EggsBeneditRecipeImages {
    static let recipeImage = "https://tastesbetterfromscratch.com/wp-content/uploads/2013/08/Eggs-Benedict-11.jpg"
    static let poachEggs = "https://www.dontgobaconmyheart.co.uk/wp-content/uploads/2017/11/perfect-poached-egg-8-1.jpg"
    static let cutEgg = "https://www.recipetineats.com/wp-content/uploads/2020/10/Poached-Eggs-SQ.jpg"
    static let eat = "https://res.cloudinary.com/hksqkdlah/image/upload/ar_1:1,c_fill,dpr_2.0,f_auto,fl_lossy.progressive.strip_profile,g_faces:auto,q_auto:low,w_344/33932_sfs-perfect-poached-eggs-22"
}

final class LiveActivityViewModel: ObservableObject {
    
    @Published public var areActivitiesAvailable = true
    
    let activityAuthorizationInfo = ActivityAuthorizationInfo()
    
    @Published var activity: Activity<SousChefTimerAttributes>?
    
    init() {
        
        // Verify the current state of Live Activities
        areActivitiesAvailable = areLiveActivitiesAvailable()
        
        // Begin monitoring for activity authorization changes
        monitorForLiveActivityAuthorizationChanges()
        
    }
    
    private func areLiveActivitiesAvailable() -> Bool {
        activityAuthorizationInfo.areActivitiesEnabled
    }
    
    private func monitorForLiveActivityAuthorizationChanges() {
        Task {
            for await activityState in activityAuthorizationInfo.activityEnablementUpdates {
                if activityState != areActivitiesAvailable {
                    await MainActor.run {
                        areActivitiesAvailable = activityState
                    }
                }
            }
        }
    }
    
    public func startLiveActivity() {
        
        // Force unwrapping the image URLs for the sake of this example.
        guard let recipeImageURL = URL(
            string: EggsBeneditRecipeImages.recipeImage)
        else { return }
        
        guard let initialStepImageURL = URL(string: EggsBeneditRecipeImages.poachEggs)
        else { return }
        
        // Setup the initial state of the recipe
        let mockFutureDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        let timerRange = Date.now...mockFutureDate
        let initialContentState = SousChefTimerAttributes.CookingTimerStatus(
            stepName: "Poach Egg",
            stepImage: initialStepImageURL,
            cookingTimer: timerRange)
        let activityAttributes = SousChefTimerAttributes(
            recipeName: "Eggs Benedict",
            recipeImageURL: recipeImageURL,
            numberOfEggsRequired: 2,
            containerName: EggsBeneditConstants.containerName)
        
        Task {
            _ = try await downloadImage(from: recipeImageURL)
            _ = try await downloadImage(from: initialStepImageURL)
        }
        
        do {
            activity = try Activity.request(
                attributes: activityAttributes,
                contentState: initialContentState)
            print("Began Live Activity for \(activityAttributes.recipeName) - Step \(initialContentState.stepName)")
        } catch {
            print("Error starting Live Activity \(error.localizedDescription).")
        }
    }
    
    public func updateLiveActivity() {
        guard let cutEggImageURL = URL(string: EggsBeneditRecipeImages.cutEgg),
              let activity
        else { return }
        
        let mockFutureDate = Calendar.current.date(byAdding: .minute, value: 2, to: Date())!
        let timerRange = Date.now...mockFutureDate
        let updatedTimerStatus = SousChefTimerAttributes.CookingTimerStatus(
            stepName: "Let Cool + Cut Eggs",
            stepImage: cutEggImageURL,
            cookingTimer: timerRange)
        
        let alertConfiguration = AlertConfiguration(
            title: "\(activity.attributes.recipeName)",
            body: "Counting down to step \(updatedTimerStatus.stepName)",
            sound: .default)
        
        Task {
            _ = try await downloadImage(from: cutEggImageURL)
            await activity.update(using: updatedTimerStatus, alertConfiguration: alertConfiguration)
        }
    }
    
    public func endLiveActivity() {
        guard let enjoyImageURL = URL(string: EggsBeneditRecipeImages.eat),
              let activity
        else { return }
        
        let finalCookingStatus = SousChefTimerAttributes.CookingTimerStatus(stepName: "Eat!", stepImage: enjoyImageURL, cookingTimer: Date.now...Date())
        
        let expirationDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        
        Task {
            _ = try await downloadImage(from: enjoyImageURL)
            await activity.end(using: finalCookingStatus, dismissalPolicy: .after(expirationDate))
            await MainActor.run {
                self.activity = nil
            }
        }
    }
    
    private func downloadImage(from url: URL) async throws -> URL? {
        guard var destination = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.example.liveactivityappgroup")
        else { return nil }
        
        destination = destination.appendingPathComponent(url.lastPathComponent)
        
        guard !FileManager.default.fileExists(atPath: destination.path()) else {
            print("No need to download \(url.lastPathComponent) as it already exists.")
            return destination
        }
        
        let (source, _) = try await URLSession.shared.download(from: url)
        try FileManager.default.moveItem(at: source, to: destination)
        print("Done downloading \(url.lastPathComponent)!")
        return destination
    }
}
