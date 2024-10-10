//
//  CPLookupView.swift
//  commproviderlookup
//
//  Created by Yannick McCabe-Costa on 10/10/2024.
//

import Foundation
import SwiftUI
import PhoneNumberKit
import Combine

struct CPLookupView: View {
    @State private var phoneNumber: String = ""
    @State private var searchResults: [PhoneNumberDBResult] = []
    @State private var isValidNumber: Bool? = nil
    @State private var showWelcomeMessage = true
    private let phoneNumberUtility = PhoneNumberUtility()
    private var dbHelper = DatabaseHelper()
    @State private var debounceCancellable: AnyCancellable?

    private let statusDescriptions: [String: String] = [
       "Allocated": "This number range has been allocated to a Communication Provider for use on inbound and outbound calling.",
       "Allocated(Closed Range)": "This number range has been allocated to a Communication Provider for use on inbound and outbound calling, and additionally no further numbers from this range are to be allocated.",
       "Designated": "This number range is currently designated, and should not be being used for outbound calls. If you have received a call from a number in this range, you should report it to your teleocmmunications provider.",
       "Free": "This number range is available for general allocation to an eligible Communication Provider.",
       "Free for National Dialling Only": "This number range is available for general allocation to an eligible Communication Provider for the use of dialling UK National Numbers only.",
       "Protected": "This number range is currently protected, and should not be being used for outbound calls. If you have received a call from a number in this range, you should report it to your teleocmmunications provider.",
       "Quarantined": "This number range is currently quarantined, and should not be being used for outbound calls. If you have received a call from a number in this range, you should report it to your teleocmmunications provider.",
       "Requested": "This number range has bene requested by a communications provider, and should not YET be being used for outbound calls. If you have received a call from a number in this range, you should report it to your teleocmmunications provider.",
       "Reserved": "This number range is currently reserved, and should not be being used for outbound calls. If you have received a call from a number in this range, you should report it to your teleocmmunications provider."
   ]

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                TextFieldWithDoneButton(text: $phoneNumber, placeholder: "Enter Phone Number", isNumeric: true)
                    .padding(10)
                    .background(isValidNumber == false ? Color.red.opacity(0.1) : Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        HStack {
                            Spacer()
                            if !phoneNumber.isEmpty {
                                Button(action: {
                                    phoneNumber = ""
                                    isValidNumber = nil
                                    searchResults = []
                                    showWelcomeMessage = true
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                    )
                    .onChange(of: phoneNumber) {
                        if !phoneNumber.isEmpty {
                            showWelcomeMessage = false
                        }
                        debounceTextInput(phoneNumber)
                    }
            }
            .padding()

            if showWelcomeMessage {
                Spacer()
                VStack(spacing: 8) {
                    Text("Telco.Tools Lookup")
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                    Text("""
                        Welcome, to begin, type the UK phone number you wish to lookup in the box above, or select one of the other tabs below.
                        
                        You can enter phone numbers in standard UK format (01234567890), or in E.164 format (441234567890). If you receive an invalid number message and you are sure it is correct, please raise a bug in our Github.
                        """)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding()
                Spacer()
            } else {
                if let isValid = isValidNumber {
                    Text(isValid ? "Valid UK Phone Number" : "Invalid Phone Number")
                        .foregroundColor(isValid ? .green : .red)
                        .font(.caption)
                        .padding(.top, -8)
                }
                
                List(searchResults, id: \.prefix) { result in
                    VStack(spacing: 5) {
                        Text(result.cp)
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 5)
                        
                        HStack {
                            Text("Prefix: ")
                            Text("+44" + result.prefix)
                                .bold()
                            .padding(.top, 5)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Text("Status: ")
                            Text(result.status)
                                .bold()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if let description = statusDescriptions[result.status], !description.isEmpty {
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 5)
                        }
                    }
                    .padding()
                    .background(result.status == "Allocated" ? Color.clear : Color.yellow.opacity(0.2))
                    .cornerRadius(8)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("CP Lookup")
        .animation(.easeInOut, value: showWelcomeMessage)
    }

    private func debounceTextInput(_ newValue: String) {
        debounceCancellable?.cancel()
        debounceCancellable = Just(newValue)
            .delay(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { value in
                validateAndFormatNumber()
            }
    }

    private func validateAndFormatNumber() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let parsedNumber = try phoneNumberUtility.parse(phoneNumber, withRegion: "GB")
                
                DispatchQueue.main.async {
                    isValidNumber = true
                    var formattedNumber = phoneNumberUtility.format(parsedNumber, toType: .e164)
                    if formattedNumber.hasPrefix("+44") {
                        formattedNumber.removeFirst(3)
                    } else if formattedNumber.hasPrefix("44") {
                        formattedNumber.removeFirst(2)
                    }
                    
                    performLookup(for: formattedNumber)
                }
            } catch {
                DispatchQueue.main.async {
                    isValidNumber = false
                    searchResults = []
                }
            }
        }
    }

    private func performLookup(for strippedNumber: String) {
        var prefixes = [strippedNumber]
        for i in stride(from: strippedNumber.count - 1, to: 0, by: -1) {
            prefixes.append(String(strippedNumber.prefix(i)))
        }
        searchResults = dbHelper.searchLongestPrefixMatching(phonePrefixes: prefixes)
    }
}
