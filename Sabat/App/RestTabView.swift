import SwiftUI

struct RestTabView: View {
    @EnvironmentObject private var tabController: AppTabController

    var body: some View {
        HomeView()
            .environmentObject(tabController)
    }
}
