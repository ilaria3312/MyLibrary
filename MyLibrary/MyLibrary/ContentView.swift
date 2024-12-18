//
//  ContentView.swift
//  MyLibrary
//
//  Created by Ilaria Zampella on 14/12/24.
//

import SwiftUI
import UIKit

struct WoodenLibraryHomePage: View {
    @State private var books: [Book] = [] // Start with no books
    @State private var searchQuery: String = "" // Search query
    @State private var selectedTab: AppTab = .library // Current selected tab
    @State private var isAddingBook: Bool = false // State to control the modal visibility
    @State private var selectedBook: Book? = nil // Track selected book for editing

    private let booksPerShelf = 5 // Number of books each shelf can hold
    private let shelfHeight: CGFloat = 120 // Height of a single shelf

    var body: some View {
        ZStack {
            // Main TabView
            TabView(selection: $selectedTab) {
                // Library Tab
                NavigationView {
                    ZStack {
                        VStack(spacing: 0) {
                            // Search Bar and Shelves
                            VStack {
                                HStack {
                                    TextField("Search books...", text: $searchQuery)
                                        .padding(10)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                        .padding([.leading, .trailing], 10)
                                        .overlay(
                                            HStack {
                                                Spacer()
                                                Image(systemName: "magnifyingglass")
                                                    .foregroundColor(.gray)
                                                    .padding(.trailing, 20)
                                            }
                                        )
                                }
                                .padding(.top)
                                
                                Spacer().frame(height: 20) // Space under search bar
                            }
                            shelfScrollView
                        }
                    }
                    .navigationBarHidden(true)
                }
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
                .tag(AppTab.library)

                // Categories Tab
                NavigationView {
                    CategoriesView() // Use the CategoriesView here
                }
                .tabItem {
                    Label("Categories", systemImage: "list.bullet")
                }
                .tag(AppTab.settings) // Use the existing tag for "Categories"
            }


            // Custom Floating "+" Button in the Tab Bar
            VStack {
                Spacer()
                HStack {
                    Spacer()

                    // Floating "+" Button in the Center
                    Button(action: {
                        isAddingBook = true
                        selectedBook = nil // Reset selected book to indicate adding new book
                    }) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.system(size: 30, weight: .bold))
                            )
                            .shadow(radius: 5)
                    }
                    .offset(y: -15) // Slightly elevate the button above the tab bar
                    .sheet(isPresented: $isAddingBook) {
                        AddBookView(isPresented: $isAddingBook, selectedBook: $selectedBook) { newBook in
                            if let book = selectedBook {
                                // Update the existing book
                                if let index = books.firstIndex(where: { $0.id == book.id }) {
                                    books[index] = newBook // Update the book at the selected index
                                }
                            } else {
                                // Add the new book to the library
                                books.append(newBook)
                            }
                        }
                    }

                    Spacer()
                }
            }
        }
    }

    // MARK: - Filtered Books
    private var filteredBooks: [Book] {
        if searchQuery.isEmpty {
            return books
        } else {
            return books.filter { $0.title.localizedCaseInsensitiveContains(searchQuery) }
        }
    }

    // Shelf ScrollView
    private var shelfScrollView: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(shelfRows.indices, id: \.self) { shelfIndex in
                    ShelfView(books: shelfRows[shelfIndex], onBookTap: bookTapped)
                        .frame(height: shelfHeight)
                        .frame(maxWidth: UIScreen.main.bounds.width)
                }
            }
        }
        .background(Color(UIColor.systemBackground))
    }

    // Helper property to calculate the rows of books
    private var shelfRows: [[Book]] {
        var rows: [[Book]] = []
        var currentRow: [Book] = []

        // Create a row for each shelf
        for book in filteredBooks {
            currentRow.append(book)

            // When we reach the max number of books per shelf, create a new row
            if currentRow.count == booksPerShelf {
                rows.append(currentRow)
                currentRow = []
            }
        }

        // Add the remaining books in the last row if any
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }

        // Ensure there are enough rows to fill the screen, even if empty
        let neededRows = calculateMinimumShelves() - rows.count
        if neededRows > 0 {
            rows.append(contentsOf: Array(repeating: [], count: neededRows))
        }

        return rows
    }

    // Book tapped action to show modal
    private func bookTapped(book: Book) {
        selectedBook = book
        isAddingBook = true
    }

    // Calculate minimum shelves to cover the screen
    private func calculateMinimumShelves() -> Int {
        let screenHeight = UIScreen.main.bounds.height
        let neededShelves = Int(ceil(screenHeight / shelfHeight))
        let currentShelves = Int(ceil(Double(filteredBooks.count) / Double(booksPerShelf)))
        return max(neededShelves, currentShelves)
    }
}

