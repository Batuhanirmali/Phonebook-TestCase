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
    @State private var searchText: String = ""
    @State private var isPresentingAddContact = false

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

                    if viewModel.isLoading && viewModel.contacts.isEmpty {
                        loadingView
                    } else if viewModel.contacts.isEmpty && searchText.isEmpty {
                        emptyState
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
            }
        }
        .sheet(isPresented: $isPresentingAddContact) {
            NewContactView { newContact in
                await viewModel.addContact(newContact)
            }
            .presentationCornerRadius(25)
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
                .padding(.top, 80)
            Text("Loading contacts...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 72))
                .foregroundStyle(Color(.systemGray3))
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

    private var contactsList: some View {
        List {
            ForEach(groupedContacts.keys.sorted(), id: \.self) { letter in
                Section {
                    // Section header inside the card
                    HStack {
                        Text(letter)
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.leading, 16)
                            .padding(.top, 12)
                            .padding(.bottom, 8)
                        Spacer()
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.white)

                    ForEach(groupedContacts[letter] ?? []) { contact in
                        ContactRowView(contact: contact)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.white)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    Task {
                                        await viewModel.deleteContact(contact)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }

                        if contact.id != groupedContacts[letter]?.last?.id {
                            Divider()
                                .padding(.leading, 60)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.white)
                        }
                    }
                }
                .listSectionSeparator(.hidden)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 0)
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
    }

    private var filteredContacts: [Contact] {
        viewModel.filteredContacts(searchText: searchText)
    }

    private var groupedContacts: [String: [Contact]] {
        Dictionary(grouping: filteredContacts) { contact in
            String(contact.fullName.prefix(1).uppercased())
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
