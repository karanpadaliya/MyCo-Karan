import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myco_karan/custom_widgets/text_field.dart';
import 'package:path/path.dart' as path;
import '../themes_colors/app_theme.dart';
import '../themes_colors/colors.dart';
import 'dashed_border_container_theme.dart';
import 'image_picker.dart';
import 'new_myco_button.dart';

class OutOfRangeBottomSheet extends StatefulWidget {
  final double? height;
  final double? width;
  final List<Map<String, String>>? customTravelModes;
  final double? imageHeight;
  final double? imageMargin;

  const OutOfRangeBottomSheet({
    super.key,
    this.customTravelModes,
    this.imageHeight,
    this.imageMargin,
    this.height,
    this.width,
  });

  @override
  State<OutOfRangeBottomSheet> createState() => _OutOfRangeBottomSheetState();
}

class _OutOfRangeBottomSheetState extends State<OutOfRangeBottomSheet> {
  int selectedTravelModeIndex = -1;
  final List<Map<String, String>> defaultAssetTravelModes = [
    {'name': 'Bicycle', 'icon': 'assets/travelmodeicon/Bicycle.png'},
    {'name': 'Bike', 'icon': 'assets/travelmodeicon/Bike.png'},
    {'name': 'Bus', 'icon': 'assets/travelmodeicon/Bus.png'},
    {'name': 'Car', 'icon': 'assets/travelmodeicon/Car.png'},
    {'name': 'Train', 'icon': 'assets/travelmodeicon/Train.png'},
    {'name': 'AirplaneTilt', 'icon': 'assets/travelmodeicon/AirplaneTilt.png'},
    {'name': 'Sailboat', 'icon': 'assets/travelmodeicon/Sailboat.png'},
  ];
  final List<Map<String, String>> selectedAssetTravelModes = [
    {'name': 'Bicycle', 'icon': 'assets/travelmodeicon/Bicycle_Select.png'},
    {'name': 'Bike', 'icon': 'assets/travelmodeicon/Bike_Select.png'},
    {'name': 'Bus', 'icon': 'assets/travelmodeicon/Bus_Select.png'},
    {'name': 'Car', 'icon': 'assets/travelmodeicon/Car_Select.png'},
    {'name': 'Train', 'icon': 'assets/travelmodeicon/Train_Select.png'},
    {
      'name': 'AirplaneTilt',
      'icon': 'assets/travelmodeicon/AirplaneTilt_Select.png',
    },
    {'name': 'Sailboat', 'icon': 'assets/travelmodeicon/Sailboat_Select.png'},
  ];

  File? _pickedImage;
  File? pickedFile;

