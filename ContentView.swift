//
//  ContentView.swift
//  TestProject
//
//  Created by Tunde Adegoroye on 29/01/2022.
//
import SwiftUI
import MapKit
import Foundation
import UIKit
import Foundation
import TabularData
import CoreLocation

struct ContentView: View {
    @StateObject private var statNavManager = StatsNavigationManager()

    

    var body: some View {
        TabView {
                    
            StatsView()
            .tabItem {
                Label("Home", systemImage: "house")
            }
            
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
            }
            FavView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark")
            }
        }
        .environmentObject(statNavManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

private extension StatsView {
    
    var inputTxtVw: some View {
        TextField("Zip Code",
                  text: $input.zip,
                  prompt: Text("Zip Code"))
            .focused($inputFocused)
            .keyboardType(.decimalPad)
    }
    

    
    var submitBtn: some View {
        Button(action: submit) {
            Text("Submit")
            
        }
    }
}

private extension StatsView {
    
    func submit() {//what happens when you submit
        print("The city/county/zip inputted: \(input)")
        print("help:", input.zip)
        //.onAppear {
        let stringStats = test.getStats(input: input.zip)
        //}
        print(stringStats)
        resignKeyboard()
    }
    
    func resignKeyboard() {
        if #available(iOS 15, *) {
            inputFocused = false
        } else {
            dismissKeyboard()
        }
    }
}

extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
class NumbersOnly: ObservableObject {
    @Published var value = "" {
        didSet {
            let filtered = value.filter { $0.isNumber }
            
            if value != filtered {
                value = filtered
            }
        }
    }
}
enum Screens {
    case statsPage
}

extension Screens: Hashable {}

final class StatsNavigationManager: ObservableObject {
    
    @Published var screen: Screens? {
        didSet {
            print("📱 \(String(describing: screen))")
        }
    }
    
    func push(to screen: Screens) {
        self.screen = screen
    }
    
    func popToRoot() {
        self.screen = nil
    }
}
struct StatsView: View {
    let test = cityClass()
    
    //@ObservedObject var input = NumbersOnly()
    struct Input{
        var zip: String = ""
    }
    
    @State private var input: Input = .init()
    @FocusState private var inputFocused: Bool
    

    @EnvironmentObject var statNavManager: StatsNavigationManager
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.blue
                VStack {
                    inputTxtVw
                    submitBtn
                }
                .padding()
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()

                        Button("Retrieve Data") {//why does resign keyboard not work
                            statNavManager.push(to: .statsPage)
                        }
                        .background(
                        
                            NavigationLink(destination: CityView(),
                                           tag: .statsPage,
                                           selection: $statNavManager.screen) { EmptyView() }
                        )
                    }
                }
                .onSubmit(of: .text, submit)
                
               

            }
        }
    }
}
struct CityView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode

    @EnvironmentObject var statNavManager: StatsNavigationManager
    
    var body: some View {
        ZStack {
            Color.teal
            VStack {
                Text("City Statistics")
                /*Button("Go to search bar") {
                    statNavManager.popToRoot()
                }*/

                Button("Go back") {
                    if #available(iOS 15, *) {
                        dismiss()
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

/*struct MapView: View {
    
    
    var body: some View {
        Text("hello")
    }
}*/

final class ViewModel: ObservableObject {
        @Published var items = [Item]()
        @Published var showingFavs = false
        @Published var savedItems: Set<Int> = []
        
        // Filter saved items
        var filteredItems: [Item]  {
            if showingFavs {
                return items.filter { savedItems.contains($0.id) }
            }
            return items
        }
        
        private var db = Database()
        
        init() {
            self.savedItems = db.load()
            self.items = Item.sampleItems
        }
        
        func sortFavs() {
            withAnimation() {
                showingFavs.toggle()
            }
        }
        
        func contains(_ item: Item) -> Bool {
                savedItems.contains(item.id)
            }
        
        // Toggle saved items
        func toggleFav(item: Item) {
            if contains(item) {
                savedItems.remove(item.id)
            } else {
                savedItems.insert(item.id)
            }
            db.save(items: savedItems)
        }
    }

struct FavView: View {
    @StateObject private var vm = ViewModel()
    
    var body: some View {
        VStack {
            Button("Toggle Saved", action: vm.sortFavs)
                .padding()
            
            List {
                ForEach(vm.filteredItems) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.headline)
                            
                            Text(item.description)
                                .font(.subheadline)
                        }
                        Spacer()
                        Image(systemName: vm.contains(item) ? "bookmark.fill" : "bookmark")
                            .foregroundColor(.blue)
                            .onTapGesture {
                                vm.toggleFav(item: item)
                            }
                    }
                }
            }
            .cornerRadius(10)
        }
    }
}

let cityclassnt = cityClass()
var latitude_user = cityclassnt.getLocation().coordinate.latitude
var longitude_user = cityclassnt.getLocation().coordinate.longitude
struct MapView: View {


    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude_user, longitude: longitude_user), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))

    var body: some View {
        /*let cityclassnt = cityClass()
        var latitude_user = cityclassnt.getLocation().coordinate.latitude
        var longitude_user = cityclassnt.getLocation().coordinate.longitude/
*/
         //this.setCenter(CLLocationCoordinate2D(latitude: latitude_user, longitude: longitude_user), animated: false)
        //region.latitude = latitude_user
       // region.center.longitude = longitude_user
        //region = MKCoordinateRegion(center: CLLocationCoordinate2D(cityclassnt.getLocation()), span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))

        //$region.setCenter(cityclassnt.getLocation(), animated: false)
        Map(coordinateRegion: $region)
            .edgesIgnoringSafeArea(.all)
    }
    
}
