import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showAddRecord = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView(showAddRecord: $showAddRecord)
                    .tabItem {
                        Label("今日", systemImage: "heart.text.square")
                    }
                    .tag(0)

                HistoryView()
                    .tabItem {
                        Label("历史", systemImage: "calendar")
                    }
                    .tag(1)

                // 占位，中间按钮
                Color.clear
                    .tabItem {
                        Label("", systemImage: "")
                    }
                    .tag(2)

                StatsView()
                    .tabItem {
                        Label("统计", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .tag(3)

                SettingsView()
                    .tabItem {
                        Label("设置", systemImage: "gearshape")
                    }
                    .tag(4)
            }
            .tint(.pink)

            // 中央浮动添加按钮
            Button {
                showAddRecord = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        LinearGradient(
                            colors: [.pink, .red.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: .pink.opacity(0.4), radius: 8, y: 4)
            }
            .offset(y: -16)
        }
        .sheet(isPresented: $showAddRecord) {
            AddRecordView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: BloodPressureRecord.self, inMemory: true)
}
