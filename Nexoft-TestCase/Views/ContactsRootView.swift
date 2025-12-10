//
//  ContactsRootView.swift
//  Nexoft-TestCase
//
//  Created by Talha Batuhan Irmalı on 8.12.2025.
//

import SwiftUI
import SwiftData

struct ContactsRootView: View {
    @StateObject private var viewModel: ContactsViewModel
    @StateObject private var searchHistoryManager = SearchHistoryManager.shared
    @State private var searchText: String = ""
    @State private var isPresentingAddContact = false
    @State private var selectedContact: Contact?
    @FocusState private var isSearchFocused: Bool

    init(viewModel: ContactsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0xF6/255, green: 0xF6/255, blue: 0xF6/255)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    searchBar
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 12)

                    if isSearchFocused && searchText.isEmpty && !searchHistoryManager.searchHistory.isEmpty {
                        searchHistoryView
                        Spacer()
                    } else if viewModel.isLoading && viewModel.contacts.isEmpty {
                        Spacer()
                        loadingView
                        Spacer()
                    } else if viewModel.contacts.isEmpty && searchText.isEmpty {
                        emptyState
                        Spacer()
                    } else if !searchText.isEmpty && filteredContacts.isEmpty {
                        noResultsView
                        Spacer()
                    } else {
                        contactsList
                    }
                }
                .onTapGesture {
                    hideKeyboard()
                }
                .navigationTitle("Contacts")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isPresentingAddContact = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                        }
                    }
                }
                .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                    Button("OK") {
                        viewModel.errorMessage = nil
                    }
                } message: {
                    if let error = viewModel.errorMessage {
                        Text(error)
                    }
                }

                if viewModel.showSuccessMessage {
                    SuccessOverlayView(message: "New contact saved")
                        .animation(.spring(), value: viewModel.showSuccessMessage)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                                withAnimation {
                                    viewModel.showSuccessMessage = false
                                }
                            }
                        }
                }

                if viewModel.showDeleteSuccessMessage {
                    VStack {
                        Spacer()
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.green)

                            Text("User is deleted!")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)

                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                viewModel.showDeleteSuccessMessage = false
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isPresentingAddContact, onDismiss: {
            viewModel.refreshFromLocalDatabase()
        }) {
            NewContactView { newContact in
                await viewModel.addContact(newContact)
            }
            .presentationCornerRadius(25)
        }
        .sheet(item: Binding(
            get: { selectedContact },
            set: { selectedContact = $0 }
        )) { contact in
            EditContactView(
                contact: contact,
                startInEditMode: viewModel.shouldStartInEditMode,
                onSave: { updatedContact in
                    await viewModel.updateContact(updatedContact)
                },
                onDelete: { contactToDelete in
                    await viewModel.deleteContact(contactToDelete)
                }
            )
            .presentationCornerRadius(25)
            .onAppear {
                print("✅ Sheet appeared with contact: \(contact.fullName)")
            }
            .onDisappear {
                print("🔴 Sheet dismissed")
                selectedContact = nil
                viewModel.shouldStartInEditMode = false
                // Refresh to update phone contact status
                viewModel.refreshFromLocalDatabase()
            }
        }
        .onAppear {
            viewModel.loadContacts()
        }
    }

    // MARK: - Subviews

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search by name", text: $searchText)
                .focused($isSearchFocused)
                .onSubmit {
                    if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                        searchHistoryManager.addSearchQuery(searchText)
                    }
                }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
