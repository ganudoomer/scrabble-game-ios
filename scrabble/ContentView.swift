//
//  ContentView.swift
//  scrabble
//
//  Created by Sree on 20/09/21.
//

import SwiftUI
// Add word to the list
struct ContentView: View {
    @State private var useWords = [String]()
    @State private var rootWord = ""
    @State private var newWord  = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var score = 0
    var body: some View {
        NavigationView{
            VStack {
                Spacer()
                TextField("Enter your word",text:
                        // onCommit is called when return is pressed
                            $newWord,onCommit:addNewWord).textFieldStyle(RoundedBorderTextFieldStyle()).padding().autocapitalization(.none)
                Text("Your Score is \(self.score) ")
                    .font(.title2)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .padding(.all)
                    .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color(hue: 1.0, saturation: 0.123, brightness: 0.79)/*@END_MENU_TOKEN@*/)
                    .cornerRadius(/*@START_MENU_TOKEN@*/50.0/*@END_MENU_TOKEN@*/)
                    .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
                List(useWords,id: \.self){ word in
                    HStack{
                        Image(systemName: "\(word.count).circle")
                        Text(word)
                    }.accessibilityElement()
                        .accessibilityLabel("\(word)")
                        .accessibilityHint(" \(word.count) letters")
                 
                }
            }.navigationBarItems(
                trailing:
                    Button("Start Game") {
                        self.startGame()
                    }
            ).navigationBarTitle(rootWord).onAppear(perform: startGame).alert(isPresented: $showingError){
                Alert(title: Text(errorTitle), message: Text(errorMessage),dismissButton: .default(Text("Ok")))

            }
        }
    }
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {
            return
        }
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word")
            return
        }
        score+=1
        useWords.insert(answer, at: 0)
        newWord=""
    }
    
    func startGame(){
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try?
                String(contentsOf: startWordURL) {
                let allWords = startWords.components(separatedBy:"\n")
                repeat {
                    rootWord = allWords.randomElement() ?? "silkworm"
                }while(rootWord.count <= 3);
           
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle ")
    }
    
    func isOriginal(word: String) -> Bool {
        !useWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        for letter in word {
        if let pos = tempWord.firstIndex(of: letter){
            tempWord.remove(at: pos)
        } else {
            return false
         }
       }
     return true
    }
    
    func isReal(word:String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0,length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message:String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
