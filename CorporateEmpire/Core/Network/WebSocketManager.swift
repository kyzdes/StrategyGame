//
//  WebSocketManager.swift
//  CorporateEmpire
//
//  Core - WebSocket Manager for real-time updates
//

import Foundation
import Combine

protocol WebSocketManager {
    func connect()
    func disconnect()
    func send(message: WebSocketMessage)
    func subscribe(to event: WebSocketEvent) -> AnyPublisher<WebSocketMessage, Never>
}

final class DefaultWebSocketManager: NSObject, WebSocketManager {
    private var webSocketTask: URLSessionWebSocketTask?
    private let session: URLSession
    private let url: URL

    private let messageSubject = PassthroughSubject<WebSocketMessage, Never>()
    private var cancellables = Set<AnyCancellable>()

    private var isConnected = false
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5

    init(url: URL, session: URLSession = .shared) {
        self.url = url
        self.session = session
        super.init()
    }

    func connect() {
        guard !isConnected else { return }

        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        isConnected = true
        reconnectAttempts = 0

        receiveMessage()

        print("WebSocket connected to \(url)")
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        isConnected = false
        print("WebSocket disconnected")
    }

    func send(message: WebSocketMessage) {
        guard isConnected else {
            print("WebSocket not connected, cannot send message")
            return
        }

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(message)

            if let jsonString = String(data: data, encoding: .utf8) {
                let wsMessage = URLSessionWebSocketTask.Message.string(jsonString)
                webSocketTask?.send(wsMessage) { error in
                    if let error = error {
                        print("WebSocket send error: \(error)")
                    }
                }
            }
        } catch {
            print("Failed to encode WebSocket message: \(error)")
        }
    }

    func subscribe(to event: WebSocketEvent) -> AnyPublisher<WebSocketMessage, Never> {
        return messageSubject
            .filter { message in
                // Filter messages by event type
                switch event {
                case .stockPriceUpdate(let ticker, _):
                    return message.type == .stockUpdate && message.payload.ticker == ticker
                case .orderFilled(let orderId):
                    return message.type == .orderFilled && message.payload.orderId == orderId
                case .chatMessage(let channelId, _):
                    return message.type == .chatMessage && message.payload.channelId == channelId
                default:
                    return message.type.rawValue == "\(event)"
                }
            }
            .eraseToAnyPublisher()
    }

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let message):
                self.handleMessage(message)
                // Continue receiving messages
                self.receiveMessage()

            case .failure(let error):
                print("WebSocket receive error: \(error)")
                self.handleConnectionError()
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            decodeMessage(from: text)
        case .data(let data):
            if let text = String(data: data, encoding: .utf8) {
                decodeMessage(from: text)
            }
        @unknown default:
            print("Unknown WebSocket message type")
        }
    }

    private func decodeMessage(from text: String) {
        guard let data = text.data(using: .utf8) else { return }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let message = try decoder.decode(WebSocketMessage.self, from: data)
            messageSubject.send(message)
        } catch {
            print("Failed to decode WebSocket message: \(error)")
        }
    }

    private func handleConnectionError() {
        isConnected = false

        guard reconnectAttempts < maxReconnectAttempts else {
            print("Max reconnect attempts reached")
            return
        }

        reconnectAttempts += 1
        let delay = pow(2.0, Double(reconnectAttempts)) // Exponential backoff

        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in
            print("Attempting to reconnect... (Attempt \(self?.reconnectAttempts ?? 0))")
            self?.connect()
        }
    }
}

// MARK: - WebSocket Message

struct WebSocketMessage: Codable {
    let type: MessageType
    let payload: PayloadData
    let timestamp: Date

    enum MessageType: String, Codable {
        case stockUpdate
        case orderFilled
        case orderCancelled
        case notification
        case chatMessage
        case corporationUpdate
        case friendOnline
        case marketEvent
        case achievementUnlocked
    }
}

struct PayloadData: Codable {
    var ticker: String?
    var orderId: UUID?
    var channelId: String?
    var data: [String: String]?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ticker = try container.decodeIfPresent(String.self, forKey: .ticker)
        orderId = try container.decodeIfPresent(UUID.self, forKey: .orderId)
        channelId = try container.decodeIfPresent(String.self, forKey: .channelId)
        data = try container.decodeIfPresent([String: String].self, forKey: .data)
    }

    init(
        ticker: String? = nil,
        orderId: UUID? = nil,
        channelId: String? = nil,
        data: [String: String]? = nil
    ) {
        self.ticker = ticker
        self.orderId = orderId
        self.channelId = channelId
        self.data = data
    }

    private enum CodingKeys: String, CodingKey {
        case ticker, orderId, channelId, data
    }
}

// MARK: - WebSocket Event

enum WebSocketEvent {
    case stockPriceUpdate(ticker: String, price: Decimal)
    case orderBookUpdate(ticker: String)
    case orderFilled(orderId: UUID)
    case orderCancelled(orderId: UUID)
    case friendOnline(userId: UUID)
    case corporationActivity(corporationId: UUID, activity: String)
    case chatMessage(channelId: String, message: String)
    case marketEvent(event: String)
    case achievementUnlocked(achievement: String)
    case dailyRewardAvailable
}

// MARK: - WebSocket Configuration

struct WebSocketConfiguration {
    static let url: URL = {
        #if DEBUG
        return URL(string: "wss://ws-dev.corporateempire.game")!
        #else
        return URL(string: "wss://ws.corporateempire.game")!
        #endif
    }()
}
