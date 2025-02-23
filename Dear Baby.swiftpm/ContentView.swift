import SwiftUI
import PhotosUI
import UIKit
import AVFoundation
import UserNotifications
//hello baby

struct Memory: Identifiable {
    let id: UUID
    let title: String
    let date: Date
    var image: UIImage
    let description: String
    var additionalImages: [UIImage]?
    var isInSpace: Bool
    var spaceImage: UIImage?
    var reminder: Reminder?
    
    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        image: UIImage,
        description: String,
        additionalImages: [UIImage]? = nil,
        isInSpace: Bool = false,
        spaceImage: UIImage? = nil,
        reminder: Reminder? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.image = image
        self.description = description
        self.additionalImages = additionalImages
        self.isInSpace = isInSpace
        self.spaceImage = spaceImage
        self.reminder = reminder
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
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    @State private var selectedTab = 0
    @State private var selectedBabyIndex = 0
    @State private var showingSettings = false
    @State private var showingBabyPicker = false
    @State private var showingNewProfileSheet = false
    @State private var babies: [Baby]
    
    
    init() {
        let demoBabies = [
            Baby(id: UUID(), name: "Aadya", 
                 birthDate: Calendar.current.date(byAdding: .month, value: -6, to: Date())!, 
                 image: UIImage(named: "baby_emma") ?? UIImage(systemName: "person.circle.fill")!, 
                 memories: [
                    Memory(
                        id: UUID(),
                        title: "First Smile",
                        date: Date(),
                        image: UIImage(named: "First Smile") ?? UIImage(systemName: "photo")!,
                        description: "Her first beautiful smile! 😍",
                        isInSpace: true
                    ),
                    Memory(
                        id: UUID(),
                        title: "First Crawl",
                        date: Date(),
                        image: UIImage(named: "emma_crawl") ?? UIImage(systemName: "photo")!,
                        description: "Finally! Emma started to crawl 💃",
                        isInSpace: true
                    )
                 ], 
                 gender: .girl),
            Baby(id: UUID(), name: "Lakshya", 
                 birthDate: Calendar.current.date(byAdding: .month, value: -3, to: Date())!, 
                 image: UIImage(named: "baby_liam") ?? UIImage(systemName: "person.circle.fill")!, 
                 memories: [
                    Memory(
                        id: UUID(),
                        title: "First Word",
                        date: Date(),
                        image: UIImage(named: "liam_word") ?? UIImage(systemName: "photo")!,
                        description: "Liam said papa for the first time 🥰",
                        isInSpace: true
                    )
                 ], 
                 gender: .boy),
//            Baby(id: UUID(), name: "Kaashvi", 
//                 birthDate: Calendar.current.date(byAdding: .month, value: -9, to: Date())!, 
//                 image: UIImage(named: "kaashvi") ?? UIImage(systemName: "person.circle.fill")!, 
//                 memories: [], 
//                 gender: .girl)
        ]
        _babies = State(initialValue: demoBabies)
    }
    
    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            } else {
                mainView
            }
        }
    }
    
    var mainView: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                HomeView(
                    selectedBabyIndex: $selectedBabyIndex,
                    showingBabyPicker: $showingBabyPicker,
                    babies: $babies,
                    selectedTab: $selectedTab
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
            
            // Baby Space Tab
            NavigationView {
                BabySpaceView(
                    baby: babies[selectedBabyIndex],
                    babies: $babies,
                    babyIndex: selectedBabyIndex,
                    selectedTab: $selectedTab
                )
                .navigationBarBackButtonHidden(true)
            }
            .tabItem {
                Label("Baby's Space", systemImage: "moon.stars.fill")
            }
            .tag(2)
        }
        .sheet(isPresented: $showingNewProfileSheet) {
                    AddNewProfileView(babies: $babies)
                }
        .actionSheet(isPresented: $showingBabyPicker) {
            ActionSheet(
//                title: Text("Select Baby"),
//                buttons: babies.enumerated().map { index, baby in
                title: Text("Baby Profile"),
                                message: Text("Select an existing profile or create new"),
                                buttons: [
                                    .default(Text("Add New Profile")) {
                                        showingNewProfileSheet = true  // New state variable
                                    }
                                ] + babies.enumerated().map { index, baby in
                    .default(Text(baby.name)) {
                        selectedBabyIndex = index
                    }
                } + [.cancel()]
            )
        }
    }
}

