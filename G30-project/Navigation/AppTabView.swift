import SwiftUI

struct AppTabView: View {
    var body: some View{
        TabView{
            NavigationStack{
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }
            
            NavigationStack{
                OntarioMapView()
            }
            .tabItem {
                Label("Map", systemImage: "map.fill")
            }
            
            NavigationStack{
                NotificationsView()
            }
            .tabItem {
                Label("Alerts", systemImage: "bell.fill")
            }
        }
    }
}
