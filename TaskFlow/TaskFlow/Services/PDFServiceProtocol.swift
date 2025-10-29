import Foundation

public protocol PDFServiceProtocol: Sendable {
    func outputURL(forTaskId id: String) -> URL
    func generateReport(for task: WorkItemSnapshot) throws -> URL
}