struct AddNewProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var babies: [Baby]
//    @State private var name = ""
//    @State private var birthDate = Date()
//    @State private var gender: Gender = .girl
//    @State private var profileImage: UIImage = UIImage(systemName: "person.circle.fill")!
//    @State private var showingImagePicker = false
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Profile Photo")) {
//                    HStack {
//                        Spacer()
//                        Image(uiImage: profileImage)
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 120, height: 120)
//                            .clipShape(Circle())
//                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
//                            .onTapGesture {
//                                showingImagePicker = true
//                            }
//                        Spacer()
//                    }
//                    .padding(.vertical)
//                }
//                
//                Section(header: Text("Details")) {
//                    TextField("Baby's Name", text: $name)
//                    DatePicker("Birth Date", selection: $birthDate, in: ...Date(), displayedComponents: .date)
//                    Picker("Gender", selection: $gender) {
//                        Text("Girl").tag(Gender.girl)
//                        Text("Boy").tag(Gender.boy)
//                    }
//                }
//                            }
//                            .navigationTitle("New Profile")
//                            .navigationBarItems(
//                                leading: Button("Cancel") {
//                                    dismiss()
//                                },
//                                trailing: Button("Add") {
//                                    let newBaby = Baby(
//                                        id: UUID(),
//                                        name: name,
//                                        birthDate: birthDate,
//                                        image: profileImage,
//                                        memories: [],
//                                        gender: gender
//                                    )
//                                    babies.append(newBaby)
//                                    dismiss()
//                                }
//                                .disabled(name.isEmpty)
//                            )
//                        }
//                        .sheet(isPresented: $showingImagePicker) {
//                            ImagePicker(image: $profileImage, sourceType: .photoLibrary)
//                        }
//                    }
//                }
  
    @State private var name = ""
    @State private var birthDate = Date()
    @State private var gender: Gender = .girl
    @State private var profileImage: UIImage? = UIImage(systemName: "person.circle.fill")  // Make it optional
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Photo")) {
                    HStack {
                        Spacer()
                        Image(uiImage: profileImage ?? UIImage(systemName: "person.circle.fill")!)  // Add nil coalescing
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            .onTapGesture {
                                showingImagePicker = true
                            }
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                Section(header: Text("Details")) {
                    TextField("Baby's Name", text: $name)
                    DatePicker("Birth Date", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                    Picker("Gender", selection: $gender) {
                        Text("Girl").tag(Gender.girl)
                        Text("Boy").tag(Gender.boy)
                    }
                }
            }
            .navigationTitle("New Profile")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Add") {
                    let newBaby = Baby(
                        id: UUID(),
                        name: name,
                        birthDate: birthDate,
                        image: profileImage ?? UIImage(systemName: "person.circle.fill")!,  // Add nil coalescing
                        memories: [],
                        gender: gender
                    )
                    babies.append(newBaby)
                    dismiss()
                }
                .disabled(name.isEmpty)
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $profileImage, sourceType: .photoLibrary)  // Now this will work
        }
    }
}
struct OnboardingPage {
    let title: String
    let subtitle: String
    let imageName: String
    let features: [String]
    let cta: String
    let symbolColor: Color
}

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    private let pages = [
        OnboardingPage(
            title: "Your Baby's Life, Beautifully Organized!",
            subtitle: "Store every milestone in a structured way and relive the journey anytime.",
            imageName: "calendar.badge.clock",
            features: [
                "A chronological timeline to store memories from birth onwards",
                "Organize photos, videos, and notes seamlessly",
                "Effortlessly track special milestones, from first steps to birthdays"
            ],
            cta: "Swipe to discover more magic!",
            symbolColor: Color(#colorLiteral(red: 0.91, green: 0.38, blue: 0.45, alpha: 1))
        ),
        OnboardingPage(
            title: "A Magical Photobook, Created Just for You!",
            subtitle: "A beautiful, auto-generated album capturing your baby's best moments each year.",
            imageName: "photo.on.rectangle.angled",
            features: [
                "A magical photobook that compiles your baby's journey into an annual keepsake",
                "AI-powered storytelling that highlights the most special moments",
                "Option to print & share with loved ones"
            ],
            cta: "Swipe for one last surprise!",
            symbolColor: Color(#colorLiteral(red: 0.33, green: 0.53, blue: 0.85, alpha: 1))
        ),
        OnboardingPage(
            title: "Leave Messages for the Future!",
            subtitle: "Set reminders, store heartfelt messages, and unlock them when the time is right.",
            imageName: "gift.fill",
            features: [
                "Write a letter or memory for your baby's future self",
                "Lock it away until a special date (first birthday, graduation, etc.)",
                "Surprise them with a priceless gift of love & memories when the time arrives"
            ],
            cta: "Begin Your Journey",
            symbolColor: Color(#colorLiteral(red: 0.55, green: 0.35, blue: 0.85, alpha: 1))
        )
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(#colorLiteral(red: 0.95, green: 0.95, blue: 1.0, alpha: 1)),
                    Color(#colorLiteral(red: 1.0, green: 0.95, blue: 0.98, alpha: 1))
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(
                            page: pages[index],
                            isLastPage: index == pages.count - 1,
                            hasCompletedOnboarding: $hasCompletedOnboarding
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                HStack(spacing: 12) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? pages[index].symbolColor : Color.gray.opacity(0.3))
                            .frame(width: currentPage == index ? 12 : 8,
                                   height: currentPage == index ? 12 : 8)
                            .overlay(
                                Circle()
                                    .stroke(pages[index].symbolColor, lineWidth: currentPage == index ? 2 : 0)
                                    .scaleEffect(currentPage == index ? 1.3 : 1)
                            )
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isLastPage: Bool
    @Binding var hasCompletedOnboarding: Bool
    
    @State private var showTitle = false
    @State private var showImage = false
    @State private var showFeatures = false
    @State private var showCTA = false
    @State private var rotation = 0.0
    @State private var isHovering = false
    @State private var scale: CGFloat = 0.9
    
    var body: some View {
        VStack(spacing: 30) {
            Text(page.title)
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(#colorLiteral(red: 0.2, green: 0.2, blue: 0.3, alpha: 1)))
                .padding(.horizontal)
                .opacity(showTitle ? 1 : 0)
                .offset(y: showTitle ? 0 : 20)
                .scaleEffect(showTitle ? 1 : 0.8)
            
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 160, height: 160)
                    .shadow(color: Color.black.opacity(0.1), radius: 10)
                    .scaleEffect(isHovering ? 1.05 : 1)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isHovering)
                
                Image(systemName: page.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80)
                    .foregroundColor(page.symbolColor)
                    .rotationEffect(.degrees(isHovering ? 8 : -8))
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isHovering)
            }
            .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
            .opacity(showImage ? 1 : 0)
            .scaleEffect(showImage ? 1 : 0.6)
            
            VStack(alignment: .leading, spacing: 15) {
                ForEach(page.features.indices, id: \.self) { index in
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .foregroundColor(page.symbolColor)
                            .rotationEffect(.degrees(showFeatures ? 0 : -30))
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.6)
                                .delay(Double(index) * 0.1),
                                value: showFeatures
                            )
                        
                        Text(page.features[index])
                            .font(.body)
                            .foregroundColor(Color(#colorLiteral(red: 0.2, green: 0.2, blue: 0.3, alpha: 1)))
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.7))
                    )
                    .opacity(showFeatures ? 1 : 0)
                    .offset(x: showFeatures ? 0 : -20)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.7)
                        .delay(Double(index) * 0.1),
                        value: showFeatures
                    )
                }
            }
            .padding(.horizontal, 24)
            
            if isLastPage {
                Button(action: { 
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        hasCompletedOnboarding = true
                    }
                }) {
                    Text(page.cta)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(page.symbolColor)
                        )
                        .padding(.horizontal, 30)
                        .scaleEffect(isHovering ? 1.02 : 1)
                }
                .opacity(showCTA ? 1 : 0)
                .scaleEffect(showCTA ? 1 : 0.8)
            } else {
                Text(page.cta)
                    .font(.headline)
                    .foregroundColor(page.symbolColor)
                    .opacity(showCTA ? 1 : 0)
                    .scaleEffect(showCTA ? 1 : 0.8)
            }
        }
        .padding(.vertical, 40)
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1
            }
            
            withAnimation(.easeOut(duration: 0.6)) {
                showTitle = true
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                showImage = true
                rotation = 360
            }
            
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                showFeatures = true
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.6)) {
                showCTA = true
            }
            
            withAnimation(
                .easeInOut(duration: 2)
                .repeatForever(autoreverses: true)
            ) {
                isHovering = true
            }
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
    @State private var selectedImages: [UIImage] = []
    @State private var showingImageLimit = false
    @State private var showingImagePicker = false
    @State private var showingImageSource = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var addToSpace: Bool = false
    @State private var showingSpaceImageSelection = false
    @State private var selectedSpaceImage: UIImage?
    @State private var showingSpaceSuccessAlert = false
    
    private func resetForm() {
        title = ""
        description = ""
        date = Date()
        selectedImage = nil
        selectedImages.removeAll()
        addToSpace = false
    }
    
    var body: some View {
        Form {
            // Memory Details Section
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
            
            // Photos Section
            Section {
                
                if !selectedImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(selectedImages.indices, id: \.self) { index in
                                Image(uiImage: selectedImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        Button(action: { removeImage(at: index) }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(Color.black.opacity(0.7))
                                                .clipShape(Circle())
                                        }
                                        .padding(4),
                                        alignment: .topTrailing
                                    )
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Button(action: { showingImageSource = true }) {
                    HStack {
                        Image(systemName: selectedImages.isEmpty ? "camera.fill" : "plus.circle.fill")
                        Text(selectedImages.isEmpty ? "Add Photos" : "Add More Photos")
                    }
                    .foregroundColor(Theme.color(for: babies[selectedBabyIndex].gender))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .disabled(selectedImages.count >= 6)
            } header: {
                Text("Photos (\(selectedImages.count)/6)")
            }
            
            Section {
                Toggle(isOn: $addToSpace) {
                    
                    HStack {
                        Image(systemName: "sparkles.square.filled.on.square")
                            .foregroundColor(Theme.color(for: babies[selectedBabyIndex].gender))
                        Text("Add to Baby's Space")
                    }
                    
                }
                .tint(Theme.color(for: babies[selectedBabyIndex].gender))
            } header: {
                Text("Special Features")
            } footer: {
                Text("Adding to Baby's Space creates a magical memory book in the space journey")
                    .font(.caption)
            }
            
            // Save Button Section
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
                .disabled(title.isEmpty || selectedImages.isEmpty)
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

        .onChange(of: selectedImage) { newImage in
            if let image = newImage {
                addImage(image)
                selectedImage = nil
            }
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .alert("Photo Limit Reached", isPresented: $showingImageLimit) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You can add up to 6 photos per memory.")
        }
        .alert("Memory Saved", isPresented: $showingSpaceSuccessAlert) {
            Button("OK") {
                resetForm()
                selectedTab = 0
            }
        } message: {
            Text("Memory successfully added to Baby's Timeline!🥳")
        }
    }
    
    private func addImage(_ image: UIImage) {
        if selectedImages.count < 6 {
            selectedImages.append(image)
        } else {
            showingImageLimit = true
        }
    }
    
    private func removeImage(at index: Int) {
        selectedImages.remove(at: index)
    }
    
    private func saveMemory() {
        
        guard !selectedImages.isEmpty else { return }
        saveMemoryWithSpaceImage(selectedImages[0])
    }
    
    private func saveMemoryWithSpaceImage(_ spaceImage: UIImage) {
        let newMemory = Memory(
            title: title,
            date: date,
            image: selectedImages[0],
            description: description.isEmpty ? "No description" : description,
            additionalImages: selectedImages.count > 1 ? Array(selectedImages[1...]) : nil,
            isInSpace: addToSpace,
            spaceImage: addToSpace ? spaceImage : nil
        )
        
        var updatedBabies = babies
        updatedBabies[selectedBabyIndex].memories.insert(newMemory, at: 0)
        babies = updatedBabies
        
        if addToSpace {
            showingSpaceSuccessAlert = true
        } else {
            resetForm()
            selectedTab = 0
        }
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
    @Binding var babies: [Baby]
    @Binding var selectedTab: Int
    
    private var recentMemories: [Memory] {
            babies[selectedBabyIndex].memories
                .sorted { $0.date > $1.date }
                .prefix(3)
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
                        HStack {
                            SectionHeader(title: "Timeline")
                            Spacer()
                            
                            NavigationLink(
                                destination: TimelineView(
                                    memories: babies[selectedBabyIndex].memories,
                                    gender: babies[selectedBabyIndex].gender,
                                    babies: $babies,
                                    babyIndex: selectedBabyIndex
                                )
                            ) {
                                HStack(spacing: 4) {
                                    Text("See Timeline")
                                        .font(.subheadline)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .foregroundColor(Theme.color(for: babies[selectedBabyIndex].gender))
                            }
                        }
                        
                        if babies[selectedBabyIndex].memories.isEmpty {
                            EmptyStateView(
                                icon: "photo.on.rectangle.angled",
                                message: "No memories yet.\nTap + to add your first memory!"
                            )
                        } else {
                            ForEach(recentMemories) { memory in
                                RecentMemoryView(
                                    memory: memory,
                                    gender: babies[selectedBabyIndex].gender,
                                    babies: $babies,
                                    babyIndex: selectedBabyIndex
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                    
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
        .navigationTitle("Dear Baby")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
            }
        }
        
    }
    
}
struct RecentMemoryView: View {
    let memory: Memory
    let gender: Gender
    @Binding var babies: [Baby]
    let babyIndex: Int
    
    var body: some View {
        NavigationLink(
            destination: MemoryDetailView(
                memory: memory,
                gender: gender,
                babies: $babies,
                babyIndex: babyIndex
            )
        ) {
            HStack(spacing: 16) {
                Image(uiImage: memory.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(memory.title)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text(memory.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if !memory.description.isEmpty {
                        Text(memory.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
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
}

struct TimelineView: View {
    let memories: [Memory]
    let gender: Gender
    @Binding var babies: [Baby]
        let babyIndex: Int
    private var sortedMemories: [Memory] {
            memories.sorted { $0.date > $1.date }
        }
    
       private var groupedMemories: [Date: [Memory]] {
           Dictionary(grouping: sortedMemories) { memory in
               Calendar.current.startOfDay(for: memory.date)
           }
       }
    
    @State private var showingReminders = false
    
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
                    ForEach(groupedMemories.keys.sorted().reversed(), id: \.self) { date in
                        if let memoriesForDate = groupedMemories[date] {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(date.formatted(date: .long, time: .omitted))
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                ForEach(memoriesForDate) { memory in
                                    TimelineCard(
                                        memory: memory,
                                        gender: gender,
                                        babies: $babies,
                                        babyIndex: babyIndex
                                    )
                                }
                            }
            }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Timeline")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingReminders = true }) {
                    Image(systemName: "bell.badge")
                        .foregroundColor(Theme.color(for: gender))
                }
            }
        }
        .sheet(isPresented: $showingReminders) {
            RemindersListView(babies: $babies, babyIndex: babyIndex)
        }
    }
}

struct TimelineCard: View {
    let memory: Memory
    let gender: Gender
    @Binding var babies: [Baby]
    let babyIndex: Int
    
    var body: some View {
        NavigationLink(destination: MemoryDetailView(memory: memory,
                                                   gender: gender,
                                                   babies: $babies,
                                                   babyIndex: babyIndex)) {
            VStack(alignment: .leading, spacing: 12) {
                Image(uiImage: memory.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
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
    @Binding var babies: [Baby]
    @State private var showingImageSelection = false
    let babyIndex: Int
    @State private var showingImagePicker = false
    @State private var showingImageSource = false
    @State private var selectedImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingGallery = false
    @State private var selectedImageIndex = 0
    @State private var showingImageSelectionForSpace = false
    @State private var showingSuccessAlert = false
    @State private var showingReminderSheet = false
    @State private var showingReminderOptions = false
    @State private var showingReminderDetail = false
    private let heroImageHeight: CGFloat = 250
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

                GeometryReader { geometry in
                                    ZStack(alignment: .bottomTrailing) {
                                        VStack(spacing: 0) {
                                            Image(uiImage: memory.image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: geometry.size.width - 32)
                                                .frame(height: heroImageHeight)
                                                .clipped()
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(Color(.systemBackground))
                                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                                )
                                                .onTapGesture {
                                                    selectedImageIndex = 0
                                                    showingGallery = true
                                                }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, 16)
                                        
                                        // Reminder Button
                                        Button(action: {
                                            if memory.reminder != nil {
                                                showingReminderDetail = true
                                            } else {
                                                showingReminderOptions = true
                                            }
                                        }) {
                                            HStack {
                                                if memory.reminder != nil {
                                                    Image(systemName: "bell.badge.fill")
                                                } else {
                                                    Image(systemName: "bell.badge")
                                                }
                                            }
                                            .font(.system(size: 20))
                                            .foregroundColor(Theme.color(for: gender))
                                            .padding(12)
                                            .background(Color(UIColor.systemBackground))
                                            .clipShape(Circle())
                                            .shadow(radius: 3)
                                        }
                                        .padding(.trailing, 32)
                                        .padding(.bottom, 12)
                                    }
                                    .frame(height: heroImageHeight + 32)
                                }
                                .frame(height: heroImageHeight + 32)
                
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
                                    .clipped()  // Add this to prevent overflow
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    .onTapGesture {
                                        selectedImageIndex = index
                                        showingGallery = true
                                    }
                            }
                            
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
                    
                    Spacer(minLength: 0)
                    
                    if !memory.isInSpace {
                        Button(action: handleAddToSpace) {
                            HStack {
                                Image(systemName: "sparkles.square.fill.on.square.fill")
                                Text("Add to Baby's Space")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Theme.color(for: gender).opacity(0.1))
                            )
                            .foregroundColor(Theme.color(for: gender))
                        }
                        .padding(.horizontal)
                        .padding(.top, 0)
                    }
                }
                
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showingImageSelection) {
                    SpaceImageSelectionView(images: allImages) { selectedImage in
                        addToSpace(with: selectedImage)
                    }
                }
        .navigationTitle(memory.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {}) {
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
        .sheet(isPresented: $showingImageSelection) {
            SpaceImageSelectionView(images: allImages) { selectedImage in
                addToSpace(with: selectedImage)
            }
        }
        .alert("Added to Space ✨", isPresented: $showingSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Memory added to Baby's Space!")
        }
        .sheet(isPresented: $showingReminderSheet) {
            ReminderView(
                memory: binding(for: memory),
                babies: $babies,
                babyIndex: babyIndex
            )
        }
        .sheet(isPresented: $showingReminderOptions) {
            if memory.reminder != nil {
                ReminderActionSheet(
                    memory: binding(for: memory),
                    babies: $babies,
                    babyIndex: babyIndex
                )
            } else {
                ReminderView(
                    memory: binding(for: memory),
                    babies: $babies,
                    babyIndex: babyIndex
                )
            }
        }
        .sheet(isPresented: $showingReminderDetail) {
            if let reminder = memory.reminder {
                ReminderDetailView(
                    memory: memory,
                    reminder: reminder,
                    babies: $babies,
                    babyIndex: babyIndex
                )
            }
        }
        .onChange(of: selectedImage) { newImage in
                    if let image = newImage {
                        var updatedBabies = babies
                        if let memoryIndex = updatedBabies[babyIndex].memories.firstIndex(where: { $0.id == memory.id }) {
                            if updatedBabies[babyIndex].memories[memoryIndex].additionalImages == nil {
                                updatedBabies[babyIndex].memories[memoryIndex].additionalImages = []
                            }
                            updatedBabies[babyIndex].memories[memoryIndex].additionalImages?.append(image)
                            babies = updatedBabies
                        }
                        selectedImage = nil
                    }
                }
    }
    
    private func handleAddToSpace() {
        if allImages.count > 1 {
            showingImageSelection = true
        } else {
            addToSpace(with: memory.image)
        }
    }
    
    
    private func addToSpace(with selectedImage: UIImage) {
        var updatedBabies = babies
        if let memoryIndex = updatedBabies[babyIndex].memories.firstIndex(where: { $0.id == memory.id }) {
            updatedBabies[babyIndex].memories[memoryIndex].isInSpace = true
            updatedBabies[babyIndex].memories[memoryIndex].spaceImage = selectedImage
            babies = updatedBabies
            showingSuccessAlert = true
        }
    }
    
    private func binding(for memory: Memory) -> Binding<Memory> {
        Binding(
            get: { memory },
            set: { newMemory in
                var updatedBabies = babies
                if let index = updatedBabies[babyIndex].memories.firstIndex(where: { $0.id == memory.id }) {
                    updatedBabies[babyIndex].memories[index] = newMemory
                    babies = updatedBabies
                }
            }
        )
    }
}

struct ImageSelectionView: View {
    let images: [UIImage]
    let onSelect: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 16
                ) {
                    ForEach(images.indices, id: \.self) { index in
                        Button {
                            onSelect(images[index])
                            dismiss()
                        } label: {
                            Image(uiImage: images[index])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Select Space Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

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
struct BabySpaceView: View {
    let baby: Baby
    @Binding var babies: [Baby]
        let babyIndex: Int
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedBook: Bool = false
    @Binding var selectedTab: Int
    @State private var animatingSpace = false
    @State private var showingBookOptions = false
    @State private var showingMemoryOptions = false
    @State private var currentPage = 1
    
    var spaceMemories: [Memory] {
        baby.memories.filter { $0.isInSpace }
    }
    
    var body: some View {
        ZStack {
            
            SpaceBackground(isAnimating: $animatingSpace)
                            .onTapGesture {
                                if selectedBook {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        selectedBook = false
                                    }
                                }
                            }
                        
                        
            GeometryReader { geometry in
                ZStack {
                    if !selectedBook {
                        FloatingBookView(
                            baby: baby,
                            isSelected: $selectedBook,
                            size: geometry.size
                        )
                    } else {
                        OpenBookView(
                            baby: baby,
                            isOpen: $selectedBook,
                            showingMemoryOptions: $showingMemoryOptions,
                            babies: $babies,
                            babyIndex: babyIndex,
                            size: geometry.size
                        )
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    withAnimation {
                        selectedTab = 0
                    }
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back to Earth")
                            .font(.system(.body, design: .rounded))
                    }
                    .foregroundColor(.white)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if !selectedBook {
                    Button(action: {
                        showingBookOptions = true
                    }) {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .animation(.easeInOut(duration: 2.0), value: currentPage)
        .confirmationDialog(
            "Book Options",
            isPresented: $showingBookOptions,
            titleVisibility: .visible
        ) {
            Button("Add New Book") {
                // Add new book action
            }
            Button("Delete Book", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}


struct EndPage: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.gold)
            
            Text("The End")
                .font(.custom("Baskerville-Bold", size: 30))
                .foregroundColor(.black.opacity(0.8))
            
            Text("Every memory tells a story...")
                .font(.custom("Baskerville", size: 16))
                .foregroundColor(.black.opacity(0.6))
                .italic()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.98))
    }
}
struct MemoryPage: View {
    let memory: Memory
    @State private var imageScale: CGFloat = 1.0
    @State private var showingFullScreenImage = false
    @State private var showingImageSelection = false
    @Binding var babies: [Baby]
    let babyIndex: Int
    
    var allImages: [UIImage] {
        var images = [memory.image]
        if let additional = memory.additionalImages {
            images.append(contentsOf: additional)
        }
        return images
    }
    
    var body: some View {
        ZStack {
            // Page background
            Color(white: 0.98)
            
            VStack(spacing: 25) {
                // Date header
                Text(memory.date.formatted(date: .long, time: .omitted))
                    .font(.custom("Baskerville", size: 18))
                    .foregroundColor(.black.opacity(0.6))
                
                // Single Image with change option
                Image(uiImage: memory.spaceImage ?? memory.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gold, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .scaleEffect(imageScale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                imageScale = min(max(value, 1), 2)
                            }
                            .onEnded { _ in
                                withAnimation {
                                    imageScale = 1
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        showingFullScreenImage = true
                    }
                if allImages.count > 1 {
                    Button {
                        showingImageSelection = true
                    } label: {
                        Label("Change Image", systemImage: "photo.on.rectangle.angled")
                            .font(.footnote)
                            .foregroundColor(.gold)
                    }
                }
                
                // Memory content
                VStack(spacing: 15) {
                    Text(memory.title)
                        .font(.custom("Baskerville-Bold", size: 24))
                        .foregroundColor(.black.opacity(0.8))
                    
                    // Decorative divider
                    HStack {
                        Line()
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.gold)
                        Line()
                    }
                    .frame(width: 100)
                    
                    Text(memory.description)
                        .font(.custom("Baskerville", size: 16))
                        .foregroundColor(.black.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal)
                }
            }
            .sheet(isPresented: $showingImageSelection) {
                        SpaceImageSelectionView(images: allImages) { selectedImage in
                            updateSpaceImage(selectedImage)
                        }
                    }
            .padding(30)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .sheet(isPresented: $showingFullScreenImage) {
            FullScreenImageView(
                images: [memory.spaceImage ?? memory.image],
                initialIndex: 0
            )
        }
    }
    
    private func updateSpaceImage(_ image: UIImage) {
        var updatedBabies = babies
        if let memoryIndex = updatedBabies[babyIndex].memories.firstIndex(where: { $0.id == memory.id }) {
            updatedBabies[babyIndex].memories[memoryIndex].spaceImage = image
            babies = updatedBabies
        }
    }
}
struct SpaceImageSelectionView: View {
    let images: [UIImage]
    let onSelect: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImageIndex: Int?
    
    private var gridWidth: CGFloat {
        UIScreen.main.bounds.width - 40
    }
    
    private var imageSize: CGFloat {
        (gridWidth - 15) / 2
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.primary)
                
                Spacer()
                
                Text("Select Image")
                    .font(.headline)
                
                Spacer()
                
                Button("Done") {
                    if let index = selectedImageIndex {
                        onSelect(images[index])
                    }
                    dismiss()
                }
                .foregroundColor(selectedImageIndex == nil ? .gray : .blue)
                .disabled(selectedImageIndex == nil)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            
            Divider()
            
            // Image Grid
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.fixed(imageSize)),
                        GridItem(.fixed(imageSize))
                    ],
                    spacing: 15
                ) {
                    ForEach(images.indices, id: \.self) { index in
                        Button {
                            selectedImageIndex = index
                        } label: {
                            Image(uiImage: images[index])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: imageSize, height: imageSize)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    ZStack {
                                        if selectedImageIndex == index {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.black.opacity(0.3))
                                            
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(.white)
                                        }
                                    }
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            selectedImageIndex == index ? Color.blue : Color.clear,
                                            lineWidth: 3
                                        )
                                )
                        }
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct ImageCell: View {
    let image: UIImage
    let isSelected: Bool
    let size: CGFloat
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Rectangle()
                .fill(Color.clear)
                .frame(width: size, height: size)
                .overlay(
                    
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                )
                .overlay(
                   
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                )
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .background(
                        Circle()
                            .fill(.white)
                            .frame(width: 26, height: 26)
                    )
                    .offset(x: -8, y: 8)
            }
        }
    }
}


struct Line: View {
    var body: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.gold.opacity(0.3))
    }
}


struct FloatingBookView: View {
    let baby: Baby
    @Binding var isSelected: Bool
    let size: CGSize
    
    
    @State private var rotation: Double = 0
    @State private var hover: CGFloat = 0
    @State private var glowOpacity: Double = 0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isSelected = true
            }
        }) {
            ZStack {
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .blur(radius: 20)
                    .opacity(glowOpacity)
                    .frame(width: 320, height: 440)
                
                
                VStack(spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.1, green: 0.1, blue: 0.3),
                                        Color(red: 0.2, green: 0.2, blue: 0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                SpaceBookOverlay()
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gold, lineWidth: 2)
                            )
                        
                        VStack(spacing: 25) {
                            Text(baby.name + "'s")
                                .font(.custom("Baskerville-Bold", size: 32))
                                .foregroundColor(.gold)
                            
                            Image(systemName: "sparkles.square.filled.on.square")
                                .font(.system(size: 60))
                                .foregroundColor(.gold)
                                .opacity(0.8)
                            
                            Text("Space Journey")
                                .font(.custom("Baskerville", size: 24))
                                .foregroundColor(.gold)
                            
                            HStack(spacing: 20) {
                                ForEach(0..<3) { _ in
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gold)
                                }
                            }
                        }
                        .padding(40)
                    }
                }
                .frame(width: 280, height: 400)
                .shadow(color: Color.purple.opacity(0.3), radius: 15, x: 5, y: 5)
            }
        }
        .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
        .offset(y: hover)
        .onAppear {
            
            withAnimation(
                Animation
                    .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
            ) {
                rotation = 8
                hover = -20
            }
            
            
            withAnimation(
                Animation
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
            ) {
                glowOpacity = 0.3
            }
        }
    }
}

