//
//  ContentView.swift
//  SousChef
//
//  Created by Brandon Koch on 10/6/22.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = LiveActivityViewModel()
    
    var body: some View {
        VStack {
            
            if let activity = viewModel.activity {
                Text(activity.attributes.recipeName)
                Text("Current Step: ") + Text(activity.contentState.stepName)
                Text("Time Remaining: ") + Text(timerInterval: activity.contentState.cookingTimer, countsDown: true, showsHours: false)
            }
            
            if viewModel.activity == nil {
                Text("⏲")
                    .font(.system(size: 48.0))
                    .padding(.bottom, 24.0)
            } else {
                
                AsyncImage(
                    url: viewModel.activity?.contentState.stepImage) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "photo.fill")
                        }.frame(width: 250, height: 250)
                
            }
            
            
            
            
            
            
            
            Button(action: {
                viewModel.activity == nil ? viewModel.startLiveActivity() : viewModel.updateLiveActivity()
            }) {
                viewModel.activity == nil ? Text("Start Live Activity") : Text("Update Live Activity")
            }
            
            if viewModel.activity != nil {
                Button(action: {
                    viewModel.endLiveActivity()
                }) {
                    Text("End Live Activity")
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
