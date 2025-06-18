// import 'package:beautician_app/utils/libs.dart';

// class SearchResultScreen extends StatefulWidget {
//   const SearchResultScreen({super.key, required this.searchText});

//   final String searchText;

//   @override
//   State<SearchResultScreen> createState() => _SearchResultScreenState();
// }

// class _SearchResultScreenState extends State<SearchResultScreen>
//     with SingleTickerProviderStateMixin {
//   late TextEditingController controller;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     controller = TextEditingController(text: widget.searchText);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Primary color

//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back_ios_new),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//           title: TextField(
//             controller: controller,
//             decoration: InputDecoration(
//               prefixIcon: Image.asset('assets/search2.png'),
//               suffixIcon: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: Image.asset('assets/mic.png'),
//               ),
//               hintText: 'Search',
//               contentPadding:
//                   const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//               filled: true,
//               fillColor: const Color(0xffFFFFFF),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(40),
//                 borderSide: const BorderSide(
//                   color: Color(0xFFC0C0C0),
//                   width: 1,
//                 ),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(40),
//                 borderSide: const BorderSide(
//                   color: Color(0xFFC0C0C0), // Active border color
//                   width: 1.5,
//                 ),
//               ),
//             ),
//             style: const TextStyle(color: Colors.black),
//           ),
//         ),
//         backgroundColor: Colors.white,
//         body: Padding(
//           padding: EdgeInsets.symmetric(horizontal: padding),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Row(
//                   children: [
//                     Text(
//                       'Result found',
//                       style: kSubheadingStyle.copyWith(fontSize: 16),
//                     ),
//                     SizedBox(
//                       width: 5,
//                     ),
//                     Text(
//                       '(2)',
//                       style: kHeadingStyle.copyWith(fontSize: 16),
//                     ),
//                   ],
//                 ),
//                 // SizedBox(height: 20,),
//                 // SaloonCardTwo(),
//                 // SizedBox(height: 15,),
//                 // SaloonCardTwo(),
//                 // SizedBox(height: 15,),
//                 // Divider(color: kGreyColor2,),
//                 // SizedBox(height: 15,),
//                 // SaloonCardTwo(),
//                 // SizedBox(height: 15,),
//                 // SaloonCardTwo(),
//                 // SizedBox(height: 15,),
//                 // SaloonCardTwo(),
//                 // SizedBox(height: 15,),
//               ],
//             ),
//           ),
//         ));
//   }
// }
