/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A type representing the available options for virtual content.
*/

enum VirtualContentType: Int {
    case none
    case faceGeometry
    
    static let orderedValues: [VirtualContentType] = [.none, .faceGeometry]
    
    var imageName: String {
        switch self {
        case .none: return "none"
        case .faceGeometry: return "faceGeometry"
        }
    }
}
