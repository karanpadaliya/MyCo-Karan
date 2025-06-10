//
// import 'package:flutter/material.dart';
// import 'package:myco_component/custom_widgets/responsive.dart';
// import 'package:myco_component/custom_widgets/text_field.dart';
// import '../themes_colors/colors.dart';
// import 'new_myco_button.dart';
// import 'new_myco_button_theme.dart';
//
// class BottomsheetRadioButton extends StatefulWidget {
//   final List<Map<String, String>> items;
//   final double? height;
//   final double? width;
//   final String? selectedItem;
//   final ValueChanged<String>? onSelect;
//   final ImageProvider? image;
//   final double? titleImageHeight;
//   final double? titleImageWidth;
//   final String? title;
//   final bool showSnackBar;
//
//   const BottomsheetRadioButton({
//     super.key,
//     required this.items,
//     this.selectedItem,
//     this.onSelect,
//     this.image,
//     this.title,
//     this.showSnackBar = false,
//     this.titleImageHeight,
//     this.titleImageWidth,
//     this.height,
//     this.width,
//   });
//
//   @override
//   State<BottomsheetRadioButton> createState() => _BottomsheetRadioButtonState();
// }
//
// class _BottomsheetRadioButtonState extends State<BottomsheetRadioButton> {
//   String searchQuery = '';
//   String? selectedItem;
//
//   @override
//   void initState() {
//     super.initState();
//     selectedItem = widget.selectedItem;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final filteredItems = widget.items
//         .where(
//           (item) =>
//               item['title']!.toLowerCase().contains(
//                 searchQuery.toLowerCase(),
//               ) ||
//               item['subtitle']!.toLowerCase().contains(
//                 searchQuery.toLowerCase(),
//               ),
//         )
//         .toList();
//
//     return Container(
//       height: widget.height ?? MediaQuery.of(context).size.height * 0.8,
//       width: widget.width ?? MediaQuery.of(context).size.width,
//       padding: const EdgeInsets.all(16),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             if (widget.title != null)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 8),
//                 child: Text(
//                   widget.title!,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w400,
//                     fontSize:
//                         Theme.of(context).textTheme.bodyLarge?.fontSize ?? 14,
//                     fontFamily: 'Gilroy-SemiBold',
//                   ),
//                 ),
//               ),
//             if (widget.image != null)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Image(
//                     fit: BoxFit.cover,
//                     image: widget.image!,
//                     height: widget.titleImageHeight ?? 100,
//                     width: widget.titleImageWidth ?? 100,
//                   ),
//                 ),
//               ),
//             MyCoTextField(
//               isSuffixIconOn: true,
//               hintText: "Search",
//               hintTextStyle: TextStyle(color: AppColors.black),
//               color: AppColors.borderColor,
//               prefix: Icon(Icons.apartment, color: AppColors.primary),
//               onChanged: (value) {
//                 setState(() {
//                   searchQuery = value;
//                 });
//               },
//             ),
//             const SizedBox(height: 12),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: filteredItems.length,
//                 itemBuilder: (context, index) {
//                   final item = filteredItems[index];
//                   final isSelected = selectedItem == item['id'];
//                   return Container(
//                     margin: const EdgeInsets.symmetric(vertical: 6),
//                     decoration: BoxDecoration(
//                       color: isSelected ? AppColors.primary : Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: AppColors.primary.withAlpha((0.3 * 255).toInt()),
//                       ),
//                     ),
//                     child: RadioListTile<String>(
//                       value: item['id']!,
//                       groupValue: selectedItem,
//                       onChanged: (value) {
//                         setState(() {
//                           selectedItem = value;
//                         });
//                       },
//                       activeColor: Colors.white,
//                       title: Text(
//                         item['title']!,
//                         style: TextStyle(
//                           fontWeight: FontWeight.w400,
//                           fontSize:
//                               Theme.of(
//                                 context,
//                               ).textTheme.bodyMedium?.fontSize ??
//                               14,
//                           fontFamily: 'Gilroy-SemiBold',
//                         ),
//                       ),
//                       isThreeLine: true,
//                       subtitle: Text(
//                         item['subtitle']!,
//                         style: TextStyle(
//                           fontWeight: FontWeight.w400,
//                           fontSize:
//                               Theme.of(context).textTheme.bodySmall?.fontSize ??
//                               14,
//                           fontFamily: 'Gilroy-SemiBold',
//                         ),
//                       ),
//
//                       secondary: CircleAvatar(
//                         radius: 20,
//                         backgroundColor: isSelected
//                             ? Colors.white
//                             : AppColors.primary,
//                         child: Container(
//                           alignment: Alignment.center,
//                           height: 30,
//                           width: 30,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(50),
//                             color: AppColors.white,
//                           ),
//                           child: Text(
//                             item['title']![0],
//                             style: TextStyle(
//                               fontWeight: FontWeight.w400,
//                               fontSize:
//                                   Theme.of(
//                                     context,
//                                   ).textTheme.bodyMedium?.fontSize ??
//                                   14,
//                               fontFamily: 'Gilroy-SemiBold',
//                             ),
//                           ),
//                         ),
//                       ),
//                       controlAffinity: ListTileControlAffinity.trailing,
//                     ),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: MediaQuery.of(context).size.height * 0.020),
//             Row(
//               children: [
//                 Expanded(
//                   child: MyCoButton(
//                     title: 'Close',
//                     width: getWidth(context) * .450,
//                     colorBackground: AppColors.white,
//                     border: Border.all(color: AppColors.primary, width: 2),
//                     textStyle: MyCoButtonTheme.getWhiteBackgroundTextStyle(
//                       context,
//                     ),
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: MyCoButton(
//                     title: 'Submit',
//                     width: getWidth(context) * .450,
//                     onTap: () {
//                       if (selectedItem != null && widget.onSelect != null) {
//                         widget.onSelect!(selectedItem!);
//                       }
//                       Navigator.pop(context, selectedItem);
//
//                       if (widget.showSnackBar && selectedItem != null) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             backgroundColor: AppColors.primary,
//                             content: Text(
//                               "You selected ${selectedItem.toString()}",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w400,
//                                 fontSize:
//                                     Theme.of(
//                                       context,
//                                     ).textTheme.bodyMedium?.fontSize ??
//                                     14,
//                                 fontFamily: 'Gilroy-SemiBold',
//                               ),
//                             ),
//                           ),
//                         );
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:myco_karan/custom_widgets/responsive.dart';
import 'package:myco_karan/custom_widgets/text_field.dart';
import '../themes_colors/colors.dart';
import 'new_myco_button.dart';
import 'new_myco_button_theme.dart';

class BottomsheetRadioButton extends StatefulWidget {
  final List<Map<String, String>> items;
  final double? height;
  final double? width;
  final String? selectedItem;
  final ValueChanged<String>? onSelect;
  final ImageProvider? image;
  final double? titleImageHeight;
  final double? titleImageWidth;
  final String? title;
  final bool showSnackBar;

  const BottomsheetRadioButton({
    super.key,
    required this.items,
    this.selectedItem,
    this.onSelect,
    this.image,
    this.title,
    this.showSnackBar = false,
    this.titleImageHeight,
    this.titleImageWidth,
    this.height,
    this.width,
  });

  @override
  State<BottomsheetRadioButton> createState() => _BottomsheetRadioButtonState();
}

class _BottomsheetRadioButtonState extends State<BottomsheetRadioButton> {
  String searchQuery = '';
  String? selectedItem;

  @override
  void initState() {
    super.initState();
    selectedItem = widget.selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems =
        widget.items
            .where(
              (item) =>
                  item['title']!.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  item['subtitle']!.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ),
            )
            .toList();

    return Container(
      height: widget.height ?? MediaQuery.of(context).size.height * 0.8,
      width: widget.width ?? MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                widget.title!,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize:
                      Theme.of(context).textTheme.bodyLarge?.fontSize ?? 14,
                  fontFamily: 'Gilroy',
                ),
              ),
            ),
          if (widget.image != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image(
                  fit: BoxFit.cover,
                  image: widget.image!,
                  height: widget.titleImageHeight ?? 100,
                  width: widget.titleImageWidth ?? 100,
                ),
              ),
            ),
          MyCoTextField(
            isSuffixIconOn: true,
            hintText: "Search",
            hintTextStyle: TextStyle(color: AppColors.black),
            color: AppColors.borderColor,
            prefix: Icon(Icons.apartment, color: AppColors.primary),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final isSelected = selectedItem == item['id'];

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withAlpha((0.3 * 255).toInt()),
                    ),
                  ),
                  child: RadioListTile<String>(
                    value: item['id']!,
                    groupValue: selectedItem,
                    onChanged: (value) {
                      setState(() {
                        if (selectedItem == value) {
                          selectedItem = null;
                        } else {
                          selectedItem = value;
                          if (widget.showSnackBar) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.primary,
                                content: Text(
                                  "Selected ID: ${item['id']}, Title: ${item['title']}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.fontSize ??
                                        14,
                                    fontFamily: 'Gilroy-SemiBold',
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                      });
                    },
                    activeColor: Colors.white,
                    title: Text(
                      item['title']!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium?.fontSize ??
                            14,
                        fontFamily: 'Gilroy',
                        color: isSelected ? AppColors.white : null,
                      ),
                    ),
                    isThreeLine: true,
                    subtitle: Text(
                      item['subtitle']!,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize:
                            Theme.of(context).textTheme.bodySmall?.fontSize ??
                            14,
                        fontFamily: 'Gilroy',
                        color: isSelected ? AppColors.white : null,
                      ),
                    ),
                    secondary: CircleAvatar(
                      radius: 20,
                      backgroundColor:
                          isSelected ? Colors.white : AppColors.primary,
                      child: Container(
                        alignment: Alignment.center,
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: AppColors.white,
                        ),
                        child: Text(
                          item['title']![0].toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize:
                                Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.fontSize ??
                                14,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.020),
          Row(
            children: [
              Expanded(
                child: MyCoButton(
                  isShadow: false,
                  title: 'Close',
                  width: getWidth(context) * .450,
                  colorBackground: AppColors.white,
                  border: Border.all(color: AppColors.primary, width: 2),
                  textStyle: MyCoButtonTheme.getWhiteBackgroundTextStyle(
                    context,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MyCoButton(
                  title: 'Submit',
                  width: getWidth(context) * .450,
                  onTap: () {
                    if (selectedItem != null && widget.onSelect != null) {
                      widget.onSelect!(selectedItem!);
                    }
                    Navigator.pop(context, selectedItem);
                    if (widget.showSnackBar && selectedItem != null) {
                      final selected = widget.items.firstWhere(
                        (item) => item['id'] == selectedItem,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.primary,
                          content: Text(
                            "You selected ID: ${selected['id']}, Title: ${selected['title']}",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.fontSize ??
                                  14,
                              fontFamily: 'Gilroy-SemiBold',
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