  @override
  Widget build(BuildContext context) {
    final travelModes = widget.customTravelModes ?? defaultAssetTravelModes;

    return Container(
      height: widget.height ?? MediaQuery.of(context).size.height * 0.8,
      width: widget.width ?? MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        color: Colors.white,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'You are Out of Range (Ahmedabad)',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.titleMedium?.fontSize ?? 18,
                        fontFamily: 'Gilroy-Bold',
                        color: AppColors.titleColor,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              Text(
                '480.45 Meter Away (Air Distance)',
                style: TextStyle(
                  fontFamily: 'Gilroy-Medium',
                  fontSize: Theme.of(context).textTheme.titleSmall!.fontSize ?? 10,
                  color: AppColors.subTitleColor,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '2025-05-15 10:55:11 AM',
                      style: TextStyle(
                        fontFamily: 'Gilroy-Medium',
                        fontSize: Theme.of(context).textTheme.titleSmall!.fontSize ?? 10,
                        color: AppColors.subTitleColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'GPS Accuracy: ',
                            style: TextStyle(
                              fontFamily: 'Gilroy-Medium',
                              fontSize: Theme.of(context).textTheme.titleSmall!.fontSize ?? 10,
                              color: AppColors.subTitleColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFDB913)),
                          ),
                          child: const Text(
                            'Medium',
                            style: TextStyle(
                              color: Color(0xFFFDB913),
                              fontFamily: 'Gilroy-Medium',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Travel Mode",
                style: TextStyle(
                  fontFamily: 'Gilroy-Bold',
                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize ?? 14,
                  color: AppColors.titleColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor, width: 1),
                ),
                child: Center(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: travelModes.length,
                    itemBuilder: (context, index) {
                      bool isSelected = selectedTravelModeIndex == index;
                      final iconPath = isSelected
                          ? selectedAssetTravelModes[index]['icon']!
                          : defaultAssetTravelModes[index]['icon']!;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTravelModeIndex = index;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected ? AppColors.primary : null,
                            ),
                            child: Image.asset(iconPath, width: 34, height: 34),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Odometer Reading",
                style: TextStyle(
                  fontFamily: 'Gilroy-Bold',
                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize ?? 14,
                  color: AppColors.titleColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderColor, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Last odometer reading : 12.5 KM",
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14,
                        fontFamily: 'Gilroy-Medium',
                        fontWeight: FontWeight.w400,
                        color: AppColors.titleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("1. Attach Odometer Photo"),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => openImagePicker(context),
                      child: DashedBorderContainer(
                        borderRadius: 8,
                        borderColor: AppColors.primary,
                        padding: const EdgeInsets.all(0),
                        child: _pickedImage != null
                            ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _pickedImage!,
                                width: double.infinity,
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 6,
                              top: 6,
                              child: GestureDetector(
                                onTap: () => setState(() => _pickedImage = null),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.removeBackground,
                                    border: Border.all(color: AppColors.remove),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "Remove",
                                    style: TextStyle(
                                      fontSize: AppTheme.lightTheme.textTheme.bodyLarge!.fontSize ?? 14,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                            : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.imagePickerBg,
                          ),
                          padding: const EdgeInsets.all(10),
                          width: double.infinity,
                          height: widget.imageHeight ?? 160,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/gallery-export.png', width: 30, height: 30),
                              const SizedBox(height: 5),
                              Text(
                                'Capture Image',
                                style: TextStyle(
                                  fontSize: AppTheme.lightTheme.textTheme.bodyLarge!.fontSize ?? 16,
                                  fontFamily: "Gilroy-SemiBold",
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.titleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("2. Odometer Reading"),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Km'),
                              MyCoTextField(
                                typingtextStyle: TextStyle(
                                  fontFamily: 'Gilroy-SemiBold',
                                  fontWeight: FontWeight.w400,
                                  fontSize: Theme.of(context).textTheme.titleMedium?.fontSize ?? 13,
                                  color: AppColors.textFieldColor,
                                ),
                                color: AppColors.borderColor,
                                isSuffixIconOn: false,
                                textInputType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Meter'),
                              MyCoTextField(
                                typingtextStyle: TextStyle(
                                  fontFamily: 'Gilroy-SemiBold',
                                  fontWeight: FontWeight.w400,
                                  fontSize: Theme.of(context).textTheme.titleMedium?.fontSize ?? 13,
                                  color: AppColors.textFieldColor,
                                ),
                                color: AppColors.borderColor,
                                isSuffixIconOn: false,
                                textInputType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: MyCoButton(
                      onTap: () => Navigator.pop(context),
                      title: "Prev",
                      textStyle: const TextStyle(
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                      boarderRadius: 50,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MyCoButton(
                      onTap: () => Navigator.pop(context),
                      title: "Punch In",
                      boarderRadius: 50,
                      textStyle: const TextStyle(
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openImagePicker(BuildContext context) async {
    final File? selectedFile = await showImageFilePicker(
      context: context,
      selectDocument: true,
    );

    if (selectedFile != null) {
      final String extension = path.extension(selectedFile.path).toLowerCase();

      if (extension == '.png' || extension == '.jpg' || extension == '.heic' || extension == '.jpeg') {
        setState(() {
          _pickedImage = selectedFile;
          pickedFile = null;
        });
      } else if (extension == '.pdf' || extension == '.doc' || extension == '.docx') {
        setState(() {
          pickedFile = selectedFile;
          _pickedImage = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unsupported file type')),
        );
      }
    } else {
      log('User cancelled or error occurred.');
    }
  }
}
