import SwiftUI

// MARK: - MODELS
struct AgeResult: Codable { let age: Int }
struct PetImage: Codable { let url: String }
struct InsultResult: Codable { let insult: String }

// MARK: - MAIN VIEW
struct ContentView: View {
    
    @State private var catImage = ""
    @State private var dogImage = ""
    @State private var catRoast = "Click start to roast!"
    @State private var dogRoast = "Waiting for the dog..."
    @State private var predictedAge = 0
    @State private var winnerText = "Who has the best burn?"
    @State private var isLoading = false
    @State private var tilt = CGSize.zero
    
    var body: some View {
        ZStack {
            
            // 🌌 PREMIUM BACKGROUND
            LinearGradient(
                colors: [.black, .purple.opacity(0.8), .blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Glow blobs
            Circle()
                .fill(Color.purple.opacity(0.4))
                .blur(radius: 120)
                .offset(x: -150, y: -200)
            
            Circle()
                .fill(Color.blue.opacity(0.4))
                .blur(radius: 120)
                .offset(x: 150, y: 250)
            
            Circle()
                .fill(Color.cyan.opacity(0.3))
                .blur(radius: 100)
                .offset(x: 0, y: 300)
            
            VStack(spacing: 20) {
                
                // TITLE
                Text("🔥 Pet Roast Battle")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .shadow(color: .purple, radius: 10)
                
                Text("Age Power: \(predictedAge)")
                    .foregroundColor(.cyan)
                
                // MAIN CARD
                VStack(spacing: 20) {
                    
                    HStack(spacing: 20) {
                        
                        PetColumn(
                            title: "🐱 Cat",
                            image: catImage,
                            roast: catRoast,
                            color: .orange
                        ) {
                            winnerText = "🐱 Cat destroyed the dog 💀"
                        }
                        
                        Text("VS")
                            .font(.title.bold())
                            .foregroundColor(.yellow)
                        
                        PetColumn(
                            title: "🐶 Dog",
                            image: dogImage,
                            roast: dogRoast,
                            color: .blue
                        ) {
                            winnerText = "🐶 Dog barked harder 🔥"
                        }
                    }
                    
                    Text(winnerText)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.08))
                        .background(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .rotation3DEffect(.degrees(Double(tilt.width/10)), axis: (0,1,0))
                .gesture(
                    DragGesture()
                        .onChanged { tilt = $0.translation }
                        .onEnded { _ in tilt = .zero }
                )
                
                // BUTTON
                Button(action: startBattle) {
                    Text("NEXT ROUND ⚔️")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.black)
                        .cornerRadius(15)
                        .shadow(color: .cyan.opacity(0.5), radius: 10)
                }
                .padding(.horizontal)
            }
            .padding()
            
            // LOADING OVERLAY
            if isLoading {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                        
                        Text("Summoning chaos...")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    // MARK: - FAST PARALLEL API CALLS
    func startBattle() {
        isLoading = true
        winnerText = "Generating chaos..."
        
        Task {
            async let ageTask = fetchAge()
            async let catTask = fetchCat()
            async let dogTask = fetchDog()
            async let roast1 = fetchInsult()
            async let roast2 = fetchInsult()
            
            do {
                predictedAge = try await ageTask
                catImage = try await catTask
                dogImage = try await dogTask
                catRoast = try await roast1
                dogRoast = try await roast2
                
                winnerText = "Pick your winner 👇"
            } catch {
                winnerText = "Error loading APIs ⚠️"
            }
            
            isLoading = false
        }
    }
    
    func fetchAge() async throws -> Int {
        let url = URL(string: "https://api.agify.io?name=rex")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(AgeResult.self, from: data).age
    }
    
    func fetchCat() async throws -> String {
        let url = URL(string: "https://api.thecatapi.com/v1/images/search")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([PetImage].self, from: data).first?.url ?? ""
    }
    
    func fetchDog() async throws -> String {
        let url = URL(string: "https://api.thedogapi.com/v1/images/search")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([PetImage].self, from: data).first?.url ?? ""
    }
    
    func fetchInsult() async throws -> String {
        let url = URL(string: "https://evilinsult.com/generate_insult.php?lang=en&type=json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(InsultResult.self, from: data).insult
    }
}

// MARK: - PET COLUMN
struct PetColumn: View {
    
    let title: String
    let image: String
    let roast: String
    let color: Color
    let onVote: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            
            Text(title)
                .foregroundColor(.white)
            
            AsyncImage(url: URL(string: image)) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 130, height: 130)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            Text(roast)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .frame(height: 70)
            
            Button("Winner") {
                onVote()
            }
            .padding(6)
            .background(color)
            .foregroundColor(.black)
            .cornerRadius(10)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }
}
