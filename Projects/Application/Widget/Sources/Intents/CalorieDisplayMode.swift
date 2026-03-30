import AppIntents

enum CalorieDisplayMode: String, AppEnum {
    case intake = "intake"
    case net = "net"

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "칼로리 표시"
    }

    static var caseDisplayRepresentations: [CalorieDisplayMode: DisplayRepresentation] {
        [
            .intake: "섭취 칼로리",
            .net: "순 칼로리 (섭취-운동)"
        ]
    }
}
