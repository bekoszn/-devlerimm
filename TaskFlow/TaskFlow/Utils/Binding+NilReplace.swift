import SwiftUI

extension Binding where Value == String? {
    init(_ source: Binding<String?>, replacingNilWith placeholder: String) {
        self.init(
            get: { source.wrappedValue ?? "" },
            set: { source.wrappedValue = $0.isEmpty ? nil : $0 }
        )
    }
}