struct SpaceBookOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Stars
                ForEach(0..<50) { _ in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 2, height: 2)
                        .position(
                            x: .random(in: 0...geometry.size.width),
                            y: .random(in: 0...geometry.size.height)
                        )
                        .opacity(.random(in: 0.3...0.7))
                }
                
                // Nebula effect
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.2), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: geometry.size.width * 0.8)
                    .offset(x: geometry.size.width * 0.1, y: geometry.size.height * 0.1)
                    .blur(radius: 20)
            }
        }
    }
}
struct OpenBookView: View {
    let baby: Baby
    @Binding var isOpen: Bool
    @Binding var showingMemoryOptions: Bool
    @Binding var babies: [Baby]
    let babyIndex: Int
    let size: CGSize
    @State private var currentPage = -1
    @State private var pageRotation: Double = 0
    @State private var dragOffset: CGFloat = 0
    @GestureState private var dragState = DragState.inactive
    
    private var spaceMemories: [Memory] {
        baby.memories.filter { $0.isInSpace }
    }
    
    var body: some View {
        ZStack {
            
            BookBase()
                .shadow(color: .black.opacity(0.3), radius: 20, x: 10, y: 0)
            
            
            ZStack {
                if currentPage > -1 {
                    getPage(for: currentPage - 1)
                        .rotation3DEffect(.degrees(-pageRotation), axis: (x: 0, y: 1, z: 0), anchor: .leading)
                        .zIndex(1)
                }
                getPage(for: currentPage)
                    .rotation3DEffect(.degrees(pageRotation), axis: (x: 0, y: 1, z: 0), anchor: .leading)
                    .zIndex(2)
            }
            .gesture(
                DragGesture()
                    .updating($dragState) { value, state, _ in
                        state = .dragging(translation: value.translation)
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        if value.translation.width < -threshold && currentPage < spaceMemories.count {
                            nextPage()
                        } else if value.translation.width > threshold && currentPage > -1 {
                            previousPage()
                        }
                    }
            )
            
            if currentPage > 0 {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            showingMemoryOptions = true
                        }) {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 22))
                                .foregroundColor(.gold)
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
        }
        .frame(width: size.width * 0.85, height: size.height * 0.7)
        .confirmationDialog(
            "Memory Options",
            isPresented: $showingMemoryOptions,
            titleVisibility: .visible
        ) {

            if currentPage > 0 {
                Button("Delete Memory", role: .destructive) {
                    previousPage()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func getPage(for index: Int) -> some View {
        Group {
            if index == -1 {
                BookCover(baby: baby)
            } else if index == 0 {
                IntroductionPage(baby: baby)
            } else if index <= spaceMemories.count {
                MemoryPage(
                    memory: spaceMemories[index - 1],
                    babies: $babies,
                    babyIndex: babyIndex
                )
            } else {
                EmptyPage()
            }
        }
        .shadow(color: .black.opacity(0.2), radius: 5, x: 2, y: 2)
    }
    
    private func nextPage() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            pageRotation = -180
            if currentPage < spaceMemories.count {
                currentPage += 1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            pageRotation = 0
        }
    }
    
    private func previousPage() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            pageRotation = 180
            if currentPage > -1 {
                currentPage -= 1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            pageRotation = 0
        }
    }

    
    
    private func updatePageRotation(dragState: DragState) {
        let dragAmount = dragState.translation.width
        let normalized = min(max(-180, dragAmount), 180)
        pageRotation = normalized
    }
}

