import 'package:daytistics/application/models/conversation.dart';
import 'package:daytistics/application/providers/services/conversations/conversations_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/utils/internet.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StyledScaffoldDrawer extends ConsumerStatefulWidget {
  const StyledScaffoldDrawer({super.key});

  @override
  ConsumerState<StyledScaffoldDrawer> createState() =>
      _StyledScaffoldDrawerState();
}

class _StyledScaffoldDrawerState extends ConsumerState<StyledScaffoldDrawer> {
  final int _pageSize = 10;
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  final List<Conversation> _conversations = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_loadMore);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchData();
    });
  }

  Future<void> _fetchData() async {
    if (await maybeRedirectToConnectionErrorView(context)) return;
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final conversations =
          await ref.read(conversationsServiceProvider).fetchConversations(
                offset: _currentPage * _pageSize,
                amount: _pageSize,
              );

      setState(() {
        _currentPage++;
        _isLoading = false;
        _conversations.addAll(conversations);
        _hasMore = conversations.length >= _pageSize;
      });
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  void _loadMore() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoading &&
        _hasMore) {
      _fetchData();
    }
  }

  Widget _buildConversationItem(Conversation conversation) {
    return ListTile(
      title: StyledText(conversation.title),
      onTap: () {
        // Handle tap for item $i
        Navigator.pop(context);
      },
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          // Handle menu item selection
          if (value == 'Option 1') {
            // Do something for Option 1
          } else if (value == 'Option 2') {
            // Do something for Option 2
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'Open',
            child: StyledText('Open'),
          ),
          const PopupMenuItem(
            value: 'Delete',
            child: StyledText(
              'Delete',
              style: TextStyle(
                color: ColorSettings.error,
              ),
            ),
          ),
        ],
        icon: const Icon(Icons.more_vert),
      ),
    );
  }

  Widget _buildConversationList() {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _conversations.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _conversations.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final conversation = _conversations[index];
          return _buildConversationItem(conversation);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: Stack(
                children: [
                  ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      DrawerHeader(
                        decoration: const BoxDecoration(
                          color: ColorSettings.primary,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SvgPicture.asset(
                              'assets/svg/daytistics_mono.svg',
                              height: 55,
                            ),
                            const SizedBox(height: 8),
                            const StyledText(
                              'Conversations',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      // for (int i = 0; i < 20; i++)
                      //   Stack(
                      //     children: [
                      //       ListTile(
                      //         title: StyledText('Item $i'),
                      //         onTap: () {
                      //           // Handle tap for item $i
                      //           Navigator.pop(context);
                      //         },
                      //       ),
                      //       Positioned(
                      //         top: 8,
                      //         right: 8,
                      //         child: PopupMenuButton<String>(
                      //           onSelected: (value) {
                      //             // Handle menu item selection
                      //             if (value == 'Option 1') {
                      //               // Do something for Option 1
                      //             } else if (value == 'Option 2') {
                      //               // Do something for Option 2
                      //             }
                      //           },
                      //           itemBuilder: (BuildContext context) => [
                      //             const PopupMenuItem(
                      //               value: 'Open',
                      //               child: StyledText('Open'),
                      //             ),
                      //             const PopupMenuItem(
                      //               value: 'Delete',
                      //               child: StyledText(
                      //                 'Delete',
                      //                 style: TextStyle(
                      //                   color: ColorSettings.error,
                      //                 ),
                      //               ),
                      //             ),
                      //           ],
                      //           icon: const Icon(Icons.more_vert),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      if (_conversations.isEmpty && !_isLoading)
                        const Center(child: Text('No conversations found'))
                      else
                        _buildConversationList(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ListTile(
                title: const StyledText('Settings'),
                leading: const Icon(Icons.settings),
                onTap: () {
                  // Navigate to the settings page
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   static const appTitle = 'Drawer Demo';

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       title: appTitle,
//       home: MyHomePage(title: appTitle),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _selectedIndex = 0;
//   static const TextStyle optionStyle = TextStyle(
//     fontSize: 30,
//     fontWeight: FontWeight.bold,
//   );
//   static const List<Widget> _widgetOptions = <Widget>[
//     Text('Index 0: Home', style: optionStyle),
//     Text('Index 1: Business', style: optionStyle),
//     Text('Index 2: School', style: optionStyle),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//         leading: Builder(
//           builder: (context) {
//             return IconButton(
//               icon: const Icon(Icons.menu),
//               onPressed: () {
//                 Scaffold.of(context).openDrawer();
//               },
//             );
//           },
//         ),
//       ),
//       body: Center(child: _widgetOptions[_selectedIndex]),
//       drawer: ,
//     );
//   }
// }
