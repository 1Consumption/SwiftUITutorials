//
//  ContentView.swift
//  Landmarks
//
//  Created by 신한섭 on 2020/11/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Turtle Rock")
                .font(.title)
            
            LocationView()
        }
        .padding()
    }
}

struct LocationView: View {
    var body: some View {
        HStack {
            Text("Joshua Tree National Park")
                .font(.subheadline)
            Spacer()
            Text("Califonia")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