enum DragState: Equatable {
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    static func == (lhs: DragState, rhs: DragState) -> Bool {
        switch (lhs, rhs) {
        case (.inactive, .inactive):
            return true
        case (.dragging(let lhsTranslation), .dragging(let rhsTranslation)):
            return lhsTranslation == rhsTranslation
        default:
            return false
        }
    }
}

struct BookBase: View {
    var body: some View {
        ZStack {
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.5),
                            Color.black.opacity(0.2),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 20)
                .offset(x: -10)
            
            Rectangle()
                .fill(Color(white: 0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.gold, lineWidth: 1)
                )
        }
    }
}
struct BookCover: View {
    let baby: Baby
    
    var body: some View {
        ZStack {
           
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.1, green: 0.1, blue: 0.3),
                            Color(red: 0.2, green: 0.2, blue: 0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(SpaceBookOverlay())
            
            VStack(spacing: 30) {
                Text(baby.name + "'s")
                    .font(.custom("Baskerville-Bold", size: 36))
                    .foregroundColor(.gold)
                
                Image(systemName: "sparkles.square.filled.on.square")
                    .font(.system(size: 70))
                    .foregroundColor(.gold)
                    .opacity(0.8)
                
                Text("Space Journey")
                    .font(.custom("Baskerville", size: 28))
                    .foregroundColor(.gold)
                
                // Swipe hint
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Swipe to explore")
                    Image(systemName: "chevron.left")
                }
                .font(.custom("Baskerville", size: 16))
                .foregroundColor(.gold.opacity(0.8))
                .padding(.top, 30)
            }
            .padding(40)
        }
    }
}
struct IntroductionPage: View {
    let baby: Baby
    
