// import 'package:flutter/material.dart';
// import 'package:olrggmobile/screens/newslist_form.dart';
// import 'package:olrggmobile/screens/news_entry_list.dart';
// import 'package:olrggmobile/screens/login.dart';
// import 'package:pbp_django_auth/pbp_django_auth.dart';
// import 'package:provider/provider.dart';

// class ItemHomepage {
//   final String name;
//   final IconData icon;
//   final Color color;

//   ItemHomepage(this.name, this.icon, this.color);
// }

// class ItemCard extends StatelessWidget {
//   final ItemHomepage item;
//   const ItemCard(this.item, {super.key});
//   @override
//   Widget build(BuildContext context) {
//     final request = context.watch<CookieRequest>();
//     return Material(
//       color: item.color,
//       borderRadius: BorderRadius.circular(12),
//       child: InkWell(
//         onTap: () async {
//           ScaffoldMessenger.of(context)
//             ..hideCurrentSnackBar()
//             ..showSnackBar(SnackBar(
//                 content: Text("Kamu telah menekan tombol ${item.name}!")));
//           if (item.name == "Create News") {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const NewsFormPage()),
//             );
//           }
//           else if (item.name == "All News") {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => const NewsEntryListPage()
//               ),
//             );
//           }
//           else if (item.name == "My News") {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const NewsEntryListPage(showOnlyMine: true),
//               ),
//             );
//           }
//           else if (item.name == "Featured News") {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const NewsEntryListPage(showFeatured: true),
//               ),
//             );
//           } 
//           else if (item.name == "Forum Diskusi") {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const ForumEntryListPage(), // Jangan lupa import filenya
//                 ),
//               );
//           }
//         },
//         child: Container(
//           padding: const EdgeInsets.all(8),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   item.icon,
//                   color: Colors.white,
//                   size: 30.0,
//                 ),
//                 const Padding(padding: EdgeInsets.all(3)),
//                 Text(
//                   item.name,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }