//
//  CategoriesView.swift
//  MyLibrary
//
//  Created by Ilaria Zampella on 18/12/24.
//

import SwiftUI

struct CategoriesView: View {
    var body: some View {
        VStack {

            List {
                Text("Fiction")
                Text("Non-Fiction")
                Text("Science Fiction")
                Text("Fantasy")
                Text("Biography")
                Text("History")
            }
        }
        .navigationTitle("Categories")
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
    }
}

