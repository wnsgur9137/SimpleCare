import AppIntents

enum WidgetDataType: String, AppEnum {
    case calories = "calories"
    case macros = "macros"
    case exercise = "exercise"
    case weight = "weight"

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "데이터 유형"
    }

    static var caseDisplayRepresentations: [WidgetDataType: DisplayRepresentation] {
        [
            .calories: "칼로리",
            .macros: "영양소",
            .exercise: "운동",
            .weight: "체중"
        ]
    }
}