    var body: some View {
        ZStack {
            Color(white: 0.98)

            
            VStack(spacing: 30) {
               
                VStack(spacing: 15) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gold)
                    
                    Text("Welcome to")
                        .font(.custom("Baskerville-Italic", size: 24))
                    Text(baby.name + "'s")
                        .font(.custom("Baskerville-Bold", size: 32))
                    Text("First Year Journey")
                        .font(.custom("Baskerville", size: 28))
                }
                .foregroundColor(.black.opacity(0.8))
                
                HStack {
                    Line()
                    Image(systemName: "sparkles")
                        .foregroundColor(.gold)
                    Line()
                }
                .frame(width: 200)
                
                VStack(spacing: 15) {
                    DetailRow(icon: "calendar", title: "Born on", value: baby.birthDate.formatted(date: .long, time: .omitted))
                    DetailRow(icon: "clock", title: "Age", value: baby.age)
                }
                .padding(.vertical)
                
                VStack(spacing: 8) {
                    Text("Swipe to explore memories")
                        .font(.custom("Baskerville-Italic", size: 16))
                        .foregroundColor(.black.opacity(0.6))
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.gold)
                }
                .padding(.top, 20)
            }
            .padding(40)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
struct EmptyPage: View {
    @State private var quote: String
    
    init() {
        _quote = State(initialValue: EndingQuotes.randomQuote())
    }
    
    var body: some View {
        ZStack {
            Color(white: 0.98)
                .overlay(
                    Image("paper_texture")
                        .resizable()
                        .opacity(0.1)
                )
            
            VStack(spacing: 30) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.gold.opacity(0.6))
                
                Text("End of Journey")
                    .font(.custom("Baskerville-Bold", size: 24))
                    .foregroundColor(.black.opacity(0.6))
                
                VStack(spacing: 15) {
                    Text("")
                        .font(.system(size: 40))
                        .foregroundColor(.gold)
                    
                    Text(quote)
                        .font(.custom("Baskerville-Italic", size: 20))
                        .foregroundColor(.black.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Text("")
                        .font(.system(size: 40))
                        .foregroundColor(.gold)
                }
                .padding(.vertical)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onAppear {
            quote = EndingQuotes.randomQuote()
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gold)
            
            Text(title)
                .font(.custom("Baskerville", size: 16))
            
            Text(value)
                .font(.custom("Baskerville-Bold", size: 16))
        }
        .foregroundColor(.black.opacity(0.7))
    }
}

extension Color {
    static let gold = Color(red: 212/255, green: 175/255, blue: 55/255)
    static let deepSpace = Color(red: 0.1, green: 0.1, blue: 0.3)
    static let starlight = Color(red: 1, green: 1, blue: 0.95)
    static let cosmic = Color(red: 0.4, green: 0.2, blue: 0.6)
}