// Remaining code remains the same, but all `.accessibility()` modifiers have been removed.


// MARK: - AddBookView
struct AddBookView: View {
    @Binding var isPresented: Bool
    @Binding var selectedBook: Book?
    var onAddBook: (Book) -> Void

    @State private var title: String = ""
    @State private var author: String = ""
    @State private var genre: String = ""
    @State private var publisher: String = ""
    @State private var rating: Int = 0
    @State private var coverImage: UIImage? = nil
    @State private var showImagePicker: Bool = false

    var body: some View {
        NavigationView {
            Form {
                // Cover Section
                Section(header: Text("Cover")) {
                    if let coverImage = coverImage {
                        Image(uiImage: coverImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(8)
                            .onTapGesture {
                                showImagePicker = true
                            }
                    } else {
                        Button("Select Cover Image") {
                            showImagePicker = true
                        }
                    }
                }

                // Book Details Section
                Section(header: Text("Book Details")) {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                }

                // Genre Section
                Section(header: Text("Genre")) {
                    TextField("Genre", text: $genre)
                }

                // Publisher Section
                Section(header: Text("Publisher")) {
                    TextField("Publisher", text: $publisher)
                }

                // Rating Section
                Section(header: Text("Rating")) {
                    HStack {
                        ForEach(1..<6) { star in
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .foregroundColor(star <= rating ? .yellow : .gray)
                                .onTapGesture {
                                    rating = star
                                }
                        }
                    }
                }
            }
            .navigationBarTitle(selectedBook == nil ? "Add New Book" : "Edit Book", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button(selectedBook == nil ? "Add" : "Save") {
                    let newBook = Book(
                        title: title,
                        author: author,
                        coverImage: coverImage,
                        genre: genre,
                        publisher: publisher,
                        rating: rating
                    )
                    onAddBook(newBook)
                    isPresented = false
                }
                .disabled(title.isEmpty || author.isEmpty)
            )
            .onAppear {
                if let book = selectedBook {
                    title = book.title
                    author = book.author
                    genre = book.genre
                    publisher = book.publisher
                    rating = book.rating
                    coverImage = book.coverImage
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $coverImage)
            }
        }
    }
}

// MARK: - ImagePicker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - ShelfView
struct ShelfView: View {
    let books: [Book]
    var onBookTap: (Book) -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Image("single_shelf")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width)

            HStack(spacing: 10) {
                ForEach(books) { book in
                    BookView(book: book, onBookTap: onBookTap)
                }
                Spacer()
            }
            .padding([.leading, .trailing], 20)
        }
    }
}

// MARK: - BookView
struct BookView: View {
    let book: Book
    private let bookHeight: CGFloat = 110
    var onBookTap: (Book) -> Void

    var body: some View {
        if let coverImage = book.coverImage {
            Image(uiImage: coverImage)
                .resizable()
                .scaledToFit()
                .frame(height: bookHeight)
                .cornerRadius(5)
                .padding(.top, 25)
                .onTapGesture {
                    onBookTap(book)
                }
        } else {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.green)
                .frame(width: bookHeight * 0.4, height: bookHeight)
                .overlay(
                    Text(book.title)
                        .font(.caption)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .padding(2),
                    alignment: .bottom
                )
                .padding(.top, 10)
                .onTapGesture {
                    onBookTap(book)
                }
        }
    }
}

// MARK: - Book Model
struct Book: Identifiable {
    let id = UUID()
    var title: String
    var author: String
    var coverImage: UIImage?
    var genre: String
    var publisher: String
    var rating: Int
}

// MARK: - AppTab Enum
enum AppTab {
    case library
    case settings
}

// MARK: - Preview
struct WoodenLibraryHomePage_Previews: PreviewProvider {
    static var previews: some View {
        WoodenLibraryHomePage()
    }
}
