import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: Text("Profile"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.settings_rounded)),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_MblgVXEbYWCyEckNrMa81SVPib-3RpUq5A&s",
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Rachael wagner",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold
                ),
              ),
              Text("Junior Product Designer")
            ],
          ),
          SizedBox(height: 25),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Text(
                  "complete your profile",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Text("(1/5)", style: TextStyle(color: Color(0xFF114195))),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: List.generate(5, (index) {
              return Expanded(
                child: Container(
                  height: 7,
                  width: 10,
                  margin: EdgeInsets.only(right: index == 4 ? 0 : 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: index == 0 ? Color(0xFF114195) : Colors.black12,
                  ),
                ),
              );
            }),
          ),

          SizedBox(
            height: 180,
            child: ListView.separated(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final card = profileCompletionCards[index];
                return SizedBox(
                  width: 160,

                  child: Card(
                    shadowColor: Colors.black12,
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Icon(card.icon, size: 30,color: Color(0xFF114195)),
                          SizedBox(height: 10),
                          Text(card.title, textAlign: TextAlign.center),

                          Spacer(),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Color(0xFF114195),
                            ),
                            child: Text(card.buttonText,style: TextStyle(color: Colors.white),),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder:
                  (context, index) =>
                  Padding(padding: EdgeInsets.only(right: 5)),
              itemCount: profileCompletionCards.length,
            ),
          ),
          SizedBox(height: 35),
          ...List.generate(customListTiles.length, (index) {
            final tile = customListTiles[index];
            return Card(
              elevation: 4,
              shadowColor: Colors.black12,
              child: ListTile(
                leading: Icon(tile.icon,color: Color(0xFF114195)),
                title: Text(tile.title),
                trailing: Icon(Icons.chevron_right),
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),

          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "messages"),

          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Discover"),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: "profile"),
        ],
      ),
    );
  }
}

class ProfileCompletionCard {
  final String title;
  final String buttonText;
  final IconData icon; // Changed from imageUrl to IconData

  ProfileCompletionCard({
    required this.title,
    required this.buttonText,
    required this.icon,

  });
}

List<ProfileCompletionCard> profileCompletionCards = [
  ProfileCompletionCard(
    title: "Set Your Profile Details",
    icon: CupertinoIcons.person_circle, // Correct usage
    buttonText: "Continue",
  ),
  ProfileCompletionCard(
    title: "Upload Your Resume",
    icon: CupertinoIcons.doc,
    buttonText: "Upload",
  ),
  ProfileCompletionCard(
    title: "Set Your Profile Details",
    icon: CupertinoIcons.square_list, // Fix typo (Cupertion -> Cupertino)
    buttonText: "Add",
  ),
];

class CustomListTile {
  final IconData icon;
  final String title;

  CustomListTile({required this.icon, required this.title});
}

List<CustomListTile> customListTiles = [
  CustomListTile(icon: Icons.insights, title: "Activity"),
  CustomListTile(icon: Icons.location_on_outlined, title: "location"),
  CustomListTile(title: "Notifications", icon: CupertinoIcons.bell),
  CustomListTile(title: "logout", icon: CupertinoIcons.arrow_right_arrow_left),
];
