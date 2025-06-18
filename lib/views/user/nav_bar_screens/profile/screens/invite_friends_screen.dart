import 'package:beautician_app/utils/libs.dart';
class InviteFriendsScreen extends StatelessWidget {
  final List<Map<String, String>> friends = [
    {"name": "Dianne Russell", "username": "dianne", "image": "assets/specialist2.png"},
    {"name": "Kristin Watson", "username": "kristin", "image": "assets/specialist2.png"},
    {"name": "Kathryn Murphy", "username": "kathryn", "image": "assets/specialist2.png"},
    {"name": "Jacob Jones", "username": "jacob", "image": "assets/specialist2.png"},
    {"name": "Arlene McCoy", "username": "arlene", "image": "assets/specialist2.png"},
    {"name": "Dianne Russell", "username": "dianne", "image": "assets/specialist2.png"},
    {"name": "Guy Hawkins", "username": "guy", "image": "assets/specialist2.png"},
    {"name": "Jenny Wilson", "username": "jenny", "image": "assets/specialist2.png"},
    {"name": "Leslie Alexander", "username": "leslie", "image": "assets/specialist2.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: SvgPicture.asset('assets/back icon.svg', height: 24),
        ),
        title: Text(
          'Invite Friends',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            leading: CircleAvatar(
              backgroundImage: AssetImage(friend["image"]!),
              radius: 24,
            ),
            title: Text(
              friend["name"]!,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              "@${friend["username"]!}",
              style: TextStyle(color: kGreyColor, fontSize: 14),
            ),
            trailing: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "Invite",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          );
        },
      ),
    );
  }
}