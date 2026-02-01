-- Modules/DadJokes.lua - Dad Jokes Module

Dadabase = Dadabase or {}

local defaultJokes = {
    "What do ducks like on their tacos? Quackamole and Beako de Gallo",
    "Did you know Vin Diesel only eats 2 meals a day? BreakFAST and BreakFURIOUS!",
    "I don't like German sausages. They are the wurst",
    "Which vegetable do you stand in line for? A queue cumber.",
    "Everyone knows Albert Einstein was brilliant. His brother Frank, though, was a real monster.",
    "My wife says I'm the cheapest man in the world. Well, I'm not buying it.",
    "The Flat Earth Society just announced they now have one million members...around the globe.",
    "What do you call a funny drawing? A Snickerdoodle",
    "A friend asked me to play the part of Brutus in an upcoming play about Julius Caesar",
    "What do you call a factory that makes okay products? A satisfactory.",
    "What do you call a sad strawberry? A blueberry.",
    "My physical therapist said I should do lunges to stay in shape. That would be a big step forward.",
    "I asked my dog what's two minus two. He said nothing.",
    "Did you know the first French fries weren't cooked in France? They were cooked in Greece.",
    "Where do you learn to make a banana split? Sundae school.",
    "Do you know why koala bears aren't really bears? They don't meet the koalafications.",
    "I used to be addicted to soap, but I'm clean now.",
    "What do you call it when a snowman throws a tantrum? A meltdown.",
    "Bought a new shrub trimmer today... It's cutting hedge technology.",
    "Did you hear about the circus fire? It was in tents.",
    "How can you tell it's a dogwood tree? By the bark.",
    "Don't trust atoms. They make up everything!",
    "What kind of car does a sheep like to drive? A lamborghini.",
    "What happens when a frog's car dies? It gets toad away.",
    "I could tell a joke about pizza, but it's a little too cheesy.",
    "I used to hate facial hair, but then it grew on me.",
    "I stayed up all night and tried to figure out where the sun was. Then it dawned on me.",
    "I used to be a baker, but I couldn't raise the dough.",
    "A termite walks into a bar and asks, 'Is the bar tender here?'",
    "What's the best way to watch a fly fishing tournament? Live stream.",
    "To whoever stole my copy of Microsoft Office, I will find you. You have my Word.",
    "What do you get when you cross a snowman with a vampire? Frostbite.",
    "How do you make a tissue dance? You put a little boogie in it.",
    "Why did the scarecrow win an award? He was outstanding in his field.",
    "I'm on a seafood diet. I see food and I eat it.",
    "Why don't scientists trust atoms? Because they make up everything.",
    "How does a penguin build his house? Igloos it together.",
    "What do you call a fake noodle? An impasta.",
    "Want to hear a joke about construction? I'm still working on it.",
    "Why don't skeletons fight each other? They don't have the guts.",
    "What do you call cheese that isn't yours? Nacho cheese!",
    "Why did the coffee file a police report? It got mugged.",
    "What's orange and sounds like a parrot? A carrot.",
    "Why do chicken coops only have two doors? Because if they had four, they'd be chicken sedans.",
    "What's the best thing about Switzerland? I don't know, but the flag is a big plus.",
    "Did you hear about the mathematician who's afraid of negative numbers? He'll stop at nothing to avoid them.",
    "How do you organize a space party? You planet.",
    "Why did the bicycle fall over? It was two tired.",
    "What do you call a can opener that doesn't work? A can't opener.",
    "I wouldn't buy anything with velcro. It's a total rip-off.",
    "Why did the golfer bring two pairs of pants? In case he got a hole in one.",
    "What time did the man go to the dentist? Tooth hurt-y.",
    "How do you make holy water? You boil the hell out of it.",
    "I used to play piano by ear, but now I use my hands.",
    "Why can't your nose be 12 inches long? Because then it would be a foot.",
    "What did the ocean say to the beach? Nothing, it just waved.",
    "Why do bees have sticky hair? Because they use a honeycomb.",
    "What do you call a bear with no teeth? A gummy bear.",
    "Why did the stadium get hot after the game? All of the fans left.",
    "What does a house wear? Address.",
    "What do you call a group of killer whales playing instruments? An orca-stra.",
    "Why don't oysters donate to charity? Because they're shellfish.",
    "What do you call a pile of cats? A meowtain.",
    "Why did the tomato turn red? Because it saw the salad dressing.",
    "What do lawyers wear to court? Lawsuits.",
    "Why did the cookie go to the hospital? Because he felt crummy.",
    "What did one wall say to the other wall? I'll meet you at the corner.",
    "Why did the invisible man turn down the job offer? He couldn't see himself doing it.",
    "What do you call a sleeping bull? A bulldozer.",
    "Why don't eggs tell jokes? They'd crack each other up.",
    "How does Moses make his coffee? Hebrews it.",
    "What do you call a dog that does magic tricks? A labracadabrador.",
    "Why did the math book look sad? Because it had too many problems.",
    "What did the grape do when he got stepped on? He let out a little wine.",
    "Why don't some couples go to the gym? Because some relationships don't work out.",
    "What do you call a dinosaur with an extensive vocabulary? A thesaurus.",
    "How do you get a squirrel to like you? Act like a nut.",
    "What did the buffalo say when his son left for college? Bison.",
    "Why did the picture go to jail? Because it was framed.",
    "What do you call a fish with no eyes? Fsh.",
    "Why couldn't the bicycle stand up by itself? It was two tired.",
    "What do you call a belt made of watches? A waist of time.",
    "How do celebrities stay cool? They have many fans.",
    "Why did the mushroom go to the party? Because he was a fungi.",
    "What do you call a snowman in July? A puddle.",
    "Why don't scientists trust stairs? Because they're always up to something.",
    "What did the left eye say to the right eye? Between you and me, something smells.",
    "Why did the golfer wear two pairs of socks? In case he got a hole in one.",
    "What's brown and sticky? A stick.",
    "Why did the computer go to the doctor? It had a virus.",
    "What do you call a lazy kangaroo? A pouch potato.",
    "How do you catch a unique rabbit? Unique up on it.",
    "What do you call a boomerang that won't come back? A stick.",
    "Why was the broom late? It swept in.",
    "What's the difference between a poorly dressed man on a tricycle and a well-dressed man on a bicycle? Attire.",
    "Why did the scarecrow become a successful neurosurgeon? He was outstanding in his field."
}

-- Register with Database Manager
Dadabase.DatabaseManager:RegisterModule("dadjokes", {
    name = "Dad Jokes",
    defaultContent = defaultJokes,
    dbVersion = 1,
    defaultSettings = {
        enabled = true,
        triggers = {
            wipe = true,
            death = false
        },
        groups = {
            raid = true,
            party = true
        }
    }
})

-- Register config tab
Dadabase.Config:RegisterModuleTab("dadjokes", {
    name = "Dad Jokes",
    buildContent = function(container, moduleId)
        Dadabase.Config:BuildModuleContent(container, moduleId)
    end
})
