import 'package:flutter/material.dart';
import 'package:vibey/screens/widgets/sign_board_widget.dart';
import 'package:vibey/screens/widgets/snackbar.dart';
import 'package:vibey/theme/default.dart';
import 'package:vibey/utils/importer.dart';

class ImporterDialogWidget extends StatefulWidget {
  final Stream<ImporterState> strm;
  const ImporterDialogWidget({super.key, required this.strm});

  @override
  State<ImporterDialogWidget> createState() => _ImporterDialogWidgetState();
}

class _ImporterDialogWidgetState extends State<ImporterDialogWidget> {
  String message = "Importing...";
  bool isCompleted = false;
  bool isFailed = false;

  @override
  void initState() {
    super.initState();
    widget.strm.listen((event) async {
      if (mounted) {
        setState(() {
          message = event.message;
          isFailed = event.isFailed;
          isCompleted = event.isDone;
        });

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.of(context).pop();
        if (isFailed) SnackbarService.showMessage("Import Failed!");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.black.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCompleted)
              const SignBoardWidget(
                message: "Import Completed",
                icon: Icons.check_circle,
              )
            else if (isFailed)
              const SignBoardWidget(message: "Import Failed", icon: Icons.error)
            else ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                message,
                style: Default_Theme.secondoryTextStyle.copyWith(
                  fontSize: 16,
                  color: Default_Theme.primaryColor1,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