struct SpaceBackground: View {
    @Binding var isAnimating: Bool
    
    
    private let starCount = 100
    @State private var starOpacities: [Double]
    @State private var starScales: [CGFloat]
    @State private var starPositions: [CGPoint]
    
    
    @State private var shootingStars: [ShootingStar] = []
    private let shootingStarInterval: Double = 3.0
    
    
    @State private var nebulaOffset = CGPoint.zero
    private let nebulaColors: [Color] = [
        Color(red: 0.4, green: 0.2, blue: 0.6).opacity(0.3),
        Color(red: 0.6, green: 0.3, blue: 0.7).opacity(0.2),
        Color(red: 0.3, green: 0.1, blue: 0.5).opacity(0.3)
    ]
    
    init(isAnimating: Binding<Bool>) {
        self._isAnimating = isAnimating
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        self._starOpacities = State(initialValue: (0..<100).map { _ in Double.random(in: 0.2...0.8) })
        self._starScales = State(initialValue: (0..<100).map { _ in CGFloat.random(in: 0.5...1.5) })
        self._starPositions = State(initialValue: (0..<100).map { _ in
            CGPoint(
                x: CGFloat.random(in: -50...screenWidth + 50),
                y: CGFloat.random(in: -50...screenHeight + 50)
            )
        })
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                Color.black.ignoresSafeArea()
                
                
                ForEach(0..<3) { index in
                    NebulaEffect(color: nebulaColors[index], offset: $nebulaOffset)
                        .opacity(isAnimating ? 1 : 0.5)
                }
                
                
                ForEach(0..<starCount, id: \.self) { index in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 2, height: 2)
                        .scaleEffect(starScales[index])
                        .opacity(starOpacities[index])
                        .position(
                            x: starPositions[index].x,
                            y: starPositions[index].y
                        )
                        .animation(
                            Animation
                                .easeInOut(duration: Double.random(in: 1.5...3.0))
                                .repeatForever(autoreverses: true)
                                .delay(Double.random(in: 0...2)),
                            value: starOpacities[index]
                        )
                }
                
                ForEach(shootingStars) { star in
                    ShootingStarView(star: star)
                }
            }
            .onAppear {
                startAnimations()
                startShootingStars(in: geometry)
            }
        }
    }
    
    private func startAnimations() {
        isAnimating = true
        
        
        for i in 0..<starCount {
            withAnimation(
                Animation
                    .easeInOut(duration: Double.random(in: 1.5...3.0))
                    .repeatForever(autoreverses: true)
                    .delay(Double.random(in: 0...2))
            ) {
                starOpacities[i] = Double.random(in: 0.4...1.0)
                starScales[i] = CGFloat.random(in: 0.8...1.2)
            }
        }
        
        withAnimation(
            Animation
                .easeInOut(duration: 8)
                .repeatForever(autoreverses: true)
        ) {
            nebulaOffset = CGPoint(x: 50, y: 50)
        }
    }
    
    private func startShootingStars(in geometry: GeometryProxy) {
        Timer.scheduledTimer(withTimeInterval: shootingStarInterval, repeats: true) { _ in
            @MainActor func addShootingStar() {
                let newStar = ShootingStar(
                    id: UUID(),
                    startPoint: CGPoint(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: -50
                    ),
                    angle: .random(in: -30...30),
                    speed: .random(in: 0.5...1.5)
                )
                shootingStars.append(newStar)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    shootingStars.removeAll { $0.id == newStar.id }
                }
            }
            
            Task { @MainActor in
                addShootingStar()
            }
        }
    }
}

struct NebulaEffect: View {
    let color: Color
    @Binding var offset: CGPoint
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: UIScreen.main.bounds.width * 1.5)
            .blur(radius: 60)
            .offset(x: offset.x, y: offset.y)
    }
}

struct ShootingStar: Identifiable {
    let id: UUID
    let startPoint: CGPoint
    let angle: Double
    let speed: Double
}

struct ShootingStarView: View {
    let star: ShootingStar
    @State private var offset: CGFloat = 0
    
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 2, height: 2)
            .blur(radius: 0.5)
            .overlay(
                Circle()
                    .fill(Color.white)
                    .frame(width: 1, height: 1)
                    .blur(radius: 0.2)
                    .offset(x: -15)
                    .opacity(0.8)
            )
            .rotationEffect(.degrees(star.angle))
            .position(star.startPoint)
            .offset(y: offset)
            .onAppear {
                withAnimation(
                    .linear(duration: 1.0 / star.speed)
                ) {
                    offset = UIScreen.main.bounds.height + 100
                }
            }
    }
}

struct EndingQuotes {
    static let quotes = [
        "Every memory with you is a page in our beautiful story.",
        "Small moments make the biggest memories.",
        "Today's little moments become tomorrow's precious memories.",
        "Life is not measured by the breaths we take, but by the moments that take our breath away.",
        "The best thing about memories is making them.",
        "Sometimes the smallest things take up the most room in your heart.",
        "A baby fills a place in your heart that you never knew was empty.",
        "Every day may not be good, but there's something good in every day.",
        "The littlest feet make the biggest footprints in our hearts.",
        "Babies are bits of stardust blown from the hand of God.",
        "A baby is God's opinion that life should go on.",
        "A new baby is like the beginning of all things - wonder, hope, a dream of possibilities."
    ]
    
    static func randomQuote() -> String {
        quotes.randomElement() ?? quotes[0]
    }
}

struct Reminder: Identifiable {
    let id: UUID
    let memoryId: UUID
    var date: Date
    var title: String
    var notes: String
    var voiceRecordingURL: URL?
    var isCompleted: Bool
    
    init(
        id: UUID = UUID(),
        memoryId: UUID,
        date: Date,
        title: String = "",
        notes: String = "",
        voiceRecordingURL: URL? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.memoryId = memoryId
        self.date = date
        self.title = title
        self.notes = notes
        self.voiceRecordingURL = voiceRecordingURL
        self.isCompleted = isCompleted
    }
}

class AudioPlayerManager: NSObject, AVAudioPlayerDelegate, ObservableObject {
    @Published var isPlaying: Bool = false
    var audioPlayer: AVAudioPlayer?
    
    func play(url: URL) {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Playback failed: \(error)")
        }
    }
    
    func stop() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}

struct ReminderView: View {
    @Binding var memory: Memory
    @Binding var babies: [Baby]
    let babyIndex: Int
    var isEditing: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    @State private var reminderDate = Date()
    @State private var notes = ""
    @State private var isRecording = false
    @State private var recordingURL: URL?
    @State private var audioRecorder: AVAudioRecorder?
    @State private var showingDeleteAlert = false
    @State private var reminderTitle = ""
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var isPlayingPreview = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Reminder Details")) {
                    TextField("Title", text: $reminderTitle)
                    DatePicker("Open On", selection: $reminderDate, in: Date()...)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section(header: Text("Voice Notes")) {
                    if let _ = recordingURL {
                        HStack {
                            Image(systemName: "mic.fill")
                                .foregroundColor(Theme.color(for: babies[babyIndex].gender))
                            Text("Voice Note Saved")
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button(action: deleteRecording) {
                                Image(systemName: "trash.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 24))
                            }
                        }
                    } else {
                        Button(action: toggleRecording) {
                            HStack {
                                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                    .foregroundColor(isRecording ? .red : Theme.color(for: babies[babyIndex].gender))
                                    .font(.system(size: 24))
                                Text(isRecording ? "Stop Recording" : "Record Voice Note")
                            }
                        }
                    }
                }
                
                if memory.reminder != nil {
                    Section {
                        Button("Delete Reminder", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Reminder" : "Set Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveReminder()
                }
                .disabled(reminderTitle.isEmpty)
            )
            .onAppear {
                if isEditing, let reminder = memory.reminder {
                    reminderDate = reminder.date
                    reminderTitle = reminder.title
                    notes = reminder.notes
                    recordingURL = reminder.voiceRecordingURL
                }
            }
        }
        .onDisappear {
            audioManager.stop()
            isPlayingPreview = false
        }
    }
    
    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentPath.appendingPathComponent("\(UUID().uuidString).m4a")
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Recording failed: \(error)")
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        recordingURL = audioRecorder?.url
        isRecording = false
    }
    
    private func playRecording() {
        guard let url = recordingURL else { return }
        audioManager.play(url: url)
    }
    
    private func saveReminder() {
        if isEditing {
            let existingNotes = memory.reminder?.notes ?? ""
            let newNotes = existingNotes.isEmpty ? notes : "\(existingNotes)\n\n\(notes)"
            
            let reminder = Reminder(
                id: memory.reminder?.id ?? UUID(),
                memoryId: memory.id,
                date: reminderDate,
                title: reminderTitle,
                notes: newNotes,
                voiceRecordingURL: recordingURL
            )
            var updatedBabies = babies
            if let memoryIndex = updatedBabies[babyIndex].memories.firstIndex(where: { $0.id == memory.id }) {
                updatedBabies[babyIndex].memories[memoryIndex].reminder = reminder
                babies = updatedBabies
            }
        } else {
            let reminder = Reminder(
                memoryId: memory.id,
                date: reminderDate,
                title: reminderTitle,
                notes: notes,
                voiceRecordingURL: recordingURL
            )
            
            var updatedBabies = babies
            if let memoryIndex = updatedBabies[babyIndex].memories.firstIndex(where: { $0.id == memory.id }) {
                updatedBabies[babyIndex].memories[memoryIndex].reminder = reminder
                babies = updatedBabies
            }
        }
        
        scheduleNotification()
        
        dismiss()
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Memory Reminder: \(memory.title)"
        content.body = notes.isEmpty ? "Tap to view this memory" : notes
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = memory.reminder?.id.uuidString ?? UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func deleteReminder() {
        var updatedBabies = babies
        if let memoryIndex = updatedBabies[babyIndex].memories.firstIndex(where: { $0.id == memory.id }) {
            if let reminder = memory.reminder {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
            }
            
            updatedBabies[babyIndex].memories[memoryIndex].reminder = nil
            babies = updatedBabies
        }
        
        dismiss()
    }
    
    private func togglePlayback() {
        if audioManager.isPlaying {
            audioManager.stop()
        } else {
            playRecording()
        }
    }
    
    private func deleteRecording() {
        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
        }
        recordingURL = nil
        audioManager.stop()
    }
}

