import Foundation

/// Widget 관련 중앙 관리 상수
public enum WidgetConstants {
    /// App Group ID (메인 앱 + Widget Extension 공유)
    public static let appGroupID = "group.com.junhyeok.SimpleCare"
    /// UserDefaults 키: 일일 요약 데이터
    public static let dailySummaryKey = "widget.dailySummary"
    /// Widget 번들 ID 접미사
    public static let bundleIdSuffix = "Widget"

    // MARK: - Interactive Widget Keys (W-D)
    /// UserDefaults 키: Widget에서 추가된 수분 잔 수 (pending)
    public static let waterPendingCupsKey = "widget.water.pendingCups"
    /// UserDefaults 키: Widget에서 입력된 임시 체중
    public static let weightPendingKey = "widget.weight.pending"
    /// UserDefaults 키: 임시 체중 저장 여부
    public static let weightPendingSavedKey = "widget.weight.pendingSaved"
}
