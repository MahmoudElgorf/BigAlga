/// Home page with algae classification and encyclopedia access
import 'package:bioalga/features/home/controllers/home_controller.dart';
import 'package:bioalga/shared/widgets/gradient_background.dart';
import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/home_body.dart';
import '../widgets/home_footer.dart';
import '../widgets/home_overlay.dart';
import '../widgets/animated_background.dart';
import '../widgets/history_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.attachContext(context);

      _controller.initializeModel().then((_) {
        _controller.checkModelStatus();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HistoryDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              const Positioned.fill(child: AnimatedBackground()),
              Positioned.fill(
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          const HomeHeader(),
                          const SizedBox(height: 20),
                          HomeBody(controller: _controller),
                          const HomeFooter(),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (_controller.isLoading) const HomeLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }
}