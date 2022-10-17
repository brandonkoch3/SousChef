//
//  SousChefTimerAttributes.swift
//  SousChef
//
//  Created by Brandon Koch on 10/6/22.
//

import ActivityKit
import Foundation

/// An instance of the ActivityAttributes that are used to display the static and dynamic content
/// of the Live Activity.
struct SousChefTimerAttributes: ActivityAttributes {
    
    /// Typealias that references the `ContentState`, which dynamically displays content
    /// related to the countdown of the cooking item's cooked state.
    public typealias CookingTimerStatus = ContentState
    
    /// Represents the dynamic content that is displayed and updated in the Live Activity.  For example,
    /// this could refer to which step of a recipe a user is on, and the date range until the cooking is
    /// complete.
    public struct ContentState: Codable, Hashable {
        
        /// The step name from the recipe.
        var stepName: String
        
        /// An optional image to represent the recipe.
        var stepImage: URL?
        
        /// The cooking timer, referring to the time left between now and when this step of the recipe
        /// is fully cooked.
        var cookingTimer: ClosedRange<Date>
    }
    
    /// The name of the recipe, such as "Eggs Benedict."
    var recipeName: String
    
    /// An optional preview image of the recipe for rendering on the lock screen and Dynamic Island, if space permits.
    var recipeImageURL: URL?
    
    /// The number of eggs required for this recipe, such as *2*.
    var numberOfEggsRequired: Int
    
    /// A container name that will contain images passed from the parent app
    var containerName: String
    
}