struct RemindersListView: View {
    @Binding var babies: [Baby]
    let babyIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    private var sortedReminders: [(Memory, Reminder)] {
        let allMemories = babies[babyIndex].memories
        let remindersWithMemories = allMemories.compactMap { memory -> (Memory, Reminder)? in
            guard let reminder = memory.reminder else { return nil }
            return (memory, reminder)
        }
        return remindersWithMemories.sorted { $0.1.date < $1.1.date }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedReminders, id: \.0.id) { memory, reminder in
                    ReminderCard(
                        memory: memory,
                        reminder: reminder,
                        babies: $babies,
                        babyIndex: babyIndex
                    )
                }
                .onDelete { indexSet in
                    deleteReminders(at: indexSet)
                }
            }
            .navigationTitle("Upcoming Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .overlay {
                if sortedReminders.isEmpty {
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView(
                            "No Reminders",
                            systemImage: "bell.slash",
                            description: Text("You haven't set any reminders yet")
                        )
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "bell.slash")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("No Reminders")
                                .font(.headline)
                            Text("You haven't set any reminders yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
    
    private func deleteReminders(at indexSet: IndexSet) {
        var updatedBabies = babies
        for index in indexSet {
            let (memory, reminder) = sortedReminders[index]
            if let memoryIndex = updatedBabies[babyIndex].memories.firstIndex(where: { $0.id == memory.id }) {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
                
                updatedBabies[babyIndex].memories[memoryIndex].reminder = nil
            }
        }
        babies = updatedBabies
    }
}

struct ReminderCard: View {
    let memory: Memory
    let reminder: Reminder
    @Binding var babies: [Baby]
    let babyIndex: Int
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var timeRemaining: String = ""
    @State private var isUnlocked: Bool = false
    @State private var showingDetail = false
    @State private var showingCelebration = false
    @State private var glowOpacity: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var sparkles: [(CGPoint, Double)] = []
    @State private var showShimmer = false
    @State private var showConfetti: Bool = false
    @State private var rotationAngle: Double = 0
    @State private var ribbonOffset: CGFloat = -50
    @State private var ribbonOpacity: Double = 0
    @State private var ribbonScale: CGFloat = 0.5
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var displayTitle: String {
        if !reminder.title.isEmpty {
            return reminder.title
        }
        return memory.title
    }
    
    private func updateTimeRemaining() {
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: reminder.date)
        let wasLocked = !isUnlocked
        isUnlocked = Date() >= reminder.date
        
        if isUnlocked && wasLocked {
           
            withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowOpacity = 0.8
            }
        }
        
        if isUnlocked {
            timeRemaining = "Unlocked"
        } else if let days = components.day, days > 0 {
            timeRemaining = "\(days) day\(days == 1 ? "" : "s")"
        } else if let hours = components.hour, hours > 0 {
            timeRemaining = "\(hours) hour\(hours == 1 ? "" : "s")"
        } else if let minutes = components.minute, minutes > 0 {
            timeRemaining = "\(minutes) minute\(minutes == 1 ? "" : "s")"
        } else if let seconds = components.second {
            timeRemaining = "\(seconds) second\(seconds == 1 ? "" : "s")"
        } else {
            timeRemaining = "Now"
            isUnlocked = true
        }
    }
    
    var body: some View {
        Button(action: {
            if isUnlocked {
                showingDetail = true
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    ZStack(alignment: .topLeading) {
                        Image(uiImage: memory.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        if isUnlocked {
                            Text("🎀")
                                .font(.system(size: 24))
                                .offset(x: -12, y: -12)
                                .opacity(ribbonOpacity)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(displayTitle)
                            .font(.headline)
                            .foregroundColor(isUnlocked ? .green : .primary)
                        
                        Text(reminder.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: isUnlocked ? "lock.open.fill" : "clock")
                                .foregroundColor(isUnlocked ? .green : .orange)
                            Text(timeRemaining)
                                .font(.caption)
                                .foregroundColor(isUnlocked ? .green : .orange)
                        }
                    }
                    
                    Spacer()
                    
                    if reminder.voiceRecordingURL != nil {
                        Image(systemName: "mic.fill")
                            .foregroundColor(isUnlocked ? .green : .blue)
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                Group {
                    if isUnlocked {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.green.opacity(0.1),
                                            Color.green.opacity(0.15)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            ForEach(0..<12) { index in
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.green,
                                                Color.green.opacity(0.5)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: 4, height: 4)
                                    .offset(x: CGFloat.random(in: -50...50), y: showConfetti ? 100 : -100)
                                    .opacity(showConfetti ? 0 : 1)
                                    .animation(
                                        Animation
                                            .easeOut(duration: 1.5)
                                            .repeatForever(autoreverses: false)
                                            .delay(Double(index) * 0.1),
                                        value: showConfetti
                                    )
                            }
                            
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0),
                                            Color.white.opacity(0.5),
                                            Color.white.opacity(0)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .offset(x: showShimmer ? 200 : -200)
                                .opacity(0.3)
                                RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.green.opacity(0.7),
                                            Color.green.opacity(0.3)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                                .scaleEffect(scale)
                        }
                        .rotationEffect(.degrees(rotationAngle))
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                    }
                }
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onChange(of: isUnlocked) { newValue in
            if newValue {
                startUnlockAnimation()
            }
        }
        .onAppear {
            if isUnlocked {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    ribbonOpacity = 1
                }
            }
        }
        .onAppear {
            updateTimeRemaining()
        }
        .onReceive(timer) { _ in
            updateTimeRemaining()
        }
        .sheet(isPresented: $showingDetail) {
            ReminderDetailView(
                memory: memory,
                reminder: reminder,
                babies: $babies,
                babyIndex: babyIndex
            )
        }
    }
    
    private func startUnlockAnimation() {
        ribbonOpacity = 1
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            scale = 1.05
            rotationAngle = 2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(
                Animation
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
            ) {
                scale = 1.02
                rotationAngle = -2
            }
        }
        showConfetti = true
        withAnimation(
            Animation
                .linear(duration: 3)
                .repeatForever(autoreverses: false)
        ) {
            showShimmer = true
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            ribbonOffset = 0
            ribbonScale = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(
                Animation
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
            ) {
                ribbonOffset = -5
            }
        }
    }
}


struct ReminderDetailView: View {
    let memory: Memory
    let reminder: Reminder
    @Binding var babies: [Baby]
    let babyIndex: Int
    @StateObject private var audioManager = AudioPlayerManager()
    @Environment(\.dismiss) private var dismiss
    @State private var showingNotesInput = false
    @State private var showingVoiceRecording = false
    @State private var showingDeleteAlert = false
    
