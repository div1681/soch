import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soch/models/user_model.dart';

class DataSeederService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Random _rnd = Random();

  // --- DATA BANKS ---
  
  final List<String> _maleNames = [
    'Aarav', 'Vivaan', 'Aditya', 'Vihaan', 'Arjun', 'Sai', 'Reyansh', 'Ayaan', 'Krishna', 'Ishaan',
    'Shaurya', 'Atharva', 'Kabir', 'Rohan', 'Rahul', 'Vikram', 'Siddharth', 'Manish', 'Nikhil', 'Aryan',
    'Ashneer', 'Kunal', 'Ritesh', 'Bhavish', 'Deepinder' 
  ];

  final List<String> _femaleNames = [
    'Aadya', 'Diya', 'Saanvi', 'Ananya', 'Kiara', 'Pari', 'Riya', 'Anika', 'Myra', 'Prisha',
    'Saira', 'Neha', 'Priya', 'Sneha', 'Kavya', 'Meera', 'Radhika', 'Tanvi', 'Ishita', 'Pooja',
    'Ghazal', 'Vineeta', 'Radhika' 
  ];

  final List<String> _surnames = [
    'Sharma', 'Verma', 'Gupta', 'Malhotra', 'Singh', 'Kumar', 'Patel', 'Reddy', 'Nair', 'Iyer',
    'Grover', 'Agarwal', 'Bahl', 'Bansal', 'Goyal', 'Kamath', 'Jain', 'Shah', 'Mehta', 'Chopra'
  ];

  final List<String> _bios = [
    "Building something cool. 🚀",
    "Coffee, Code, and Chaos.",
    "Trying to be an adult.",
    "Tech enthusiast & amateur philosopher.",
    "Making memories.",
    "Investor | Entrepreneur | Shark 🦈",
    "Gen Z but with millennial back pain.",
    "Just here for the vibes.",
    "Software Engineer @ MNC.",
    "MBA Student | Caffeine Addict.",
    "Seeking financial freedom.",
    "Stoic in training.",
    "I tweet about startups mostly.",
    "Digital Nomad.",
    "Artist 🎨 | Dreamer ☁️"
  ];

  final _ashneerPersona = {
    'name': 'Ashneer Grover',
    'bio': 'Founder & Shark. I speak the truth, deal with it. Yeh sab doglapan hai.',
    'pic': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ef/Virat_Kohli_Royal_Challengers_Bangalore_2024.jpg/330px-Virat_Kohli_Royal_Challengers_Bangalore_2024.jpg', 
    'tone': 'blunt'
  };

  final List<Map<String, String>> _blogTemplates = [
    {'title': 'Why 90% of Indian Startups are Doomed', 'category': 'Startup'},
    {'title': 'Bootstrapping > VC Money: Change My Mind', 'category': 'Business'},
    {'title': 'AI won\'t replace you, a person using AI will', 'category': 'Tech'},
    {'title': 'Flutter vs React Native: The toxicity needs to stop', 'category': 'Dev'},
    {'title': 'Surviving the Tech Layoffs: A Guide', 'category': 'Career'},
    {'title': 'The hypocrisy of \'Hustle Culture\'', 'category': 'Productivity'},
    {'title': 'Web3 is dead. Long live AI.', 'category': 'Tech'},
    {'title': 'Why I rejected a 50LPA offer', 'category': 'Career'},
    {'title': 'Situationships: Why are we afraid to commit?', 'category': 'Life'},
    {'title': 'My toxic trait is buying books I\'ll never read', 'category': 'Life'},
    {'title': 'Bangalore Traffic: A love-hate story', 'category': 'Rant'},
    {'title': 'Is \'Adulting\' just paying bills and having back pain?', 'category': 'Funny'},
    {'title': 'Digital Detox: I quit Instagram for 30 days', 'category': 'Health'},
    {'title': 'The subtle art of not reacting instantly', 'category': 'Wisdom'},
    {'title': 'Money buys comfort, not happiness', 'category': 'Philosophy'},
    {'title': 'Silence is often the best answer', 'category': 'Wisdom'},
    {'title': 'Stop waiting for the \'perfect\' moment', 'category': 'Motivation'},
    {'title': 'Rent vs Buy: The mathematical truth', 'category': 'Finance'},
    {'title': 'Credit Cards: Trap or Tool?', 'category': 'Finance'},
    {'title': 'Crypto is dead. Long live Crypto.', 'category': 'Finance'},
    {'title': 'SIP vs Lumpsum: What works?', 'category': 'Finance'},
    {'title': 'The Indian Education System needs a reboot', 'category': 'Opinion'},
    {'title': 'Why are weddings so expensive?', 'category': 'Society'},
    {'title': 'Public transport etiquette 101', 'category': 'Rant'},
    {'title': 'The problem with \'Positive Vibes Only\'', 'category': 'Life'},
  ];

  final List<String> _richParagraphs = [
    "The market dynamics are shifting rapidly. We are seeing a fundamental change in how consumers interact with digital products. It's no longer just about utility; it's about the experience, the story, and the connection.",
    "I've been reflecting on this for a while. Often, we get so caught up in the rat race that we forget why we started in the first place. The goal wasn't just to make money, it was to build something meaningful.",
    "Let's look at the data. In the last quarter alone, the trends have defied all expert predictions. This serves as a reminder that the market is irrational, and trying to time it is a fool's errand.",
    "Innovation is not about adding more features. It's about removing the friction. It's about taking something complex and making it invisible to the user. That is true engineering.",
    "Bangalore, for all its traffic woes, has an energy that is unmatched. You walk into a cafe in Koramangala and you can hear the next billion-dollar idea being discussed at the next table.",
    "Financial freedom is not about buying a Ferrari. It's about having the time to do what you want, when you want, with whom you want. That is the only wealth that matters.",
    "We need to normalize taking breaks. The 'Hustle Culture' glorifies burnout as a badge of honor. It's not. It's a failure of planning and self-care.",
    "Artificial Intelligence will not replace creativity. It will amplify it. The artists and writers who embrace these tools will define the next era of content creation.",
    "Relationships are the compound interest of life. Invest in them early, and the returns over decades will be immeasurable.",
    "Failure is data. Every time you fail, you learn one way that doesn't work. The only true failure is quitting before you find the way that does."
  ];

  final List<String> _comments = [
    "Totally agree with this! 🔥",
    "This is a fresh perspective. Thanks for sharing.",
    "I'm not sure I agree with the second point, but interesting read.",
    "Valid.",
    "This changed my mind.",
    "Can you elaborate on this?",
    "So true!",
    "UNDE RATED opinion.",
    "This needs to be said more often.",
    "💯",
    "Great post!",
    "Sent this to my co-founder immediately."
  ];

  // --- METHODS ---

  Future<void> floodDatabase() async {
    print("🌊 STARTING DATA FLOOD (RESET & RESEED)...");
    
    // 0. RESET (Wipe existing data)
    await _wipeCollection('users');
    await _wipeCollection('blogs');
    print("✅ Database Wiped (Clean Slate)");

    // 1. Create Users
    List<UserModel> users = [];
    WriteBatch batch = _db.batch();
    int batchCount = 0;

    Future<void> commitIfNeeded() async {
      batchCount++;
      if (batchCount >= 400) {
        await batch.commit();
        batch = _db.batch();
        batchCount = 0;
        print("   ...committed batch...");
      }
    }

    final ashneer = await _createSpecificUser(_ashneerPersona['name']!, _ashneerPersona['bio']!, batch);
    users.add(ashneer);
    await commitIfNeeded();

    for (int i = 0; i < 49; i++) {
      users.add(await _createRandomUser(i, batch));
      await commitIfNeeded();
    }
    
    await batch.commit(); 
    batch = _db.batch();
    batchCount = 0;
    print("✅ Created ${users.length} Users");

    // 2. Generate Social Graph (Followers)
    print("🕸️ Generating Social Graph...");
    for (var u1 in users) {
      if (_rnd.nextBool()) { // 50% chance to follow people
         int followCount = 1 + _rnd.nextInt(5);
         for(int k=0; k<followCount; k++) {
             var u2 = users[_rnd.nextInt(users.length)];
             if (u1.uid != u2.uid) {
               // Update u1 following u2
               batch.update(_db.collection('users').doc(u1.uid), {
                 'following': FieldValue.arrayUnion([u2.uid])
               });
               // Update u2 followers u1
               batch.update(_db.collection('users').doc(u2.uid), {
                 'followers': FieldValue.arrayUnion([u1.uid])
               });
               await commitIfNeeded();
             }
         }
      }
    }
    await batch.commit();
    batch = _db.batch();
    batchCount = 0;
    print("✅ Social Graph Generated");

    // 3. Create Blogs & Comments
    print("📝 Creating Blogs & Comments...");
    for (var user in users) {
      int blogCount = 5 + _rnd.nextInt(10); 
      if (user.username.contains("Ashneer")) blogCount = 20;

      for (int i = 0; i < blogCount; i++) {
        await _createBlogForUser(user, batch, users); // Pass all users for comments
        // Note: _createBlogForUser handles its own sub-batching for comments if needed, 
        // but here we are passing the MAIN batch. 
        // To be safe and avoid complexity with subcollections in the same batch limit, 
        // let's commit frequently.
        await commitIfNeeded();
      }
    }

    await batch.commit();
    print("✅ DATA FLOOD COMPLETE!");
  }

  Future<void> _wipeCollection(String colName) async {
    // Client-side wipe (inefficient but works for 1k items)
    final snap = await _db.collection(colName).get();
    WriteBatch b = _db.batch();
    int count = 0;
    for(var doc in snap.docs) {
      b.delete(doc.reference);
      count++;
      if (count >= 400) {
        await b.commit();
        b = _db.batch();
        count = 0;
      }
    }
    await b.commit();
    print("   ...wiped $colName");
  }

  Future<UserModel> _createSpecificUser(String name, String bio, WriteBatch batch) async {
    final id = 'user_ashneer_${_rnd.nextInt(99999)}'; 
    final user = UserModel(
      uid: id,
      email: 'ashneer@bharatpe.mock',
      username: name,
      bio: bio,
      profilePicUrl: 'https://ui-avatars.com/api/?name=${name.replaceAll(" ", "+")}&background=0D8ABC&color=fff&size=200', 
      followers: [],
      following: [],
    );
    batch.set(_db.collection('users').doc(id), user.toMap());
    return user;
  }

  Future<UserModel> _createRandomUser(int index, WriteBatch batch) async {
    bool isMale = _rnd.nextBool();
    String first = isMale 
        ? _maleNames[_rnd.nextInt(_maleNames.length)] 
        : _femaleNames[_rnd.nextInt(_femaleNames.length)];
    String last = _surnames[_rnd.nextInt(_surnames.length)];
    String name = "$first $last";
    
    final id = 'user_mock_$index${_rnd.nextInt(99999)}';
    final user = UserModel(
      uid: id,
      email: '${first.toLowerCase()}.${last.toLowerCase()}$index@mock.com',
      username: name,
      bio: _bios[_rnd.nextInt(_bios.length)],
      profilePicUrl: 'https://ui-avatars.com/api/?name=${first}+${last}&background=random&size=200',
      followers: [],
      following: [],
    );
    batch.set(_db.collection('users').doc(id), user.toMap());
    return user;
  }

  Future<void> _createBlogForUser(UserModel author, WriteBatch batch, List<UserModel> allUsers) async {
    final template = _blogTemplates[_rnd.nextInt(_blogTemplates.length)];
    final isViral = _rnd.nextInt(10) > 8; 
    
    final daysAgo = _rnd.nextInt(90);
    final timestamp = Timestamp.fromDate(DateTime.now().subtract(Duration(days: daysAgo, hours: _rnd.nextInt(24))));

    final blogId = _db.collection('blogs').doc().id;
    
    // Rich Content Generation
    String content = "";
    int paragraphs = 2 + _rnd.nextInt(4);
    for(int i=0; i<paragraphs; i++) {
        content += _richParagraphs[_rnd.nextInt(_richParagraphs.length)] + "\n\n";
    }
    if (author.username.contains("Ashneer")) {
      content += "Yeh sab doglapan hai. Do actual work.\n";
    }

    // Likes
    List<String> likes = [];
    int likeCount = isViral ? 50 + _rnd.nextInt(200) : _rnd.nextInt(20);
    for(int k=0; k<likeCount; k++) {
      likes.add('dummy_liker_$k');
    }
    
    // Create Blog
    final blogData = {
      'blogId': blogId,
      'authorId': author.uid,
      'authorName': author.username,
      'authorPicUrl': author.profilePicUrl,
      'title': template['title'],
      'content': content.trim(),
      'likes': likes,
      'timestamp': timestamp,
      'commentCount': 0, // Will update below
      'category': template['category']
    };
    batch.set(_db.collection('blogs').doc(blogId), blogData);

    // Comments (Real subcollection items)
    int commentCount = isViral ? 5 + _rnd.nextInt(15) : _rnd.nextInt(4);
    for(int c=0; c<commentCount; c++) {
        final commenter = allUsers[_rnd.nextInt(allUsers.length)];
        final commentBody = _comments[_rnd.nextInt(_comments.length)];
        final cid = _db.collection('blogs').doc(blogId).collection('comments').doc().id;
        
        final commentData = {
            'commentId': cid, // Ensure ID is consistent
            'authorId': commenter.uid,
            'authorName': commenter.username,
            'authorPicUrl': commenter.profilePicUrl,
            'content': commentBody,
            'timestamp': Timestamp.now(), // Simplified
        };

        // NOTE: We cannot easily batch Add to Subcollection with the SAME batch object 
        // if we are nearing the 500 limit. 
        // For simplicity in this script, we will just use the batch.set
        batch.set(_db.collection('blogs').doc(blogId).collection('comments').doc(cid), commentData);
    }
    
    // Update count
    if (commentCount > 0) {
        batch.update(_db.collection('blogs').doc(blogId), {'commentCount': commentCount});
    }
    
    print("   [BLOG] -> '${template['title']}' ($commentCount comments)");
  }
}
