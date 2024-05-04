import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomMenu extends StatelessWidget {
  final String text;
  final BuildContext context;
  final VoidCallback? onMenuButtonPressed;
  final VoidCallback? onSearchButtonPressed;
  final VoidCallback? onPortraitButtonPressed;
  final VoidCallback? onTextSizeButtonPressed;
  final VoidCallback? onCommentButtonPressed;

  const CustomMenu(
    BuildContext contextParam, {
    required this.text,
    required this.context,
    super.key,
    this.onMenuButtonPressed,
    this.onSearchButtonPressed,
    this.onPortraitButtonPressed,
    this.onTextSizeButtonPressed,
    this.onCommentButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0, 1),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 74),
        child: Container(
          width: 275,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xffDC2626),
            borderRadius: BorderRadius.all(
              Radius.circular(25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Close button
                Expanded(
                  child: Container(
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xffDC2626),
                      size: 24,
                    ),
                  ),
                ),
                // Button for changing orientation to landscape
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Change orientation to landscape when this button is pressed
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.landscapeRight,
                      ]);
                    },
                    child: const ButtonContainer(
                      icon: Icons.screen_lock_rotation,
                      color: Colors.white,
                    ),
                  ),
                ),




                // Additional buttons
                Expanded(
                  child: GestureDetector(
                    onTap: onSearchButtonPressed,
                    child: const ButtonContainer(
                      icon: Icons.search,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: onMenuButtonPressed,
                    child: const ButtonContainer(
                      icon: Icons.menu,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: onTextSizeButtonPressed,
                    child: const ButtonContainer(
                      icon: Icons.format_size_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: onCommentButtonPressed,
                    child: const ButtonContainer(
                      icon: Icons.add_comment_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonContainer extends StatelessWidget {
  final IconData icon;
  final Color color;

  const ButtonContainer({
    super.key,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }
}
