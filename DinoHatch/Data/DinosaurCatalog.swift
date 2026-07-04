import Foundation

enum DinosaurCatalog {
    static let all: [Dinosaur] = [
        Dinosaur(
            id: "t-rex",
            name: "Tyrannosaurus Rex",
            era: "Late Cretaceous",
            diet: .carnivore,
            length: "12 m (40 ft)",
            funFact: "T-Rex had teeth as long as bananas and one of the strongest bites of any animal ever!",
            symbolName: "flame.fill",
            emoji: "🦖",
            imageAssetName: nil,
            rarity: .rare
        ),
        Dinosaur(
            id: "triceratops",
            name: "Triceratops",
            era: "Late Cretaceous",
            diet: .herbivore,
            length: "9 m (30 ft)",
            funFact: "Triceratops had three horns and a giant bony frill to protect its neck from predators!",
            symbolName: "shield.fill",
            emoji: "🦕",
            imageAssetName: nil,
            rarity: .common
        ),
        Dinosaur(
            id: "velociraptor",
            name: "Velociraptor",
            era: "Late Cretaceous",
            diet: .carnivore,
            length: "2 m (6.8 ft)",
            funFact: "Velociraptors were fast, smart hunters that likely had feathers, just like birds today!",
            symbolName: "wind",
            emoji: "🐦",
            imageAssetName: nil,
            rarity: .uncommon
        ),
        Dinosaur(
            id: "brachiosaurus",
            name: "Brachiosaurus",
            era: "Late Jurassic",
            diet: .herbivore,
            length: "21 m (69 ft)",
            funFact: "Brachiosaurus had front legs longer than its back legs, kind of like a giraffe!",
            symbolName: "tree.fill",
            emoji: "🌿",
            imageAssetName: nil,
            rarity: .common
        ),
        Dinosaur(
            id: "stegosaurus",
            name: "Stegosaurus",
            era: "Late Jurassic",
            diet: .herbivore,
            length: "9 m (30 ft)",
            funFact: "Stegosaurus had bony plates on its back and dangerous spikes on its tail called a thagomizer!",
            symbolName: "triangle.fill",
            emoji: "🦕",
            imageAssetName: nil,
            rarity: .common
        ),
        Dinosaur(
            id: "spinosaurus",
            name: "Spinosaurus",
            era: "Mid Cretaceous",
            diet: .carnivore,
            length: "15 m (49 ft)",
            funFact: "Spinosaurus had a huge sail on its back and loved to swim and hunt fish!",
            symbolName: "water.waves",
            emoji: "🐊",
            imageAssetName: nil,
            rarity: .rare
        ),
        Dinosaur(
            id: "ankylosaurus",
            name: "Ankylosaurus",
            era: "Late Cretaceous",
            diet: .herbivore,
            length: "6.5 m (21 ft)",
            funFact: "Ankylosaurus was covered in bony armor and had a big club at the end of its tail!",
            symbolName: "shield.lefthalf.filled",
            emoji: "🛡️",
            imageAssetName: nil,
            rarity: .uncommon
        ),
        Dinosaur(
            id: "pteranodon",
            name: "Pteranodon",
            era: "Late Cretaceous",
            diet: .carnivore,
            length: "6 m (20 ft) wingspan",
            funFact: "Pteranodon wasn't a dinosaur at all, it was a flying reptile that soared over the oceans!",
            symbolName: "bird.fill",
            emoji: "🦅",
            imageAssetName: nil,
            rarity: .uncommon
        ),
        Dinosaur(
            id: "parasaurolophus",
            name: "Parasaurolophus",
            era: "Late Cretaceous",
            diet: .herbivore,
            length: "10 m (33 ft)",
            funFact: "Parasaurolophus had a long curved crest that it may have used to make loud honking sounds!",
            symbolName: "speaker.wave.3.fill",
            emoji: "📯",
            imageAssetName: nil,
            rarity: .common
        ),
        Dinosaur(
            id: "diplodocus",
            name: "Diplodocus",
            era: "Late Jurassic",
            diet: .herbivore,
            length: "33 m (108 ft)",
            funFact: "Diplodocus had one of the longest tails of any dinosaur, which it may have cracked like a whip!",
            symbolName: "arrow.left.and.right",
            emoji: "🦕",
            imageAssetName: nil,
            rarity: .rare
        ),
        Dinosaur(
            id: "allosaurus",
            name: "Allosaurus",
            era: "Late Jurassic",
            diet: .carnivore,
            length: "9.7 m (32 ft)",
            funFact: "Allosaurus was one of the top predators of its time, with sharp teeth like curved knives!",
            symbolName: "bolt.fill",
            emoji: "🦖",
            imageAssetName: nil,
            rarity: .uncommon
        ),
        Dinosaur(
            id: "pachycephalosaurus",
            name: "Pachycephalosaurus",
            era: "Late Cretaceous",
            diet: .herbivore,
            length: "4.5 m (15 ft)",
            funFact: "Pachycephalosaurus had a thick dome skull that may have been used for head-butting contests!",
            symbolName: "circle.fill",
            emoji: "🪨",
            imageAssetName: nil,
            rarity: .uncommon
        ),
        Dinosaur(
            id: "iguanodon",
            name: "Iguanodon",
            era: "Early Cretaceous",
            diet: .herbivore,
            length: "10 m (33 ft)",
            funFact: "Iguanodon had a sharp thumb spike on each hand, maybe used for defense or finding food!",
            symbolName: "hand.point.up.fill",
            emoji: "👍",
            imageAssetName: nil,
            rarity: .common
        ),
        Dinosaur(
            id: "compsognathus",
            name: "Compsognathus",
            era: "Late Jurassic",
            diet: .carnivore,
            length: "1 m (3.3 ft)",
            funFact: "Compsognathus was about the size of a chicken, making it one of the smallest known dinosaurs!",
            symbolName: "hare.fill",
            emoji: "🐔",
            imageAssetName: nil,
            rarity: .common
        )
    ]
}
