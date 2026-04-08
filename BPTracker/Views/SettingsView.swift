import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var allRecords: [BloodPressureRecord]
    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section("数据") {
                    HStack {
                        Label("总记录数", systemImage: "number")
                        Spacer()
                        Text("\(allRecords.count) 条")
                            .foregroundStyle(.secondary)
                    }

                    if let first = allRecords.min(by: { $0.timestamp < $1.timestamp }) {
                        HStack {
                            Label("最早记录", systemImage: "calendar")
                            Spacer()
                            Text(RecordStore.formatDate(first.timestamp, style: "yyyy年M月d日"))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("关于") {
                    HStack {
                        Label("版本", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("适配系统", systemImage: "iphone")
                        Spacer()
                        Text("iOS 17+")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("清除所有数据", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("设置")
            .alert("确认清除", isPresented: $showDeleteAlert) {
                Button("取消", role: .cancel) {}
                Button("清除", role: .destructive) {
                    deleteAll()
                }
            } message: {
                Text("将删除所有 \(allRecords.count) 条血压记录，此操作不可撤销。")
            }
        }
    }

    private func deleteAll() {
        for record in allRecords {
            modelContext.delete(record)
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: BloodPressureRecord.self, inMemory: true)
}
