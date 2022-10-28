import Foundation
import UIKit
import Foundation
import TabularData
import CoreLocation

final class cityClass{
    var convert: DataFrame = [:]
    var stats: DataFrame = [:]
    
    var location: CLLocation?
    
    func loadData() async {

    }

    func getStats(input: String) -> DataFrame.Slice{

        let columns = ["zip", "primary_city", "state", "county", "latitude", "longitude"]
        let statsColumns = ["county_name","crime_rate_per_100000","CPOPARST","CPOPCRIM", "MURDER","RAPE","ROBBERY","AGASSLT","BURGLRY","LARCENY","MVTHEFT","ARSON","population"
        ]
        do{
            let convert1 = try DataFrame(contentsOfCSVFile: URL(string: "https://raw.githubusercontent.com/shadowdragon2805/CrimeData/main/docs/csv/zip_code_database.csv")!, columns: columns, types: ["zip": .string, "primary_city": .string, "state": .string, "county": .string, "latitude": .double, "longitude": .double])
            
            convert = convert1
            
        }catch{
            Swift.print("Convert Error")
        }
        
        do{
            let stats1 = try DataFrame(contentsOfCSVFile: URL(string: "https://raw.githubusercontent.com/shadowdragon2805/CrimeData/main/docs/csv/crime_data_w_population_and_crime_rate.csv")!, columns: statsColumns)
           
            stats = stats1
        }catch{
            Swift.print("Stats Error")
        }
        

        convert.combineColumns("latitude", "longitude", into: "location") { (latitude: Double?, longitude: Double?) -> CLLocation? in guard let latitude = latitude, let longitude = longitude else{
                return nil
            }
            return CLLocation(latitude: latitude, longitude: longitude)
        }//combine columns
        var new = convert.filter(on: "zip", String.self){$0 == input}//find zip code
        var state: String = (new["state", String.self].first ?? "There was an error") ?? "There was an error"//find state
        print(new)
        var loc: CLLocation = (new["location", CLLocation.self].first ?? CLLocation(latitude: 0, longitude: 0)) ?? CLLocation(latitude: 0, longitude: 0)//make locations
        location = loc//use later

        var county: String = (new["county", String.self].first ?? "There was an error") ?? "There was an error"//find state
        print("county", county)
        var countyStats = stats.filter(on: "county_name", String.self){$0 == (county ?? "error") + ", " + state}//what I want
        
        convert = [:]
        stats = [:]
        state = " "
        county = " "

        return countyStats//return my stats


    }


    func closestCities(to location: CLLocation, in convert: DataFrame, limit: Int) -> DataFrame.Slice{
        var closestCities = convert
        closestCities.transformColumn("location") { (meterLocation: CLLocation) in meterLocation.distance(from: location)
            
        }
        closestCities.renameColumn("location", to: "distance")
        return closestCities.sorted(on: "distance", order: .ascending)[..<limit]
    }
    func callClosest() -> DataFrame.Slice{//use this to find closest
        let test = closestCities(to: location ?? CLLocation(), in: convert, limit: 10)
        return test
    }
    func getLocation() -> CLLocation{//use this to find closest
            return location ?? CLLocation(latitude: 0, longitude: 0)
        }
}
struct Item: Identifiable, Codable {
    var id: Int
    var title: String
    var description: String
    var isFaved: Bool
    
    static var sampleItems: [Item] {
        var temptList = [Item]()
        
        for i in 1...20 { // Search results
            let id = i
            let title = "Title: \(i)"
            let description = "Placeholder description."
            
            temptList.append(Item(id: id, title: title, description: description, isFaved: false))
            
        }
        return temptList
    }
}

final class Database {
    private let FAV_KEY = "fav_key"
    
    func save(items: Set<Int>) {
        let array = Array(items)
        UserDefaults.standard.set(array, forKey: FAV_KEY)
    }
    
    func load() -> Set<Int> {
        let array = UserDefaults.standard.array(forKey: FAV_KEY) as? [Int] ?? [Int]()
        return Set(array)
        
    }
}
