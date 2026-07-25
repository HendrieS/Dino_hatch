import WidgetKit
import SwiftUI

@main
struct DinoHatchWidgetBundle: WidgetBundle {
    var body: some Widget {
        DinoHatchCollectionWidget()
        DinoHatchQuickTimerWidget()
    }
}
