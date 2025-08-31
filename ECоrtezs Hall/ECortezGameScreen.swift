import Foundation
import SwiftUI

struct ECortezEntryScreen: View {
    @StateObject private var loader: ECortezWebLoader

    init(loader: ECortezWebLoader) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ZStack {
            ECortezWebViewBox(loader: loader)
                .opacity(loader.state == .finished ? 1 : 0.5)
            switch loader.state {
            case .progressing(let percent):
                ECortezProgressIndicator(value: percent)
            case .failure(let err):
                ECortezErrorIndicator(err: err)  // err теперь String
            case .noConnection:
                ECortezOfflineIndicator()
            default:
                EmptyView()
            }
        }
    }
}

private struct ECortezProgressIndicator: View {
    let value: Double
    var body: some View {
        GeometryReader { geo in
            ECortezLoadingOverlay(progress: value)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
        }
    }
}

private struct ECortezErrorIndicator: View {
    let err: String  // было Error, стало String
    var body: some View {
        Text("Ошибка: \(err)").foregroundColor(.red)
    }
}

private struct ECortezOfflineIndicator: View {
    var body: some View {
        Text("Нет соединения").foregroundColor(.gray)
    }
}