//            Image(systemName: "person.crop.circle")
//                .font(.system(size: 72))
//                .foregroundStyle(Color(.systemGray3))
//                .padding(.top, 80)
            Image("person")
                .resizable()
                .frame(width: 72, height: 72)
                .padding(.top, 80)

            Text("No Contacts")
                .font(.headline)

            Text("Contacts you've added will appear here.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button {
                isPresentingAddContact = true
            } label: {
                Text("Create New Contact")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding(.top, 4)
        }
    }

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image("nodata")
                .resizable()
                .frame(width: 96, height: 96)
                .padding(.top, 40)

            Text("No Results")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)

            Text("The user you are looking for could not be found.")
                .font(.system(size: 16))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    private var searchHistoryView: some View {
        let history = searchHistoryManager.searchHistory

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("SEARCH HISTORY")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0xB0/255, green: 0xB0/255, blue: 0xB0/255))

                Spacer()

                Button {
                    searchHistoryManager.clearAllHistory()
                } label: {
                    Text("Clear All")
                        .font(.system(size: 13))
                        .foregroundColor(.blue)
                        .underline()
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 12)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(history.indices, id: \.self) { index in
                        let query = history[index]

                        HStack(spacing: 12) {
                            Button {
                                searchHistoryManager.removeSearchQuery(query)
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }

                            Button {
                                searchText = query
                                isSearchFocused = false
                            } label: {
                                HStack {
                                    Text(query)
                                        .font(.system(size: 15))
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white)

                        if index != history.count - 1 {
                            Divider()
                                .padding(.leading, 40)
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            hideKeyboard()
        }
    }

    private var contactsList: some View {
        let sortedKeys = groupedContacts.keys.sorted()

        return ScrollView {
            LazyVStack(spacing: 0, pinnedViews: []) {
                ForEach(Array(sortedKeys.enumerated()), id: \.element) { index, letter in
                    let sectionContacts = groupedContacts[letter] ?? []
                    let isFirstSection = index == 0

                    VStack(spacing: 0) {
                        HStack {
                            Text((isSearchActive && isFirstSection) ? "TOP NAME MATCHES" : letter)
                                .font(.system(size: (isSearchActive && isFirstSection) ? 14 : 17, weight: (isSearchActive && isFirstSection) ? .medium : .medium))
                                .foregroundColor((isSearchActive && isFirstSection) ? Color(red: 0xB0/255, green: 0xB0/255, blue: 0xB0/255) : .secondary)
                                .padding(.leading, 16)
                                .padding(.top, 12)
                                .padding(.bottom, 8)
                            Spacer()
                        }
                        .background(Color.white)
                        .onTapGesture {
                            hideKeyboard()
                        }

                        // Contacts in section
                        ForEach(sectionContacts) { contact in
                            SwipeableContactRow(
                                contact: contact,
                                onTap: {
                                    hideKeyboard()
                                    print("🔵 Row tapped: \(contact.fullName) - ID: \(contact.id)")
                                    selectedContact = contact
                                    print("🟢 selectedContact set to: \(selectedContact?.fullName ?? "nil")")
                                },
                                onEdit: {
                                    hideKeyboard()
                                    viewModel.shouldStartInEditMode = true
                                    selectedContact = contact
                                },
                                onDelete: {
                                    Task {
                                        await viewModel.deleteContact(contact)
                                    }
                                }
                            )
                            .id("\(contact.id)-\(contact.firstName)-\(contact.lastName)-\(contact.phoneNumber)-\(contact.localImageData?.hashValue ?? 0)-\(contact.isInDeviceContacts)")

                            if contact.id != sectionContacts.last?.id {
                                Divider()
                                    .padding(.horizontal, 16)
                                    .background(Color.white)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
        }
        .scrollIndicators(.visible)
        .scrollDisabled(false)
        .onTapGesture {
            hideKeyboard()
        }
    }

    private var filteredContacts: [Contact] {
        viewModel.filteredContacts(searchText: searchText)
    }

    private var groupedContacts: [String: [Contact]] {
        Dictionary(grouping: filteredContacts) { contact in
            String(contact.fullName.prefix(1).uppercased())
        }
    }

    private var isSearchActive: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func hideKeyboard() {
        isSearchFocused = false
    }
}

// MARK: - Contact Row

struct ContactRowView: View {
    let contact: Contact

    var body: some View {
        HStack(spacing: 12) {
            ContactAvatarView(contact: contact)

            VStack(alignment: .leading, spacing: 2) {
                Text(contact.fullName)
                    .font(.body)
                    .fontWeight(.medium)
                Text(contact.phoneNumber)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

// MARK: - Contact Avatar with Initial

struct ContactAvatarView: View {
    let contact: Contact

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let image = contact.avatarImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                } else {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0xED/255, green: 0xFA/255, blue: 0xFF/255))
                            .frame(width: 44, height: 44)

                        Text(contact.fullName.prefix(1).uppercased())
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(red: 0x00/255, green: 0x7A/255, blue: 0xFF/255))
                    }
                }
            }

            if contact.isInDeviceContacts {
                Image("telephone")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .offset(x: 2, y: 2)
            }
        }
        .frame(width: 44, height: 44)
    }
}

// MARK: - Swipeable Contact Row

struct SwipeableContactRow: View {
    let contact: Contact
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var offset: CGFloat = 0
    @State private var isSwiping = false
    @State private var showDeleteConfirmation = false

    private let actionButtonsWidth: CGFloat = 160

    var body: some View {
        ZStack(alignment: .trailing) {
            // Action buttons (background)
            HStack(spacing: 0) {
                Spacer()

                Button(action: {
                    onEdit()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        offset = 0
                    }
                }) {
                    VStack(spacing: 4) {
                        Image("edit")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 16,height: 16)
                            .foregroundColor(.white)
                    }
                    .foregroundColor(.white)
                    .frame(width: 56)
                }
                .frame(maxHeight: .infinity)
                .background(Color.blue)

                Button(action: {
                    showDeleteConfirmation = true
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        offset = 0
                    }
                }) {
                    VStack(spacing: 4) {
                        Image("delete")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 16,height: 16)
                            .foregroundColor(.white)
                    }
                    .foregroundColor(.white)
                    .frame(width: 56)
                }
                .frame(maxHeight: .infinity)
                .background(Color.red)
            }

            ContactRowView(contact: contact)
                .background(Color.white)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            isSwiping = true
                            let translation = gesture.translation.width
                            if translation < 0 {
                                offset = max(translation, -actionButtonsWidth)
                            } else if offset < 0 {
                                offset = min(0, offset + translation)
                            }
                        }
                        .onEnded { gesture in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                if offset < -actionButtonsWidth / 2 {
                                    offset = -actionButtonsWidth
                                } else {
                                    offset = 0
                                }
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isSwiping = false
                            }
                        }
                )
                .onTapGesture {
                    if !isSwiping && offset == 0 {
                        onTap()
                    } else if offset != 0 {
                        // Close swipe
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            offset = 0
                        }
                    }
                }
        }
        .clipped()
        .sheet(isPresented: $showDeleteConfirmation) {
            DeleteConfirmationSheet(
                contactName: contact.fullName,
                onConfirm: {
                    showDeleteConfirmation = false
                    onDelete()
                },
                onCancel: {
                    showDeleteConfirmation = false
                }
            )
            .presentationDetents([.height(250)])
            .presentationCornerRadius(22)
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Delete Confirmation Sheet

struct DeleteConfirmationSheet: View {
    let contactName: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Delete Contact")
                    .font(.system(size: 20, weight: .semibold))

                Text("Are you sure you want to delete this contact?")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 32)

            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text("No")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                        )
                }

                Button(action: onConfirm) {
                    Text("Yes")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color.black)
                        )
                }
            }
            .padding(.horizontal, 16)

            Spacer()
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Preview

struct ContactsRootView_Previews: PreviewProvider {
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: UserEntity.self, configurations: config)
        let viewModel = ContactsViewModel(modelContext: container.mainContext)

        return ContactsRootView(viewModel: viewModel)
    }
}
