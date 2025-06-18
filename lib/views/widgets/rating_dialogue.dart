import '../../utils/libs.dart';

void showRatingDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      int selectedRating = 0;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Rate the User"),
            backgroundColor: Colors.white,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return IconButton(
                  icon: Icon(
                    index < selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedRating = index + 1;
                    });

                    print("Rated: $selectedRating stars");
                    Navigator.of(context).pop(); // Close rating dialog

                    showCommentDialog(context);
                  },
                );
              }),
            ),
          );
        },
      );
    },
  );
}

// Function to show the comment dialog
void showCommentDialog(BuildContext context) {
  TextEditingController commentController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Tell us about your experience"),
        content: CustomTextField(isObscure: false,
          maxLines: 3,
          hintText: "Write your comment here...",
          controller: commentController,
        ),
        actions: [
          CustomButton(
            title: "Submit",
            onPressed: ()=> Get.back(),
            isEnabled: true,
          ),
        ],
      );
    },
  );
}