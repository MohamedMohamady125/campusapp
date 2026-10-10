// Trot run tracker — Live Activity widget (lock screen + Dynamic Island).
//
// NOT yet part of the Xcode build: add a Widget Extension target named
// "TrotRunActivity" and drop this file in — exact steps in
// docs/push/PUSH_SETUP.md. Until then the app silently skips Live
// Activities (see run_live_activity.dart).
//
// Data contract: the `live_activities` Flutter plugin writes the Dart map
// into the shared app group's UserDefaults, prefixing every key with the
// activity's internal id. Keys sent from Dart (run_live_activity.dart):
//   spotName, runnerName, dropoff, stage ("0"–"3"), statusLabel,
//   arrivedAtEpoch (ms, "" until the runner arrives).

import ActivityKit
import SwiftUI
import WidgetKit

// The plugin's generic attributes type (required name/shape).
struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
  public typealias LiveDeliveryData = ContentState
  public struct ContentState: Codable, Hashable {}
  var id = UUID()
}

let sharedDefault = UserDefaults(suiteName: "group.edu.campus.campusconnect.liveactivities")!

// Trot palette (docs/BRAND_BRIEF.md): coral on cream, charcoal ink.
private let trotCoral = Color(red: 0.94, green: 0.33, blue: 0.18)
private let trotInk = Color(red: 0.11, green: 0.11, blue: 0.10)
private let trotCream = Color(red: 0.99, green: 0.97, blue: 0.94)

private struct RunState {
  let spotName: String
  let runnerName: String
  let dropoff: String
  let stage: Int
  let statusLabel: String
  let arrivedAt: Date?

  init(prefix: String) {
    func str(_ key: String) -> String {
      sharedDefault.string(forKey: "\(prefix)_\(key)") ?? ""
    }
    spotName = str("spotName")
    runnerName = str("runnerName")
    dropoff = str("dropoff")
    stage = Int(str("stage")) ?? 0
    statusLabel = str("statusLabel")
    let epoch = Double(str("arrivedAtEpoch")) ?? 0
    arrivedAt = epoch > 0 ? Date(timeIntervalSince1970: epoch / 1000) : nil
  }

  /// End of the 5-minute pickup window (server NO_SHOW_WAIT).
  var pickupDeadline: Date? { arrivedAt?.addingTimeInterval(5 * 60) }
}

@main
struct TrotRunActivityBundle: WidgetBundle {
  var body: some Widget { TrotRunActivity() }
}

struct TrotRunActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
      // Lock screen / banner.
      LockScreenView(state: RunState(prefix: context.attributes.id.uuidString))
        .activityBackgroundTint(trotCream)
        .activitySystemActionForegroundColor(trotCoral)
    } dynamicIsland: { context in
      let state = RunState(prefix: context.attributes.id.uuidString)
      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Image(systemName: "figure.run")
            .font(.title2)
            .foregroundStyle(trotCoral)
        }
        DynamicIslandExpandedRegion(.trailing) {
          if let deadline = state.pickupDeadline {
            Text(timerInterval: Date()...deadline, countsDown: true)
              .monospacedDigit()
              .font(.title3.bold())
              .foregroundStyle(trotCoral)
              .frame(maxWidth: 56)
          } else {
            StageDots(stage: state.stage)
          }
        }
        DynamicIslandExpandedRegion(.bottom) {
          VStack(alignment: .leading, spacing: 4) {
            Text(state.statusLabel).font(.headline)
            Text("\(state.runnerName) · \(state.spotName) → \(state.dropoff)")
              .font(.caption)
              .foregroundStyle(.secondary)
            ProgressRail(stage: state.stage)
          }
        }
      } compactLeading: {
        Image(systemName: "figure.run").foregroundStyle(trotCoral)
      } compactTrailing: {
        if let deadline = state.pickupDeadline {
          Text(timerInterval: Date()...deadline, countsDown: true)
            .monospacedDigit()
            .font(.caption2.bold())
            .foregroundStyle(trotCoral)
            .frame(maxWidth: 40)
        } else {
          StageDots(stage: state.stage)
        }
      } minimal: {
        Image(systemName: "figure.run").foregroundStyle(trotCoral)
      }
      .keylineTint(trotCoral)
    }
  }
}

private struct LockScreenView: View {
  let state: RunState

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: "figure.run")
          .font(.title3)
          .foregroundStyle(trotCoral)
        Text(state.statusLabel)
          .font(.headline)
          .foregroundStyle(trotInk)
        Spacer()
        if let deadline = state.pickupDeadline {
          // Loud 5-minute pickup countdown — miss it and the order can be
          // marked a no-show (mirrors the in-app timer).
          Text(timerInterval: Date()...deadline, countsDown: true)
            .monospacedDigit()
            .font(.title3.bold())
            .foregroundStyle(trotCoral)
            .frame(maxWidth: 60)
        }
      }
      ProgressRail(stage: state.stage)
      Text("\(state.runnerName) · \(state.spotName) → \(state.dropoff)")
        .font(.caption)
        .foregroundStyle(trotInk.opacity(0.6))
    }
    .padding(14)
  }
}

/// 4-step rail: heading to store → at store → delivering → arrived.
private struct ProgressRail: View {
  let stage: Int

  var body: some View {
    HStack(spacing: 4) {
      ForEach(0..<4) { i in
        Capsule()
          .fill(i <= stage ? trotCoral : trotInk.opacity(0.12))
          .frame(height: 4)
      }
    }
  }
}

private struct StageDots: View {
  let stage: Int

  var body: some View {
    HStack(spacing: 3) {
      ForEach(0..<4) { i in
        Circle()
          .fill(i <= stage ? trotCoral : .gray.opacity(0.35))
          .frame(width: 5, height: 5)
      }
    }
  }
}
