import SwiftUI
import PhotosUI
import UIKit

// MARK: - Models
struct Memory: Identifiable {
    let id: UUID
    let title: String
    let date: Date
    let image: UIImage
    let description: String
    var additionalImages: [UIImage]? // New property for additional images
    
    init(id: UUID = UUID(),
         title: String,
         date: Date,
         image: UIImage,
         description: String,
         additionalImages: [UIImage]? = nil) {
        self.id = id
        self.title = title
        self.date = date
        self.image = image
        self.description = description
        self.additionalImages = additionalImages
    }
}

struct Baby: Identifiable {
    let id: UUID
    let name: String
    let birthDate: Date
    let image: UIImage
    var memories: [Memory]
    let gender: Gender
    
    var age: String {
        let ageComponents = Calendar.current.dateComponents([.year, .month, .day],
                                                          from: birthDate,
                                                          to: Date())
        
        if let years = ageComponents.year, years > 0 {
            return years == 1 ? "1 year old" : "\(years) years old"
        } else if let months = ageComponents.month, months > 0 {
            return months == 1 ? "1 month old" : "\(months) months old"
        } else if let days = ageComponents.day {
            return days == 1 ? "1 day old" : "\(days) days old"
        }
        return "Just born"
    }
}

enum Gender {
    case boy, girl
}

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var selectedBabyIndex = 0
    @State private var showingSettings = false
    @State private var showingBabyPicker = false
    
    
    // Sample data with local images
    @State private var babies: [Baby] = [
        Baby(
            id: UUID(),
            name: "Aadya",
            birthDate: Calendar.current.date(byAdding: .month, value: -6, to: Date())!,
            image: UIImage(named: "baby_emma") ?? UIImage(systemName: "person.circle.fill")!,
            memories: [
                Memory(
                    id: UUID(),
                    title: "First Smile",
                    date: Date(),
                    image: UIImage(named: "emma_smile") ?? UIImage(systemName: "photo")!,
                    description: "Her first beautiful smile! 😍"
                ),
                Memory(
                    id: UUID(),
                    title: "First Crawl",
                    date: Date(),
                    image: UIImage(named: "emma_crawl") ?? UIImage(systemName: "photo")!,
                    description: "Finally! Emma started to crawl 💃"
                )
            ],
            gender: .girl
        ),
        Baby(
            id: UUID(),
            name: "Lakshya",
            birthDate: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
            image: UIImage(named: "baby_liam") ?? UIImage(systemName: "person.circle.fill")!,
            memories: [Memory(
                id: UUID(),
                title: "First Word",
                date: Date(),
                image: UIImage(named: "liam_word") ?? UIImage(systemName: "photo")!,
                description: "Liam said papa for the first time 🥰"
            )],
            gender: .boy
        ),
        Baby(
            id: UUID(),
            name: "Kaashvi",
            birthDate: Calendar.current.date(byAdding: .month, value: -9, to: Date())!,
            image: UIImage(named: "kaashvi") ?? UIImage(systemName: "person.circle.fill")!,
            memories: [],
            gender: .girl
        )
    ]
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationView {
                HomeView(
                    selectedBabyIndex: $selectedBabyIndex,
                    showingBabyPicker: $showingBabyPicker,
                    showingSettings: $showingSettings,
                    babies: $babies
                )
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            // Add Memory Tab
            NavigationView {
                AddMemoryView(
                    selectedTab: $selectedTab,
                    babies: $babies,
                    selectedBabyIndex: selectedBabyIndex
                )
            }
            .tabItem {
                Label("Add", systemImage: "plus.circle.fill")
            }
            .tag(1)
            
            // Timeline Tab
            NavigationView {
                TimelineView(
                    memories: babies[selectedBabyIndex].memories,
                    gender: babies[selectedBabyIndex].gender
                )
            }
            .tabItem {
                Label("Timeline", systemImage: "calendar")
            }
            .tag(2)
        }
        .sheet(isPresented: $showingSettings) {
            NavigationView {
                SettingsView()
                    .navigationTitle("Settings")
                    .navigationBarItems(trailing: Button("Done") {
                        showingSettings = false
                    })
            }
        }
        .actionSheet(isPresented: $showingBabyPicker) {
            ActionSheet(
                title: Text("Select Baby"),
                buttons: babies.enumerated().map { index, baby in
                    .default(Text(baby.name)) {
                        selectedBabyIndex = index
                    }
                } + [.cancel()]
            )
        }
    }
}

