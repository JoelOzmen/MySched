import SwiftUI

@main
struct MySchedApp: App {
    @StateObject private var kth_vm = KTH_VM()
    
    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(kth_vm)
        }
    }
}