    private var isUnlocked: Bool {
        Date() >= reminder.date
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Image(uiImage: memory.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    VStack(alignment: .leading, spacing: 16) {
                        Text(reminder.title)
                            .font(.title2)
                            .bold()
                        
                        Text("Reminder set for: " + reminder.date.formatted(date: .long, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if !reminder.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes")
                                    .font(.headline)
                                
                                if isUnlocked {
                                    Text(reminder.notes)
                                        .font(.body)
                                } else {
                                    HStack {
                                        Image(systemName: "doc.text.fill")
                                        Text("Notes are locked")
                                        Spacer()
                                        Image(systemName: "lock.fill")
                                    }
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        if let url = reminder.voiceRecordingURL {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Voice Note")
                                    .font(.headline)
                                
                                if isUnlocked {
                                    Button(action: {
                                        if audioManager.isPlaying {
                                            audioManager.stop()
                                        } else {
                                            audioManager.play(url: url)
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                                .font(.system(size: 24))
                                            Text(audioManager.isPlaying ? "Stop Playing" : "Play Voice Note")
                                        }
                                        .foregroundColor(Theme.color(for: babies[babyIndex].gender))
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    }
                                } else {
                                    HStack {
                                        Image(systemName: "mic.fill")
                                        Text("Voice Note is locked")
                                        Spacer()
                                        Image(systemName: "lock.fill")
                                    }
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        if !isUnlocked {
                            VStack(spacing: 16) {
                                Button(action: { showingNotesInput = true }) {
                                    HStack {
                                        Image(systemName: "square.and.pencil")
                                        Text("Add More Notes")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                    }
                                    .foregroundColor(Theme.color(for: babies[babyIndex].gender))
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Theme.color(for: babies[babyIndex].gender), lineWidth: 1)
                                    )
                                }
                                
                                if reminder.voiceRecordingURL != nil {
                                    Button(action: { showingVoiceRecording = true }) {
                                        HStack {
                                            Image(systemName: "mic.fill")
                                            Text("Change Voice Note")
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14))
                                        }
                                        .foregroundColor(Theme.color(for: babies[babyIndex].gender))
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Theme.color(for: babies[babyIndex].gender), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Reminder Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Done") {
                    dismiss()
                },
                trailing: Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            )
        }
        .alert("Delete Reminder?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteReminder()
            }
        } message: {
            Text("Are you sure you want to delete this reminder?")
        }
        .onDisappear {
            audioManager.stop()
        }
        .sheet(isPresented: $showingNotesInput) {
            NotesInputView(
                memory: memory,
                reminder: reminder,
                babies: $babies,
                babyIndex: babyIndex,
                dismiss: { showingNotesInput = false }
            )
        }
        .sheet(isPresented: $showingVoiceRecording) {
            VoiceRecordingView(
                memory: memory,
                reminder: reminder,
                babies: $babies,
                babyIndex: babyIndex
            )
        }
    }
    
    private func deleteReminder() {
        var updatedBabies = babies
        if let memoryIndex = updatedBabies[babyIndex].memories.firstIndex(where: { $0.id == memory.id }) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
            
            updatedBabies[babyIndex].memories[memoryIndex].reminder = nil
            babies = updatedBabies
        }
        dismiss()
    }
}


struct NotesInputView: View {
    let memory: Memory
    let reminder: Reminder
    @Binding var babies: [Baby]
    let babyIndex: Int
    let dismiss: () -> Void
    
    @State private var notes = ""
    @Environment(\.dismiss) private var dismissSheet
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add New Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Notes")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismissSheet()
                },
                trailing: Button("Save") {
                    saveNotes()
                }
                .disabled(notes.isEmpty)
            )
        }
    }
    
    private func saveNotes() {
        var updatedBabies = babies
        if let memoryIndex = updatedBabies[babyIndex].memories.firstIndex(where: { $0.id == memory.id }) {
            var updatedMemory = updatedBabies[babyIndex].memories[memoryIndex]
            var updatedReminder = reminder
            
            let existingNotes = reminder.notes
            updatedReminder.notes = existingNotes.isEmpty ? notes : "\(existingNotes)\n\n\(notes)"
            
            updatedMemory.reminder = updatedReminder
            updatedBabies[babyIndex].memories[memoryIndex] = updatedMemory
            babies = updatedBabies
        }
        
        dismissSheet()
    }
}

struct VoiceRecordingView: View {
    let memory: Memory
    let reminder: Reminder
    @Binding var babies: [Baby]
    let babyIndex: Int
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var isRecording = false
    @State private var recordingURL: URL?
    @State private var audioRecorder: AVAudioRecorder?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Voice Recording")) {
                    if let url = recordingURL {
                        HStack {
                            Image(systemName: "mic.fill")
                                .foregroundColor(Theme.color(for: babies[babyIndex].gender))
                            Text("Voice Note Saved")
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button(action: deleteRecording) {
                                Image(systemName: "trash.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 24))
                            }
                        }
                    } else {
                        Button(action: toggleRecording) {
                            HStack {
                                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                    .foregroundColor(isRecording ? .red : Theme.color(for: babies[babyIndex].gender))
                                    .font(.system(size: 24))
                                    Text(isRecording ? "Stop Recording" : "Record Voice Note")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Change Voice Note")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveVoiceNote()
                }
                .disabled(recordingURL == nil)
            )
        }
    }
    
    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentPath.appendingPathComponent("\(UUID().uuidString).m4a")
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Recording failed: \(error)")
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        recordingURL = audioRecorder?.url
        isRecording = false
    }
    
    private func deleteRecording() {
        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
        }
        recordingURL = nil
    }
    
    private func saveVoiceNote() {
        if let url = recordingURL {
            var updatedBabies = babies
            if let memoryIndex = updatedBabies[babyIndex].memories.firstIndex(where: { $0.id == memory.id }) {
                var updatedMemory = updatedBabies[babyIndex].memories[memoryIndex]
                var updatedReminder = reminder
                updatedReminder.voiceRecordingURL = url
                updatedMemory.reminder = updatedReminder
                updatedBabies[babyIndex].memories[memoryIndex] = updatedMemory
                babies = updatedBabies
            }
        }
        dismiss()
    }
}

struct ReminderActionSheet: View {
    @Binding var memory: Memory
    @Binding var babies: [Baby]
    let babyIndex: Int
    @Environment(\.dismiss) private var dismiss
    @State private var showingNotesInput = false
    @State private var showingVoiceRecording = false
    
    private var isReminderUnlocked: Bool {
        guard let reminder = memory.reminder else { return false }
        return Date() >= reminder.date
    }
    
    var body: some View {
        NavigationView {
            List {
                if let reminder = memory.reminder {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Current Reminder")
                                    .font(.headline)
                                
                                if isReminderUnlocked {
                                    Image(systemName: "lock.open.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            
                            if !reminder.notes.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Previous Notes")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    if isReminderUnlocked {
                                        Text(reminder.notes)
                                            .font(.body)
                                    } else {
                                        HStack {
                                            Image(systemName: "doc.text.fill")
                                            Text("Notes are locked")
                                            Spacer()
                                            Image(systemName: "lock.fill")
                                        }
                                        .foregroundColor(.secondary)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            
                            if !isReminderUnlocked {
                                Divider()
                                    .padding(.vertical)
                                
                                VStack(spacing: 16) {
                                    Button(action: { showingNotesInput = true }) {
                                        HStack {
                                            Image(systemName: "square.and.pencil")
                                            Text("Add More Notes")
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray)
                                        }
                                        .foregroundColor(Theme.color(for: babies[babyIndex].gender))
                                    }
                                    
                                    if reminder.voiceRecordingURL != nil {
                                        Button(action: { showingVoiceRecording = true }) {
                                            HStack {
                                                Image(systemName: "mic.fill")
                                                Text("Change Voice Note")
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.gray)
                                            }
                                            .foregroundColor(Theme.color(for: babies[babyIndex].gender))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Reminder Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
        .sheet(isPresented: $showingNotesInput) {
            NotesInputView(
                memory: memory,
                reminder: memory.reminder!,
                babies: $babies,
                babyIndex: babyIndex,
                dismiss: { showingNotesInput = false }
            )
        }
        .sheet(isPresented: $showingVoiceRecording) {
            VoiceRecordingView(
                memory: memory,
                reminder: memory.reminder!,
                babies: $babies,
                babyIndex: babyIndex
            )
        }
    }
}