struct AddMemoryView: View {
    @Binding var selectedTab: Int
    @Binding var babies: [Baby]
    let selectedBabyIndex: Int
    
    @State private var title = ""
    @State private var description = ""
    @FocusState private var isDescriptionFocused: Bool
    @State private var date = Date()
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingImageSource = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var alertMessage = ""
    @State private var showingAlert = false
    private func resetForm() {
            title = ""
            description = ""
            date = Date()
            selectedImage = nil
        }
    
    var body: some View {
        Form {
            Section {
                TextField("Title", text: $title)
                    .font(.headline)
                
                DatePicker("Date", selection: $date, displayedComponents: .date)
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .focused($isDescriptionFocused)
                    
                    if description.isEmpty && !isDescriptionFocused {
                        Text("Write something about this memory...")
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                    }
                }
            } header: {
                Text("Memory Details")
            }
            
            Section {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button(action: { showingImageSource = true }) {
                    HStack {
                        Image(systemName: selectedImage == nil ? "camera.fill" : "arrow.triangle.2.circlepath")
                        Text(selectedImage == nil ? "Add Photo" : "Change Photo")
                    }
                    .foregroundColor(Theme.color(for: babies[selectedBabyIndex].gender))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            } header: {
                Text("Photo")
            }
            
            Section {
                Button(action: saveMemory) {
                    Text("Save Memory")
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Theme.color(for: babies[selectedBabyIndex].gender))
                        )
                }
                .disabled(title.isEmpty || selectedImage == nil)
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("New Memory")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    selectedTab = 0
                }
            }
        }
        .actionSheet(isPresented: $showingImageSource) {
            ActionSheet(
                title: Text("Choose Photo"),
                buttons: [
                    .default(Text("Take Photo")) {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            sourceType = .camera
                            showingImagePicker = true
                        } else {
                            alertMessage = "Camera is not available"
                            showingAlert = true
                        }
                    },
                    .default(Text("Choose from Library")) {
                        sourceType = .photoLibrary
                        showingImagePicker = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: sourceType)
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveMemory() {
        guard let image = selectedImage else { return }
        
        let newMemory = Memory(
            title: title,
            date: date,
            image: image,
            description: description.isEmpty ? "No description" : description
        )
        
        var updatedBabies = babies
        updatedBabies[selectedBabyIndex].memories.insert(newMemory, at: 0)
        babies = updatedBabies
        resetForm()
        selectedTab = 0
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                 didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
struct Theme {
    static func color(for gender: Gender) -> Color {
        switch gender {
        case .girl:
            return Color(red: 255/255, green: 140/255, blue: 170/255) // Softer pink
        case .boy:
            return Color(red: 100/255, green: 180/255, blue: 255/255) // Softer blue
        }
    }
    
    static func gradient(for gender: Gender) -> LinearGradient {
        switch gender {
        case .girl:
            return LinearGradient(
                colors: [
                    Color(red: 255/255, green: 140/255, blue: 170/255),
                    Color(red: 255/255, green: 182/255, blue: 193/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .boy:
            return LinearGradient(
                colors: [
                    Color(red: 100/255, green: 180/255, blue: 255/255),
                    Color(red: 135/255, green: 206/255, blue: 250/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    static func secondaryColor(for gender: Gender) -> Color {
        switch gender {
        case .girl:
            return Color(red: 255/255, green: 182/255, blue: 193/255).opacity(0.3) // Light pink
        case .boy:
            return Color(red: 135/255, green: 206/255, blue: 250/255).opacity(0.3) // Light blue
        }
    }
}

struct BabyProfileCard: View {
    let baby: Baby
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Profile Image
            Image(uiImage: baby.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(color: Color.black.opacity(0.1),
                        radius: 10, x: 0, y: 5)
            
            // Name and Age
            VStack(spacing: 8) {
                Text(baby.name)
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text(baby.age)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            // Change Profile Button
            Button(action: action) {
                Text("Change Profile")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .stroke(Color.white, lineWidth: 1.5)
                    )
            }
        }
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Theme.gradient(for: baby.gender))
        )
        .padding(.horizontal, 20)
        .shadow(color: Theme.color(for: baby.gender).opacity(0.3),
                radius: 15, x: 0, y: 5)
    }
}

struct HomeView: View {
    @Binding var selectedBabyIndex: Int
    @Binding var showingBabyPicker: Bool
    @Binding var showingSettings: Bool
    @Binding var babies: [Baby]
    
    private var recentMemories: [Memory] {
            babies[selectedBabyIndex].memories
                .sorted { $0.date > $1.date } // Descending order
                .prefix(3) // Only take the 3 most recent
                .map { $0 }
        }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Baby Profile Card
                BabyProfileCard(
                    baby: babies[selectedBabyIndex],
                    action: { showingBabyPicker = true }
                )
                .padding(.top, 10)
                
                // Content Sections
                VStack(spacing: 24) {
                    // Recent Memories Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Recent Memories")
                        
                        if babies[selectedBabyIndex].memories.isEmpty {
                            EmptyStateView(
                                icon: "photo.on.rectangle.angled",
                                message: "No memories yet.\nTap + to add your first memory!"
                            )
                        } else{
                            ForEach(recentMemories) { memory in
                                RecentMemoryView(memory: memory, gender: babies[selectedBabyIndex].gender)
                            }
                        }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Baby Info Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Baby Info")
                        InfoCard(baby: babies[selectedBabyIndex])
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 24)
            }
        
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Little Moments")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gear")
                        .foregroundColor(.primary)
                        .font(.system(size: 18, weight: .medium))
                }
            }
        }
    }
}
struct RecentMemoryView: View {
    let memory: Memory
    let gender: Gender
    
    var body: some View {
        NavigationLink(destination: MemoryDetailView(memory: memory, gender: gender)) {
            HStack(spacing: 16) {
                Image(uiImage: memory.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(memory.title)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text(memory.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if !memory.description.isEmpty {
                        Text(memory.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 14, weight: .semibold))
            }
        
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Theme.color(for: gender).opacity(0.1),
                       radius: 8, x: 0, y: 4)
        )
    }
}

struct TimelineView: View {
    let memories: [Memory]
    let gender: Gender
    private var sortedMemories: [Memory] {
            memories.sorted { $0.date > $1.date } // Descending order (newest first)
        }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                if memories.isEmpty {
                    EmptyStateView(
                        icon: "photo.on.rectangle.angled",
                        message: "No memories yet.\nStart capturing beautiful moments!"
                    )
                    .padding(.top, 40)
                } else {
                    ForEach(sortedMemories) { memory in
                        TimelineCard(memory: memory, gender: gender)
                    }
                
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Timeline")
    }
}

struct TimelineCard: View {
    let memory: Memory
    let gender: Gender
    
    var body: some View {
        NavigationLink(destination: MemoryDetailView(memory: memory, gender: gender)) {
            VStack(alignment: .leading, spacing: 12) {
                Image(uiImage: memory.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(memory.date.formatted(date: .long, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(memory.title)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    if !memory.description.isEmpty {
                        Text(memory.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Theme.color(for: gender).opacity(0.1),
                            radius: 8, x: 0, y: 4)
            )
        }
    }
}
struct EmptyStateView: View {
    let icon: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(message)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05),
                       radius: 5, x: 0, y: 2)
        )
    }
}

struct InfoCard: View {
    let baby: Baby
    
    var body: some View {
        VStack(spacing: 16) {
            InfoRow(
                icon: "calendar",
                title: "Birth Date",
                value: baby.birthDate.formatted(date: .long, time: .omitted)
            )
            
            Divider()
            
            InfoRow(
                icon: "clock",
                title: "Age",
                value: baby.age
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Theme.color(for: baby.gender).opacity(0.1),
                       radius: 10, x: 0, y: 5)
        )
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.gray)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.primary)
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        List {
            Section(header: Text("Profile")) {
                NavigationLink(destination: Text("Edit Profile")) {
                    Label("Edit Profile", systemImage: "person.circle")
                }
                NavigationLink(destination: Text("Change Password")) {
                    Label("Change Password", systemImage: "lock")
                }
            }
            
            Section(header: Text("Preferences")) {
                Toggle(isOn: $notificationsEnabled) {
                    Label("Notifications", systemImage: "bell")
                }
                Toggle(isOn: $darkModeEnabled) {
                    Label("Dark Mode", systemImage: "moon")
                }
            }
            
            Section(header: Text("Data")) {
                Button {
                    // Export data logic
                } label: {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                }
                
                Button {
                    // Backup logic
                } label: {
                    Label("Backup", systemImage: "arrow.clockwise.icloud")
                }
            }
            
            Section(header: Text("Support")) {
                NavigationLink(destination: Text("Help Center")) {
                    Label("Help Center", systemImage: "questionmark.circle")
                }
                
                NavigationLink(destination: Text("Privacy Policy")) {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }
                
                Link(destination: URL(string: "https://www.example.com")!) {
                    Label("Rate App", systemImage: "star")
                }
            }
            
            Section {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete Account", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Settings")
        .alert("Delete Account", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // Delete account logic
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
    }
}

// Helper extension for image compression
extension UIImage {
    func compressed() -> UIImage {
        let maxSize: CGFloat = 1024
        let scale = min(maxSize/size.width, maxSize/size.height)
        
        if scale < 1 {
            let newSize = CGSize(width: size.width * scale, height: size.height * scale)
            let renderer = UIGraphicsImageRenderer(size: newSize)
            return renderer.image { context in
                draw(in: CGRect(origin: .zero, size: newSize))
            }
        }
        return self
    }
}
struct MemoryDetailView: View {
    let memory: Memory
    let gender: Gender
    @State private var showingImagePicker = false
    @State private var showingImageSource = false
    @State private var selectedImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingGallery = false
    @State private var selectedImageIndex = 0
    
    // Fixed dimensions
    private let heroImageHeight: CGFloat = 250 // Reduced height to fit better
    private let gridImageSize: CGFloat = 160
    private let gridSpacing: CGFloat = 12
    
    private var allImages: [UIImage] {
        var images = [memory.image]
        if let additional = memory.additionalImages {
            images.append(contentsOf: additional)
        }
        return images
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero Image Container
                VStack(spacing: 0) {
                    Image(uiImage: memory.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: heroImageHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                        .onTapGesture {
                            selectedImageIndex = 0
                            showingGallery = true
                        }
                }
                .padding(.top)
                
                // Content
                VStack(alignment: .leading, spacing: 24) {
                    // Date
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(Theme.color(for: gender))
                        Text(memory.date.formatted(date: .long, time: .omitted))
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                    .padding(.top, 16)
                    
                    // Description
                    if !memory.description.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About this moment")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(memory.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(4)
                        }
                    }
                    
                    // Photos Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Photos")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(allImages.count)/6")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: gridSpacing),
                                GridItem(.flexible(), spacing: gridSpacing)
                            ],
                            spacing: gridSpacing
                        ) {
                            // All photos
                            ForEach(allImages.indices, id: \.self) { index in
                                Image(uiImage: allImages[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: gridImageSize, height: gridImageSize)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    .onTapGesture {
                                        selectedImageIndex = index
                                        showingGallery = true
                                    }
                            }
                            
                            // Add Photo Button (if less than 6 photos)
                            if allImages.count < 6 {
                                Button(action: { showingImageSource = true }) {
                                    VStack(spacing: 12) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 30))
                                        Text("Add Photo")
                                            .font(.callout)
                                    }
                                    .foregroundColor(Theme.color(for: gender))
                                    .frame(width: gridImageSize, height: gridImageSize)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Theme.color(for: gender).opacity(0.3),
                                                   style: StrokeStyle(lineWidth: 2,
                                                                    dash: [5]))
                                    )
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                    
                    // Share Button
                    Button(action: shareMemory) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Memory")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Theme.color(for: gender).opacity(0.1))
                        )
                        .foregroundColor(Theme.color(for: gender))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle(memory.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: shareMemory) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    Button(action: {
                        // Edit action
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive, action: {
                        // Delete action
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.primary)
                }
            }
        }
        // ... rest of the view modifiers (sheets, etc.) ...
    
        .sheet(isPresented: $showingGallery) {
            FullScreenImageView(
                images: allImages,
                initialIndex: selectedImageIndex
            )
        }
        .actionSheet(isPresented: $showingImageSource) {
            ActionSheet(
                title: Text("Add Photo"),
                message: Text("Choose a source"),
                buttons: [
                    .default(Text("Take Photo")) {
                        sourceType = .camera
                        showingImagePicker = true
                    },
                    .default(Text("Choose from Library")) {
                        sourceType = .photoLibrary
                        showingImagePicker = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: sourceType)
        }
    }
    
    private func shareMemory() {
        let items: [Any] = [
            memory.title,
            memory.description,
            memory.image
        ]
        
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
}

// Helper Views for cleaner code
struct PhotoGridItem: View {
    let image: UIImage
    let height: CGFloat
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct AddPhotoButton: View {
    let action: () -> Void
    let gender: Gender
    let height: CGFloat
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 30))
                Text("Add Photo")
                    .font(.callout)
            }
            .foregroundColor(Theme.color(for: gender))
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.color(for: gender).opacity(0.3),
                           style: StrokeStyle(lineWidth: 2,
                                            dash: [5]))
            )
        }
    }
}

