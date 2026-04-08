import SwiftUI
import SwiftData

struct AddRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var systolic: Int = 120
    @State private var diastolic: Int = 80
    @State private var heartRate: Int = 72
    @State private var note: String = ""
    @State private var recordTime: Date = .now

    @State private var showTimePicker = false
    @State private var saved = false

    private let systolicRange = 60...260
    private let diastolicRange = 40...180
    private let heartRateRange = 30...220

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    levelPreview

                    pickerSection

                    timeSection

                    noteSection

                    saveButton
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("记录血压")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }

    private var levelPreview: some View {
        let level = BPLevel.evaluate(systolic: systolic, diastolic: diastolic)
        return HStack(spacing: 8) {
            Image(systemName: level.icon)
                .font(.title3)
            Text(level.rawValue)
                .font(.headline)
        }
        .foregroundStyle(level.color)
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
        .background(level.color.opacity(0.12), in: Capsule())
    }

    private var pickerSection: some View {
        VStack(spacing: 16) {
            bpPicker(label: "收缩压 (高压)", value: $systolic, range: systolicRange, unit: "mmHg", color: .red)
            bpPicker(label: "舒张压 (低压)", value: $diastolic, range: diastolicRange, unit: "mmHg", color: .blue)
            bpPicker(label: "心率", value: $heartRate, range: heartRateRange, unit: "bpm", color: .pink)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func bpPicker(label: String, value: Binding<Int>, range: ClosedRange<Int>, unit: String, color: Color) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(value.wrappedValue) \(unit)")
                    .font(.title3.bold().monospacedDigit())
                    .foregroundStyle(color)
            }

            Picker(label, selection: value) {
                ForEach(Array(range), id: \.self) { v in
                    Text("\(v)").tag(v)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 100)
            .clipped()
        }
    }

    private var timeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("测量时间")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            DatePicker(
                "测量时间",
                selection: $recordTime,
                in: ...Date.now,
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
            .datePickerStyle(.compact)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("备注（可选）")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("例如：饭后测量、运动后...", text: $note)
                .textFieldStyle(.roundedBorder)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var saveButton: some View {
        Button {
            save()
        } label: {
            HStack {
                Image(systemName: saved ? "checkmark.circle.fill" : "square.and.arrow.down")
                Text(saved ? "已保存" : "保存记录")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(saved ? .green : .pink)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(saved)
    }

    private func save() {
        let record = BloodPressureRecord(
            systolic: systolic,
            diastolic: diastolic,
            heartRate: heartRate,
            timestamp: recordTime,
            note: note
        )
        modelContext.insert(record)

        withAnimation {
            saved = true
        }

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            dismiss()
        }
    }
}

#Preview {
    AddRecordView()
        .modelContainer(for: BloodPressureRecord.self, inMemory: true)
}