struct FullScreenImageView: View {
    let images: [UIImage]
    let initialIndex: Int
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int
    
    init(images: [UIImage], initialIndex: Int = 0) {
        self.images = images
        self.initialIndex = initialIndex
        _currentIndex = State(initialValue: initialIndex)
    }
    
    var body: some View {
        ZStack {
            // Black background
            Color.black.ignoresSafeArea()
            
            // Image Gallery
            TabView(selection: $currentIndex) {
                ForEach(images.indices, id: \.self) { index in
                    Image(uiImage: images[index])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .tag(index)
                        .pinchToZoom()
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            
            // Close button
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Image counter
                    Text("\(currentIndex + 1) of \(images.count)")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                        .padding()
                }
                Spacer()
            }
        }
    }
}

// Helper view modifier for pinch-to-zoom
struct PinchToZoom: ViewModifier {
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        let delta = value / lastScale
                        lastScale = value
                        scale = min(max(scale * delta, 1), 3)
                    }
                    .onEnded { _ in
                        lastScale = 1.0
                        if scale < 1.0 {
                            withAnimation { scale = 1.0 }
                        } else if scale > 3.0 {
                            withAnimation { scale = 3.0 }
                        }
                    }
            )
    }
}

extension View {
    func pinchToZoom() -> some View {
        modifier(PinchToZoom())
    }
}

