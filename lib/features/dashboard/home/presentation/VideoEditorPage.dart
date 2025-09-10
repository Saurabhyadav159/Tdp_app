// import 'dart:async';
// import 'dart:io';
// import 'package:ffmpeg_kit_min_gpl/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_min_gpl/ffmpeg_kit_config.dart';
// import 'package:ffmpeg_kit_min_gpl/return_code.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:path/path.dart' as path;
// import 'package:photo_manager/photo_manager.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:dio/dio.dart';
// import 'package:image/image.dart' as img;
// import 'dart:typed_data';
//
// import '../../../../core/models/FooterImage.dart';
// import '../../../../core/models/ProtocolImage.dart';
// import '../../../../core/models/SelfImage.dart';
// import '../../../../core/network/api_service.dart';
//
// class VideoEditorPage extends StatefulWidget {
//   final String videoUrl;
//   final String? pageTitle;
//
//   const VideoEditorPage({
//     required this.videoUrl,
//     this.pageTitle = "Video Editor",
//     super.key,
//   });
//
//   @override
//   State<VideoEditorPage> createState() => _VideoEditorPageState();
// }
//
// class _VideoEditorPageState extends State<VideoEditorPage> {
//   late VideoPlayerController _controller;
//   late VideoPlayerController _generatedVideoController;
//   bool _isPlaying = false;
//   bool _isProcessing = false;
//   double _progressValue = 0.0;
//   late Duration _videoDuration;
//   File? _generatedVideoFile;
//   File? _selectedImage;
//   File? _topBannerImage;
//   String _name = " ";
//   String _designation = " ";
//   final ImagePicker _picker = ImagePicker();
//   bool _nameItalic = false;
//   bool _designationItalic = false;
//   // Protocol Images
//   List<ProtocolImage> _protocolImages = [];
//   String? _selectedProtocolImageUrl;
//
//   // Self Images
//   List<SelfImage> _apiSelfImages = [];
//   String? _selectedFooterImageUrl;
//   List<FooterImage> _footerImages = [];
//   File? _selectedFooterImageFile;
//
//   // Color properties
//   Color _nameContainerColor = Colors.black.withOpacity(0.5);
//   Color _nameTextColor = Colors.white;
//   Color _designationTextColor = Colors.white;
//   Color _dividerColor = Colors.transparent;
//
//   // Text style properties
//   double _nameFontSize = 16.0;
//   double _designationFontSize = 14.0;
//   FontWeight _nameFontWeight = FontWeight.bold;
//   FontWeight _designationFontWeight = FontWeight.normal;
//
//   // Bottom image position
//   String? _selectedPosition = 'right';
//   int _positionVersion = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.network(widget.videoUrl)
//       ..initialize().then((_) {
//         setState(() {
//           _videoDuration = _controller.value.duration;
//           _controller.play();
//           _isPlaying = true;
//         });
//       });
//
//     _controller.addListener(() {
//       if (mounted) {
//         setState(() {});
//       }
//     });
//
//     _generatedVideoController = VideoPlayerController.network('')
//       ..addListener(() {
//         if (mounted) setState(() {});
//       });
//
//     FFmpegKitConfig.init();
//     _loadProtocolImages();
//     _loadApiSelfImages();
//     _loadFooterImages();
//   }
//
//   Future<void> _loadApiSelfImages() async {
//     try {
//       final images = await ApiService().fetchSelfImages();
//       setState(() {
//         _apiSelfImages = images;
//         if (images.isNotEmpty) {
//           _selectedPosition = images.first.position.toLowerCase();
//         }
//       });
//     } catch (e) {
//       print('Error loading self images: $e');
//     }
//   }
//
//   Future<void> _loadProtocolImages() async {
//     try {
//       final images = await ApiService().fetchProtocolImages();
//       setState(() {
//         _protocolImages = images;
//       });
//     } catch (e) {
//       print('Error loading protocol images: $e');
//     }
//   }
//
//   Future<void> _loadFooterImages() async {
//     try {
//       final images = await ApiService().fetchFooterImages();
//       setState(() {
//         _footerImages = images;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading footer images: $e')),
//       );
//     }
//   }
//
//   Future<void> _pickFooterImage() async {
//     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedFooterImageFile = File(pickedFile.path);
//         _selectedFooterImageUrl = pickedFile.path;
//       });
//     }
//   }
//
//   void _selectFooterImage(int index) {
//     if (index < _footerImages.length) {
//       setState(() {
//         _selectedFooterImageUrl = _footerImages[index].imageUrl;
//         _selectedFooterImageFile = null;
//       });
//     }
//   }
//
//   Future<void> _addProtocolImage() async {
//     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _protocolImages.add(ProtocolImage(
//           imageUrl: pickedFile.path,
//           id: DateTime.now().millisecondsSinceEpoch.toString(),
//         ));
//         _selectedProtocolImageUrl = pickedFile.path;
//       });
//     }
//   }
//
//   void _selectProtocolImage(int index) {
//     if (index < _protocolImages.length) {
//       setState(() {
//         _selectedProtocolImageUrl = _protocolImages[index].imageUrl;
//       });
//     }
//   }
//
//   Widget _buildProtocolRow() {
//     const double boxWidth = 200.0;
//     const double boxHeight = 90.0;
//     const double boxSpacing = 8.0;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "PROTOCOL",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     ..._protocolImages.map((image) {
//                       return GestureDetector(
//                         onTap: () => _selectProtocolImage(_protocolImages.indexOf(image)),
//                         child: Container(
//                           width: boxWidth,
//                           height: boxHeight,
//                           margin: EdgeInsets.only(right: boxSpacing),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[300],
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(
//                               color: _selectedProtocolImageUrl == image.imageUrl
//                                   ? Colors.deepPurple
//                                   : Colors.transparent,
//                               width: 2,
//                             ),
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(6),
//                             child: image.imageUrl.startsWith('http')
//                                 ? Image.network(
//                               image.imageUrl,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return const Icon(Icons.broken_image);
//                               },
//                             )
//                                 : Image.file(
//                               File(image.imageUrl),
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ],
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: _addProtocolImage,
//               child: Container(
//                 width: 80,
//                 height: 60,
//                 margin: EdgeInsets.only(left: boxSpacing),
//                 decoration: BoxDecoration(
//                   color: Colors.deepPurple,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.grey[400]!),
//                 ),
//                 child: const Icon(Icons.add, color: Colors.white, size: 28),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   void _togglePlayback() {
//     setState(() {
//       if (_controller.value.isPlaying) {
//         _controller.pause();
//         _isPlaying = false;
//       } else {
//         _controller.play();
//         _isPlaying = true;
//       }
//     });
//   }
//
//   Future<void> _pickBottomImage() async {
//     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//         _selectedPosition = 'right'; // Default to right when adding new image
//         _positionVersion++;
//       });
//     }
//   }
//
//   Future<bool> _requestStoragePermission() async {
//     if (Platform.isAndroid) {
//       final storageGranted = await Permission.storage.isGranted;
//       final photosGranted = await Permission.photos.isGranted;
//       final manageStorageGranted = await Permission.manageExternalStorage.isGranted;
//
//       if (storageGranted || photosGranted || manageStorageGranted) {
//         return true;
//       }
//
//       final statuses = await [
//         Permission.storage,
//         Permission.photos,
//         if (await Permission.manageExternalStorage.isRestricted)
//           Permission.manageExternalStorage,
//       ].request();
//
//       if (statuses.values.any((status) => status.isGranted)) {
//         return true;
//       }
//
//       bool? shouldOpenSettings = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Permission Required'),
//           content: const Text('We need storage permissions to save your generated images.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('Deny'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text('Allow'),
//             ),
//           ],
//         ),
//       );
//
//       if (shouldOpenSettings == true) {
//         await openAppSettings();
//       }
//       return false;
//     }
//     return true;
//   }
//
//   void _editText(String title, String currentValue, Function(String) onSave) {
//     TextEditingController controller = TextEditingController(text: currentValue);
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Edit $title"),
//           content: TextField(
//             controller: controller,
//             decoration: InputDecoration(hintText: "Enter $title"),
//           ),
//           actions: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text("Cancel"),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     setState(() {
//                       onSave(controller.text);
//                     });
//                     Navigator.of(context).pop();
//                   },
//                   child: const Text("Save"),
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<File> _simulateVideoProcessing() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final filePath = '${directory.path}/processed_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
//
//     File originalVideoFile;
//     if (widget.videoUrl.startsWith('http')) {
//       final response = await Dio().get(
//         widget.videoUrl,
//         options: Options(responseType: ResponseType.bytes),
//       );
//       originalVideoFile = File('${directory.path}/temp_video.mp4');
//       await originalVideoFile.writeAsBytes(response.data);
//     } else {
//       originalVideoFile = File(widget.videoUrl);
//       if (!await originalVideoFile.exists()) {
//         throw Exception("Local video file not found: ${widget.videoUrl}");
//       }
//     }
//
//     final videoWithOverlays = await _createVideoWithOverlays(originalVideoFile);
//
//     if (widget.videoUrl.startsWith('http')) {
//       await originalVideoFile.delete();
//     }
//
//     return videoWithOverlays;
//   }
//
//   Future<File> _createVideoWithOverlays(File originalVideo) async {
//     final directory = await getApplicationDocumentsDirectory();
//     final outputPath = '${directory.path}/final_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
//
//     await Directory(directory.path).create(recursive: true);
//
//     final overlayImage = await _createCompositeOverlay();
//
//     if (!await overlayImage.exists()) {
//       throw Exception("Overlay image not found at ${overlayImage.path}");
//     }
//
//     final overlayPath = overlayImage.path;
//     final inputVideoPath = originalVideo.path;
//
//     // Set HD resolution (1080p)
//     const hdWidth = 1920;
//     const hdHeight = 1080;
//
//     final command = '-y -i "$inputVideoPath" -i "$overlayPath" '
//         '-filter_complex "[1]format=rgba,scale=$hdWidth:$hdHeight:force_original_aspect_ratio=decrease:flags=lanczos,pad=$hdWidth:$hdHeight:(ow-iw)/2:(oh-ih)/2[scaled];'
//         '[0][scaled]overlay=0:0:format=auto:alpha=premultiplied" '
//         '-c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -c:a copy "$outputPath"';
//
//     final session = await FFmpegKit.execute(command);
//     final returnCode = await session.getReturnCode();
//
//     if (ReturnCode.isSuccess(returnCode)) {
//       final outputFile = File(outputPath);
//       if (await outputFile.exists()) {
//         return outputFile;
//       } else {
//         throw Exception("Output file not created: $outputPath");
//       }
//     } else {
//       final logs = await session.getAllLogsAsString();
//       throw Exception('FFmpeg failed with code $returnCode. Logs:\n$logs');
//     }
//   }
//
//   void _updatePosition(String position) {
//     setState(() {
//       _selectedPosition = position.trim().toLowerCase();
//       _positionVersion++;
//     });
//   }
//
//   Widget _buildBottomImageSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "BOTTOM IMAGE",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     ..._apiSelfImages.map((image) {
//                       return GestureDetector(
//                         onTap: () async {
//                           try {
//                             File? imageFile;
//                             if (image.imageUrl.startsWith('http')) {
//                               final response = await Dio().get(
//                                 image.imageUrl,
//                                 options: Options(responseType: ResponseType.bytes),
//                               );
//                               final tempDir = await getTemporaryDirectory();
//                               final fileName = path.basename(image.imageUrl);
//                               imageFile = File('${tempDir.path}/$fileName');
//                               await imageFile.writeAsBytes(response.data);
//                             } else {
//                               imageFile = File(image.imageUrl);
//                             }
//
//                             if (await imageFile.exists()) {
//                               setState(() {
//                                 _selectedImage = imageFile;
//                                 _selectedPosition = image.position.toLowerCase();
//                                 _positionVersion++;
//                               });
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text('Image file not found')),
//                               );
//                             }
//                           } catch (e) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text('Error loading image: $e')),
//                             );
//                           }
//                         },
//                         child: Container(
//                           width: 60,
//                           height: 60,
//                           margin: const EdgeInsets.only(right: 8),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[300],
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(
//                               color: _selectedImage?.path.endsWith(path.basename(image.imageUrl)) ?? false
//                                   ? Colors.deepPurple
//                                   : Colors.transparent,
//                               width: 2,
//                             ),
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(6),
//                             child: image.imageUrl.startsWith('http')
//                                 ? Image.network(
//                               image.imageUrl,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return const Icon(Icons.broken_image);
//                               },
//                             )
//                                 : Image.file(
//                               File(image.imageUrl),
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return const Icon(Icons.broken_image);
//                               },
//                             ),
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ],
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: _pickBottomImage,
//               child: Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: Colors.deepPurple,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.white),
//                 ),
//                 child: const Icon(Icons.add, color: Colors.white, size: 28),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Future<File> _createCompositeOverlay() async {
//     try {
//       if (!_controller.value.isInitialized) {
//         throw Exception("Video controller not initialized");
//       }
//       final videoWidth = _controller.value.size.width.toInt();
//       final videoHeight = _controller.value.size.height.toInt();
//
//       final overlayImage = img.Image(width: videoWidth, height: videoHeight, numChannels: 4);
//       img.fill(overlayImage, color: img.ColorRgba8(0, 0, 0, 0));
//
//       // Add footer background first (bottom layer)
//       if (_selectedFooterImageUrl != null || _selectedFooterImageFile != null) {
//         try {
//           Uint8List footerBytes;
//           if (_selectedFooterImageFile != null) {
//             footerBytes = await _selectedFooterImageFile!.readAsBytes();
//           } else if (_selectedFooterImageUrl!.startsWith('http')) {
//             final response = await Dio().get(
//               _selectedFooterImageUrl!,
//               options: Options(responseType: ResponseType.bytes),
//             );
//             footerBytes = Uint8List.fromList(response.data);
//           } else {
//             footerBytes = await File(_selectedFooterImageUrl!).readAsBytes();
//           }
//
//           if (footerBytes.isNotEmpty) {
//             final footerImage = img.decodeImage(footerBytes);
//             if (footerImage != null) {
//               final resizedFooter = img.copyResize(
//                 footerImage,
//                 width: videoWidth,
//                 height: 90,
//               );
//               img.compositeImage(
//                 overlayImage,
//                 resizedFooter,
//                 dstX: 0,
//                 dstY: videoHeight - 90,
//               );
//             }
//           }
//         } catch (e) {
//           debugPrint('Error processing footer image: $e');
//         }
//       } else {
//         // If no footer image is selected, draw a colored container
//         final containerColor = img.ColorRgba8(
//           _nameContainerColor.red,
//           _nameContainerColor.green,
//           _nameContainerColor.blue,
//           (_nameContainerColor.opacity * 255).toInt(),
//         );
//         img.fillRect(
//           overlayImage,
//           x1: 0,
//           y1: videoHeight - 90,
//           x2: videoWidth,
//           y2: videoHeight,
//           color: containerColor,
//         );
//       }
//
//       // Add protocol banner (top layer)
//       if (_selectedProtocolImageUrl != null) {
//         try {
//           Uint8List bannerBytes;
//           if (_selectedProtocolImageUrl!.startsWith('http')) {
//             final response = await Dio().get(
//               _selectedProtocolImageUrl!,
//               options: Options(responseType: ResponseType.bytes),
//             );
//             bannerBytes = Uint8List.fromList(response.data);
//           } else {
//             bannerBytes = await File(_selectedProtocolImageUrl!).readAsBytes();
//           }
//
//           if (bannerBytes.isNotEmpty) {
//             final bannerImage = img.decodeImage(bannerBytes);
//             if (bannerImage != null) {
//               final resizedBanner = img.copyResize(
//                 bannerImage,
//                 width: videoWidth,
//                 height: 190,
//               );
//               img.compositeImage(overlayImage, resizedBanner, dstX: 0, dstY: 0);
//             }
//           }
//         } catch (e) {
//           debugPrint('Error processing protocol image: $e');
//         }
//       }
//
//       const containerHeight = 90;
//       const padding = 3;
//       final containerY = videoHeight - containerHeight;
//
//       final nameTextColor = img.ColorRgba8(_nameTextColor.red, _nameTextColor.green, _nameTextColor.blue, 255);
//       final designationTextColor = img.ColorRgba8(_designationTextColor.red, _designationTextColor.green, _designationTextColor.blue, 255);
//       final dividerColor = img.ColorRgba8(
//         _dividerColor.red,
//         _dividerColor.green,
//         _dividerColor.blue,
//         _dividerColor.alpha,
//       );
//
//       final baseFont = videoWidth >= 720 ? img.arial48 : img.arial24;
//       final textY = containerY + (containerHeight - baseFont.lineHeight) ~/ 2;
//
//       // Draw divider
//       final dividerX = videoWidth ~/ 2;
//       img.drawLine(
//         overlayImage,
//         x1: dividerX,
//         y1: containerY + 5,
//         x2: dividerX,
//         y2: videoHeight - 5,
//         color: dividerColor,
//         thickness: 2,
//       );
//
//       // Draw text
//       img.drawString(
//         overlayImage,
//         _name,
//         font: baseFont,
//         x: padding,
//         y: textY,
//         color: nameTextColor,
//       );
//
//       img.drawString(
//         overlayImage,
//         _designation,
//         font: baseFont,
//         x: dividerX + padding,
//         y: textY,
//         color: designationTextColor,
//       );
//
//       if (_selectedImage != null) {
//         final bottomImageBytes = await _selectedImage!.readAsBytes();
//         final bottomImage = img.decodeImage(bottomImageBytes);
//         if (bottomImage != null) {
//           final resizedImage = img.copyResize(
//             bottomImage,
//             width: 200,
//             height: 210,
//           );
//           // Calculate position based on selection
//           final dstX = _selectedPosition == 'left' ? 0 : videoWidth - resizedImage.width - 0;
//           img.compositeImage(
//             overlayImage,
//             resizedImage,
//             dstX: dstX,
//             dstY: containerY - resizedImage.height - 0,
//           );
//         }
//       }
//
//       final tempDir = await getTemporaryDirectory();
//       final overlayPath = '${tempDir.path}/overlay_${DateTime.now().millisecondsSinceEpoch}.png';
//       final overlayFile = File(overlayPath);
//       await overlayFile.writeAsBytes(img.encodePng(overlayImage));
//
//       return overlayFile;
//     } catch (e) {
//       debugPrint('Error creating overlay: $e');
//       rethrow;
//     }
//   }
//
//   Future<void> _saveVideoToGallery(File videoFile) async {
//     try {
//       if (!await videoFile.exists() || await videoFile.length() == 0) {
//         throw Exception("Video file is empty or doesn't exist");
//       }
//
//       final hasPermission = await _requestStoragePermission();
//       if (!hasPermission) {
//         throw Exception("Storage permission not granted");
//       }
//
//       final result = await PhotoManager.editor.saveVideo(
//         videoFile,
//         title: "polyposter_video_${DateTime.now().millisecondsSinceEpoch}.mp4",
//       );
//
//       if (result == null) {
//         throw Exception("Failed to save to gallery");
//       }
//
//       final downloadsDirectory = Platform.isAndroid
//           ? Directory('/storage/emulated/0/Download')
//           : await getApplicationDocumentsDirectory();
//
//       if (!await downloadsDirectory.exists()) {
//         await downloadsDirectory.create(recursive: true);
//       }
//
//       final fileName = 'polyposter_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
//       final savedFile = File(path.join(downloadsDirectory.path, fileName));
//       await videoFile.copy(savedFile.path);
//
//       setState(() {
//         _generatedVideoFile = savedFile;
//         _generatedVideoController = VideoPlayerController.file(savedFile)
//           ..initialize().then((_) {
//             setState(() {});
//             _generatedVideoController.play();
//             _showGeneratedVideoPopup();
//           });
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Video with all edits saved successfully!')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error saving video: ${e.toString()}')),
//       );
//     }
//   }
//
//   void _startVideoProcessing() async {
//     if (_isProcessing) return;
//
//     setState(() {
//       _isProcessing = true;
//       _progressValue = 0.0;
//     });
//
//     const processingDuration = Duration(seconds: 5);
//     const updateInterval = Duration(milliseconds: 100);
//     final totalUpdates = processingDuration.inMilliseconds ~/ updateInterval.inMilliseconds;
//     final increment = 1.0 / totalUpdates;
//
//     Timer.periodic(updateInterval, (Timer timer) async {
//       setState(() {
//         _progressValue += increment;
//         if (_progressValue >= 1.0) {
//           _progressValue = 1.0;
//           timer.cancel();
//         }
//       });
//
//       if (_progressValue >= 1.0) {
//         try {
//           final processedFile = await _simulateVideoProcessing();
//           await _saveVideoToGallery(processedFile);
//
//           setState(() {
//             _isProcessing = false;
//           });
//
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Video processing complete!')),
//           );
//         } catch (e) {
//           setState(() {
//             _isProcessing = false;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error processing video: $e')),
//           );
//         }
//       }
//     });
//   }
//
//   Future<void> _shareVideo(String platform) async {
//     if (_generatedVideoFile == null) return;
//
//     final text = 'Check out my video created with PolyPoster!';
//
//     try {
//       if (platform == 'other') {
//         await Share.shareXFiles(
//           [XFile(_generatedVideoFile!.path)],
//           text: text,
//         );
//       } else {
//         await Share.shareXFiles(
//           [XFile(_generatedVideoFile!.path)],
//           text: text,
//           subject: 'My PolyPoster Video',
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error sharing video: $e')),
//       );
//     }
//   }
//
//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final minutes = twoDigits(duration.inMinutes);
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return "$minutes:$seconds";
//   }
//
//   Future<void> _selectContainerColor() async {
//     final Color? pickedColor = await showDialog<Color>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Select Container Color'),
//         content: SingleChildScrollView(
//           child: ColorPicker(
//             pickerColor: _nameContainerColor,
//             onColorChanged: (color) {
//               _nameContainerColor = color;
//             },
//             showLabel: true,
//             pickerAreaHeightPercent: 0.8,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, _nameContainerColor),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//
//     if (pickedColor != null) {
//       setState(() {
//         _nameContainerColor = pickedColor;
//       });
//     }
//   }
//
//   Future<void> _selectNameTextColor() async {
//     final Color? pickedColor = await showDialog<Color>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Select Name Text Color'),
//         content: SingleChildScrollView(
//           child: ColorPicker(
//             pickerColor: _nameTextColor,
//             onColorChanged: (color) {
//               _nameTextColor = color;
//             },
//             showLabel: true,
//             pickerAreaHeightPercent: 0.8,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, _nameTextColor),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//
//     if (pickedColor != null) {
//       setState(() {
//         _nameTextColor = pickedColor;
//       });
//     }
//   }
//
//   Future<void> _selectDesignationTextColor() async {
//     final Color? pickedColor = await showDialog<Color>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Select Designation Text Color'),
//         content: SingleChildScrollView(
//           child: ColorPicker(
//             pickerColor: _designationTextColor,
//             onColorChanged: (color) {
//               _designationTextColor = color;
//             },
//             showLabel: true,
//             pickerAreaHeightPercent: 0.8,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, _designationTextColor),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//
//     if (pickedColor != null) {
//       setState(() {
//         _designationTextColor = pickedColor;
//       });
//     }
//   }
//
//   Future<void> _selectDividerColor() async {
//     final Color? pickedColor = await showDialog<Color>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Select Divider Color'),
//         content: SingleChildScrollView(
//           child: ColorPicker(
//             pickerColor: _dividerColor,
//             onColorChanged: (color) {
//               _dividerColor = color;
//             },
//             showLabel: true,
//             pickerAreaHeightPercent: 0.8,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, _dividerColor),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//
//     if (pickedColor != null) {
//       setState(() {
//         _dividerColor = pickedColor;
//       });
//     }
//   }
//
//   void _showTextStyleDialog() {
//     Color tempContainerColor = _nameContainerColor;
//     Color tempNameColor = _nameTextColor;
//     Color tempDesignationColor = _designationTextColor;
//     Color tempDividerColor = _dividerColor;
//     bool tempNameBold = _nameFontWeight == FontWeight.bold;
//     bool tempNameItalic = _nameItalic;
//     bool tempDesignationBold = _designationFontWeight == FontWeight.bold;
//     bool tempDesignationItalic = _designationItalic;
//     double tempNameFontSize = _nameFontSize;
//     double tempDesignationFontSize = _designationFontSize;
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Text & Container Style'),
//           content: StatefulBuilder(
//             builder: (context, setState) {
//               return SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // LIVE PREVIEW
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(12),
//                       margin: const EdgeInsets.only(bottom: 16),
//                       decoration: BoxDecoration(
//                         color: tempContainerColor,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Name Preview',
//                             style: TextStyle(
//                               color: tempNameColor,
//                               fontSize: tempNameFontSize,
//                               fontWeight: tempNameBold ? FontWeight.bold : FontWeight.normal,
//                               fontStyle: tempNameItalic ? FontStyle.italic : FontStyle.normal,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Divider(
//                             color: tempDividerColor,
//                             thickness: 2,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Designation Preview',
//                             style: TextStyle(
//                               color: tempDesignationColor,
//                               fontSize: tempDesignationFontSize,
//                               fontWeight: tempDesignationBold ? FontWeight.bold : FontWeight.normal,
//                               fontStyle: tempDesignationItalic ? FontStyle.italic : FontStyle.normal,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     // Container Color
//                     ListTile(
//                       title: const Text('Container Color'),
//                       trailing: GestureDetector(
//                         onTap: () async {
//                           final Color? pickedColor = await showDialog<Color>(
//                             context: context,
//                             builder: (context) => AlertDialog(
//                               title: const Text('Select Container Color'),
//                               content: SingleChildScrollView(
//                                 child: ColorPicker(
//                                   pickerColor: tempContainerColor,
//                                   onColorChanged: (color) {
//                                     setState(() => tempContainerColor = color);
//                                   },
//                                   showLabel: true,
//                                   pickerAreaHeightPercent: 0.8,
//                                 ),
//                               ),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(context),
//                                   child: const Text('Cancel'),
//                                 ),
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(context, tempContainerColor),
//                                   child: const Text('OK'),
//                                 ),
//                               ],
//                             ),
//                           );
//                           if (pickedColor != null) {
//                             setState(() => tempContainerColor = pickedColor);
//                           }
//                         },
//                         child: Container(
//                           width: 30,
//                           height: 30,
//                           decoration: BoxDecoration(
//                             color: tempContainerColor,
//                             borderRadius: BorderRadius.circular(4),
//                             border: Border.all(color: Colors.grey),
//                           ),
//                         ),
//                       ),
//                     ),
//                     // Divider Color
//                     ListTile(
//                       title: const Text('Divider Color'),
//                       trailing: GestureDetector(
//                         onTap: () async {
//                           final Color? pickedColor = await showDialog<Color>(
//                             context: context,
//                             builder: (context) => AlertDialog(
//                               title: const Text('Select Divider Color'),
//                               content: SingleChildScrollView(
//                                 child: ColorPicker(
//                                   pickerColor: tempDividerColor,
//                                   onColorChanged: (color) {
//                                     setState(() => tempDividerColor = color);
//                                   },
//                                   showLabel: true,
//                                   pickerAreaHeightPercent: 0.8,
//                                 ),
//                               ),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(context),
//                                   child: const Text('Cancel'),
//                                 ),
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(context, tempDividerColor),
//                                   child: const Text('OK'),
//                                 ),
//                               ],
//                             ),
//                           );
//                           if (pickedColor != null) {
//                             setState(() => tempDividerColor = pickedColor);
//                           }
//                         },
//                         child: Container(
//                           width: 30,
//                           height: 30,
//                           decoration: BoxDecoration(
//                             color: tempDividerColor,
//                             borderRadius: BorderRadius.circular(4),
//                             border: Border.all(color: Colors.grey),
//                           ),
//                         ),
//                       ),
//                     ),
//                     // Name Text Style
//                     const SizedBox(height: 16),
//                     const Text('Name Text Style', style: TextStyle(fontWeight: FontWeight.bold)),
//                     ListTile(
//                       title: const Text('Name Color'),
//                       trailing: GestureDetector(
//                         onTap: () async {
//                           final Color? pickedColor = await showDialog<Color>(
//                             context: context,
//                             builder: (context) => AlertDialog(
//                               title: const Text('Select Name Color'),
//                               content: SingleChildScrollView(
//                                 child: ColorPicker(
//                                   pickerColor: tempNameColor,
//                                   onColorChanged: (color) {
//                                     setState(() => tempNameColor = color);
//                                   },
//                                   showLabel: true,
//                                   pickerAreaHeightPercent: 0.8,
//                                 ),
//                               ),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(context),
//                                   child: const Text('Cancel'),
//                                 ),
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(context, tempNameColor),
//                                   child: const Text('OK'),
//                                 ),
//                               ],
//                             ),
//                           );
//                           if (pickedColor != null) {
//                             setState(() => tempNameColor = pickedColor);
//                           }
//                         },
//                         child: Container(
//                           width: 30,
//                           height: 30,
//                           decoration: BoxDecoration(
//                             color: tempNameColor,
//                             borderRadius: BorderRadius.circular(4),
//                             border: Border.all(color: Colors.grey),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         Checkbox(
//                           value: tempNameBold,
//                           onChanged: (value) => setState(() => tempNameBold = value!),
//                         ),
//                         const Text('Bold'),
//                         const SizedBox(width: 20),
//                         Checkbox(
//                           value: tempNameItalic,
//                           onChanged: (value) => setState(() => tempNameItalic = value!),
//                         ),
//                         const Text('Italic'),
//                       ],
//                     ),
//                     Slider(
//                       value: tempNameFontSize,
//                       min: 10,
//                       max: 30,
//                       onChanged: (value) => setState(() => tempNameFontSize = value),
//                       label: 'Font Size: ${tempNameFontSize.toInt()}',
//                     ),
//                     // Designation Text Style
//                     const SizedBox(height: 16),
//                     const Text('Designation Text Style', style: TextStyle(fontWeight: FontWeight.bold)),
//                     ListTile(
//                       title: const Text('Designation Color'),
//                       trailing: GestureDetector(
//                         onTap: () async {
//                           final Color? pickedColor = await showDialog<Color>(
//                             context: context,
//                             builder: (context) => AlertDialog(
//                               title: const Text('Select Designation Color'),
//                               content: SingleChildScrollView(
//                                 child: ColorPicker(
//                                   pickerColor: tempDesignationColor,
//                                   onColorChanged: (color) {
//                                     setState(() => tempDesignationColor = color);
//                                   },
//                                   showLabel: true,
//                                   pickerAreaHeightPercent: 0.8,
//                                 ),
//                               ),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(context),
//                                   child: const Text('Cancel'),
//                                 ),
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(context, tempDesignationColor),
//                                   child: const Text('OK'),
//                                 ),
//                               ],
//                             ),
//                           );
//                           if (pickedColor != null) {
//                             setState(() => tempDesignationColor = pickedColor);
//                           }
//                         },
//                         child: Container(
//                           width: 30,
//                           height: 30,
//                           decoration: BoxDecoration(
//                             color: tempDesignationColor,
//                             borderRadius: BorderRadius.circular(4),
//                             border: Border.all(color: Colors.grey),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         Checkbox(
//                           value: tempDesignationBold,
//                           onChanged: (value) => setState(() => tempDesignationBold = value!),
//                         ),
//                         const Text('Bold'),
//                         const SizedBox(width: 20),
//                         Checkbox(
//                           value: tempDesignationItalic,
//                           onChanged: (value) => setState(() => tempDesignationItalic = value!),
//                         ),
//                         const Text('Italic'),
//                       ],
//                     ),
//                     Slider(
//                       value: tempDesignationFontSize,
//                       min: 10,
//                       max: 30,
//                       onChanged: (value) => setState(() => tempDesignationFontSize = value),
//                       label: 'Font Size: ${tempDesignationFontSize.toInt()}',
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('CANCEL'),
//             ),
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   _nameContainerColor = tempContainerColor;
//                   _nameTextColor = tempNameColor;
//                   _designationTextColor = tempDesignationColor;
//                   _dividerColor = tempDividerColor;
//                   _nameFontWeight = tempNameBold ? FontWeight.bold : FontWeight.normal;
//                   _nameItalic = tempNameItalic;
//                   _designationFontWeight = tempDesignationBold ? FontWeight.bold : FontWeight.normal;
//                   _designationItalic = tempDesignationItalic;
//                   _nameFontSize = tempNameFontSize;
//                   _designationFontSize = tempDesignationFontSize;
//                 });
//                 Navigator.pop(context);
//               },
//               child: const Text('APPLY'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
// // Helper function for color picker
//   Future<Color?> pickColor(BuildContext context, Color currentColor) async {
//     Color temp = currentColor;
//     return showDialog<Color>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Pick Color'),
//         content: SingleChildScrollView(
//           child: ColorPicker(
//             pickerColor: currentColor,
//             onColorChanged: (c) => temp = c,
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
//           TextButton(onPressed: () => Navigator.pop(context, temp), child: Text('Select')),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCustomControls() {
//     final position = _controller.value.position;
//     final duration = _controller.value.duration;
//
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.black,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: Row(
//         children: [
//           IconButton(
//             icon: Icon(
//               _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//               color: Colors.white,
//               size: 20,
//             ),
//             onPressed: _togglePlayback,
//           ),
//           Text(
//             _formatDuration(position),
//             style: const TextStyle(color: Colors.white, fontSize: 12),
//           ),
//           Expanded(
//             child: Slider(
//               activeColor: Colors.white,
//               inactiveColor: Colors.white30,
//               min: 0,
//               max: duration.inSeconds.toDouble(),
//               value: position.inSeconds.clamp(0, duration.inSeconds).toDouble(),
//               onChanged: (value) {
//                 _controller.seekTo(Duration(seconds: value.toInt()));
//               },
//             ),
//           ),
//           Text(
//             _formatDuration(duration),
//             style: const TextStyle(color: Colors.white, fontSize: 12),
//           ),
//           const SizedBox(width: 4),
//           const Icon(Icons.volume_up, color: Colors.white, size: 20),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildResponsiveButton(String text, VoidCallback onPressed) {
//     return ConstrainedBox(
//       constraints: const BoxConstraints(minWidth: 120), // Minimum width to maintain design
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.deepPurple,
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           minimumSize: const Size(120, 48), // Maintain minimum touch target
//         ),
//         onPressed: onPressed,
//         child: Text(
//           text,
//           style: const TextStyle(fontSize: 16, color: Colors.white),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildShareButton(String imageName, String label, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.grey.shade200,
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(10),
//               child: Image.asset(
//                 'assets/images/$imageName.png',
//                 fit: BoxFit.contain,
//                 errorBuilder: (context, error, stackTrace) => const Icon(Icons.share),
//               ),
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(label, style: const TextStyle(fontSize: 12)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFooterImageRow() {
//     const double boxWidth = 200.0;
//     const double boxHeight = 90.0;
//     const double boxSpacing = 8.0;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "FOOTER BACKGROUND",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     ..._footerImages.map((image) {
//                       return GestureDetector(
//                         onTap: () => _selectFooterImage(_footerImages.indexOf(image)),
//                         child: Container(
//                           width: boxWidth,
//                           height: boxHeight,
//                           margin: EdgeInsets.only(right: boxSpacing),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[300],
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(
//                               color: _selectedFooterImageUrl == image.imageUrl
//                                   ? Colors.deepPurple
//                                   : Colors.transparent,
//                               width: 2,
//                             ),
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(6),
//                             child: image.imageUrl.startsWith('http')
//                                 ? Image.network(
//                               image.imageUrl,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return const Icon(Icons.broken_image);
//                               },
//                             )
//                                 : Image.file(
//                               File(image.imageUrl),
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ],
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: _pickFooterImage,
//               child: Container(
//                 width: 80,
//                 height: 60,
//                 margin: EdgeInsets.only(left: boxSpacing),
//                 decoration: BoxDecoration(
//                   color: Colors.deepPurple,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.grey[400]!),
//                 ),
//                 child: const Icon(Icons.add, color: Colors.white, size: 28),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(
//           widget.pageTitle ?? "Video Editor",
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.deepPurple,
//         elevation: 0,
//         toolbarHeight: kToolbarHeight,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 16),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.orange,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.all(8),
//                 child: _controller.value.isInitialized
//                     ? Column(
//                   children: [
//                     AspectRatio(
//                       aspectRatio: _controller.value.aspectRatio,
//                       child: Stack(
//                         children: [
//                           VideoPlayer(_controller),
//                           if (_selectedProtocolImageUrl != null)
//                             Positioned(
//                               top: 0,
//                               left: 0,
//                               right: 0,
//                               child: _selectedProtocolImageUrl!.startsWith('http')
//                                   ? Image.network(
//                                 _selectedProtocolImageUrl!,
//                                 width: double.infinity,
//                                 height: 120,
//                                 fit: BoxFit.cover,
//                               )
//                                   : Image.file(
//                                 File(_selectedProtocolImageUrl!),
//                                 width: double.infinity,
//                                 height: 120,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           if (_selectedFooterImageUrl != null || _selectedFooterImageFile != null)
//                             Positioned(
//                               bottom: 0,
//                               left: 0,
//                               right: 0,
//                               child: Container(
//                                 height: 50,
//                                 child: _selectedFooterImageFile != null
//                                     ? Image.file(
//                                   _selectedFooterImageFile!,
//                                   width: double.infinity,
//                                   height: double.infinity,
//                                   fit: BoxFit.cover,
//                                 )
//                                     : _selectedFooterImageUrl!.startsWith('http')
//                                     ? Image.network(
//                                   _selectedFooterImageUrl!,
//                                   width: double.infinity,
//                                   height: double.infinity,
//                                   fit: BoxFit.cover,
//                                 )
//                                     : Image.file(
//                                   File(_selectedFooterImageUrl!),
//                                   width: double.infinity,
//                                   height: double.infinity,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                           if (_selectedImage != null)
//                             Positioned(
//                               bottom: 50,
//                               right: _selectedPosition == 'right' ? 1 : null,
//                               left: _selectedPosition == 'left' ? 1 : null,
//                               child: Container(
//                                 width: 90,
//                                 height: 120,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: Image.file(
//                                     _selectedImage!,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           Positioned(
//                             bottom: 1,
//                             left: 8,
//                             right: 8,
//                             child: Container(
//                               padding: const EdgeInsets.all(12),
//                               child: Center(
//                                 child: IntrinsicHeight(
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min, // This makes the row only as wide as its children
//                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                     children: [
//                                       GestureDetector(
//                                         onTap: () => _editText("Name", _name, (value) => _name = value),
//                                         child: Text(
//                                           _name,
//                                           style: TextStyle(
//                                             fontSize: _nameFontSize,
//                                             fontWeight: _nameFontWeight,
//                                             color: _nameTextColor,
//                                           ),
//                                           maxLines: 2,
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Container(
//                                         width: 2,
//                                         height: 24, // Fixed height for the divider
//                                         color: _dividerColor,
//                                         margin: const EdgeInsets.symmetric(vertical: 2),
//                                       ),
//                                       const SizedBox(width: 8),
//                                       GestureDetector(
//                                         onTap: () => _editText("Designation", _designation, (value) => _designation = value),
//                                         child: Text(
//                                           _designation,
//                                           style: TextStyle(
//                                             fontSize: _designationFontSize,
//                                             fontWeight: _designationFontWeight,
//                                             color: _designationTextColor,
//                                           ),
//                                           maxLines: 2,
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     _buildCustomControls(),
//                   ],
//                 )
//                     : const SizedBox(
//                   height: 200,
//                   child: Center(child: CircularProgressIndicator()),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               if (_isProcessing) ...[
//                 LinearProgressIndicator(
//                   value: _progressValue,
//                   backgroundColor: Colors.grey[300],
//                   valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
//                   minHeight: 10,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Processing: ${(_progressValue * 100).toStringAsFixed(1)}%',
//                   style: const TextStyle(fontSize: 14),
//                 ),
//                 const SizedBox(height: 12),
//               ],
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   _buildBottomImageSelector(),
//                   const SizedBox(height: 12),
//                   _buildFooterImageRow(),
//                   const SizedBox(height: 12),
//                   _buildProtocolRow(),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildResponsiveButton("Edit Name", () => _editText("Name", _name, (value) => _name = value)),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: _buildResponsiveButton("Edit Designation", () => _editText("Designation", _designation, (value) => _designation = value)),
//                   ),
//                   const SizedBox(width: 10),
//                   _buildResponsiveButton("Text Style Options", _showTextStyleDialog),
//                 ],
//               ),
//
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _isProcessing ? Colors.grey : Colors.deepPurple,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   onPressed: _isProcessing ? null : _startVideoProcessing,
//                   child: Text(
//                     _isProcessing ? 'Processing...' : 'Generate Video',
//                     style: const TextStyle(fontSize: 16, color: Colors.white),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               if (_generatedVideoFile != null) ...[
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: AspectRatio(
//                     aspectRatio: _generatedVideoController.value.aspectRatio,
//                     child: VideoPlayer(_generatedVideoController),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     IconButton(
//                       icon: Icon(
//                         _generatedVideoController.value.isPlaying ? Icons.pause : Icons.play_arrow,
//                         color: Colors.deepPurple,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           if (_generatedVideoController.value.isPlaying) {
//                             _generatedVideoController.pause();
//                           } else {
//                             _generatedVideoController.play();
//                           }
//                         });
//                       },
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.replay, color: Colors.deepPurple),
//                       onPressed: () {
//                         _generatedVideoController.seekTo(Duration.zero);
//                         _generatedVideoController.play();
//                       },
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   "Share your video:",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _buildShareButton("whatsapp", "WhatsApp", () => _shareVideo('whatsapp')),
//                     _buildShareButton("instagram", "Instagram", () => _shareVideo('instagram')),
//                     _buildShareButton("facebook", "Facebook", () => _shareVideo('facebook')),
//                     _buildShareButton("linkedin", "LinkedIn", () => _shareVideo('linkedin')),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showGeneratedVideoPopup() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Video Generated Successfully!'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               AspectRatio(
//                 aspectRatio: _generatedVideoController.value.aspectRatio,
//                 child: VideoPlayer(_generatedVideoController),
//               ),
//               const SizedBox(height: 50),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   IconButton(
//                     icon: Icon(
//                       _generatedVideoController.value.isPlaying
//                           ? Icons.pause
//                           : Icons.play_arrow,
//                       color: Colors.deepPurple,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         if (_generatedVideoController.value.isPlaying) {
//                           _generatedVideoController.pause();
//                         } else {
//                           _generatedVideoController.play();
//                         }
//                       });
//                     },
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.replay, color: Colors.deepPurple),
//                     onPressed: () {
//                       _generatedVideoController.seekTo(Duration.zero);
//                       _generatedVideoController.play();
//                     },
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 "Share your video:",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildShareButton("whatsapp", "WhatsApp", () {
//                     Navigator.pop(context);
//                     _shareVideo('whatsapp');
//                   }),
//                   _buildShareButton("instagram", "Instagram", () {
//                     Navigator.pop(context);
//                     _shareVideo('instagram');
//                   }),
//                   _buildShareButton("facebook", "Facebook", () {
//                     Navigator.pop(context);
//                     _shareVideo('facebook');
//                   }),
//                 ],
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
//
import 'dart:async';
import 'dart:io';
import 'package:ffmpeg_kit_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_min_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_min_gpl/return_code.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../config/colors.dart';
import '../../../../constants/app_colors.dart';
import '../../../../core/models/FooterImage.dart';
import '../../../../core/models/ProtocolImage.dart';
import '../../../../core/models/SelfImage.dart';
import '../../../../core/network/api_service.dart';

class VideoEditorPage extends StatefulWidget {
  final String videoUrl;
  final String? pageTitle;
  final String initialPosition;
  final int topDefNum;
  final int selfDefNum;
  final int bottomDefNum;

  const VideoEditorPage({
    required this.videoUrl,
    this.pageTitle = "Video Editor",
    super.key,
    this.initialPosition = "RIGHT",
    this.topDefNum = 0,
    this.selfDefNum = 0,
    this.bottomDefNum = 0,
  });

  @override
  State<VideoEditorPage> createState() => _VideoEditorPageState();
}

class _VideoEditorPageState extends State<VideoEditorPage> {
  late VideoPlayerController _controller;
  late VideoPlayerController _generatedVideoController;
  bool _isPlaying = false;
  bool _isProcessing = false;
  double _progressValue = 0.0;
  late Duration _videoDuration;
  File? _generatedVideoFile;
  File? _selectedImage;
  File? _topBannerImage;
  String _name = " ";
  String _designation = " ";
  final ImagePicker _picker = ImagePicker();
  bool _nameItalic = false;
  bool _designationItalic = false;

  // Protocol Images
  List<ProtocolImage> _protocolImages = [];
  String? _selectedProtocolImageUrl;
  Map<String, File> _protocolImageCache = {};

  // Self Images
  List<SelfImage> _apiSelfImages = [];
  String? _selectedFooterImageUrl;
  List<FooterImage> _footerImages = [];
  File? _selectedFooterImageFile;
  Map<String, File> _selfImageCache = {};
  Map<String, File> _footerImageCache = {};

  // Color properties
  Color _nameContainerColor = Colors.black.withOpacity(0.5);
  Color _nameTextColor = Colors.white;
  Color _designationTextColor = Colors.white;
  Color _dividerColor = Colors.transparent;

  // Text style properties
  double _nameFontSize = 16.0;
  double _designationFontSize = 14.0;
  FontWeight _nameFontWeight = FontWeight.bold;
  FontWeight _designationFontWeight = FontWeight.normal;

  // Bottom image position
  String? _selectedPosition = 'right';
  int _positionVersion = 0;

  @override
  void initState() {
    super.initState();

    _selectedPosition = widget.initialPosition.toLowerCase().trim();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    _controller.initialize().then((_) {
      setState(() {
        _videoDuration = _controller.value.duration;
        _controller.play();
        _isPlaying = true;
      });
    });

    _controller.addListener(() {
      if (mounted) setState(() {});
    });

    FFmpegKitConfig.init();
    _loadAllImages();
  }

  Future<void> _loadAllImages() async {
    await _loadProtocolImages();
    await _loadApiSelfImages();
    await _loadFooterImages();
  }

  Future<void> _loadApiSelfImages() async {
    try {
      final images = await ApiService().fetchSelfImages();

      // Filter images based on initialPosition
      List<SelfImage> filteredImages = [];
      if (widget.initialPosition.isNotEmpty) {
        final position = widget.initialPosition.toLowerCase().trim();

        // Only filter if position is specifically 'right' or 'left'
        if (position == 'right' || position == 'left') {
          filteredImages = images.where((image) =>
          image.position.toLowerCase().trim() == position).toList();
        } else {
          // If position is defined but not 'right' or 'left', show no images
          filteredImages = [];
        }
      } else {
        // If no initialPosition defined, show all images
        filteredImages = images;
      }

      // Pre-cache all self images
      for (var image in filteredImages) {
        await _cacheSelfImage(image);
      }

      setState(() {
        _apiSelfImages = images;

        // Reset selection if no filtered images
        if (filteredImages.isEmpty) {
          _selectedImage = null;
          _positionVersion++;
          return;
        }

        // Filter based on defNum value
        if (widget.selfDefNum != null && widget.selfDefNum! > 0) {
          try {
            // Find image with exact defNum match
            final matchingImage = filteredImages.firstWhere(
                  (image) => image.defNum == widget.selfDefNum,
            );

            // Additional position check
            if (widget.initialPosition.isEmpty ||
                matchingImage.position.toLowerCase().trim() ==
                    widget.initialPosition.toLowerCase().trim()) {
              // Use cached image
              _selectedImage = _selfImageCache[matchingImage.imageUrl];
              _selectedPosition = matchingImage.position.toLowerCase();
              _positionVersion++;
            } else {
              _selectedImage = null;
              _positionVersion++;
            }
          } catch (e) {
            // If no exact match found, use first image as fallback
            print('No image found with defNum ${widget.selfDefNum}, using first image');
            _selectedImage = _selfImageCache[filteredImages[0].imageUrl];
            _selectedPosition = filteredImages[0].position.toLowerCase();
            _positionVersion++;
          }
        } else {
          // Use first image if no specific selfDefNum requested
          _selectedImage = _selfImageCache[filteredImages[0].imageUrl];
          _selectedPosition = filteredImages[0].position.toLowerCase();
          _positionVersion++;
        }
      });
    } catch (e) {
      print('Error loading self images: $e');
      setState(() {
        _selectedImage = null;
        _positionVersion++;
      });
    }
  }

  // Cache self image for instant access
  Future<void> _cacheSelfImage(SelfImage image) async {
    try {
      if (_selfImageCache.containsKey(image.imageUrl)) return;

      File? imageFile;
      if (image.imageUrl.startsWith('http')) {
        final response = await Dio().get(
          image.imageUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        final tempDir = await getTemporaryDirectory();
        final fileName = path.basename(image.imageUrl);
        imageFile = File('${tempDir.path}/$fileName');
        await imageFile.writeAsBytes(response.data);
      } else {
        imageFile = File(image.imageUrl);
      }

      if (await imageFile.exists()) {
        _selfImageCache[image.imageUrl] = imageFile;
      } else {
        print('Image file not found: ${image.imageUrl}');
      }
    } catch (e) {
      print('Error caching self image: $e');
    }
  }
// Helper function to load and set self image
  Future<void> _loadAndSetSelfImage(SelfImage image) async {
    try {
      File? imageFile;
      if (image.imageUrl.startsWith('http')) {
        final response = await Dio().get(
          image.imageUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        final tempDir = await getTemporaryDirectory();
        final fileName = path.basename(image.imageUrl);
        imageFile = File('${tempDir.path}/$fileName');
        await imageFile.writeAsBytes(response.data);
      } else {
        imageFile = File(image.imageUrl);
      }

      if (await imageFile.exists()) {
        setState(() {
          _selectedImage = imageFile;
          _selectedPosition = image.position.toLowerCase();
          _positionVersion++;
        });
      } else {
        print('Image file not found: ${image.imageUrl}');
        setState(() {
          _selectedImage = null;
          _positionVersion++;
        });
      }
    } catch (e) {
      print('Error loading self image: $e');
      setState(() {
        _selectedImage = null;
        _positionVersion++;
      });
    }
  }

  Future<void> _loadProtocolImages() async {
    try {
      final images = await ApiService().fetchProtocolImages();

      // Pre-cache all protocol images
      for (var image in images) {
        await _cacheProtocolImage(image);
      }

      setState(() {
        _protocolImages = images;

        if (images.isEmpty) {
          _selectedProtocolImageUrl = null;
          print('No protocol images available');
          return;
        }

        // Filter based on defNum value
        if (widget.topDefNum > 0) {
          try {
            // Find image with exact defNum match
            final matchingImage = images.firstWhere(
                  (image) => image.defNum == widget.topDefNum,
            );
            _selectedProtocolImageUrl = matchingImage.imageUrl;
            print('Selected protocol image with defNum: ${widget.topDefNum}');
          } catch (e) {
            // If no exact match found, use first image as fallback
            print('No protocol image found with defNum ${widget.topDefNum}, using first image');
            _selectedProtocolImageUrl = images[0].imageUrl;
          }
        } else {
          // Use first image if no specific topDefNum requested
          _selectedProtocolImageUrl = images[0].imageUrl;
          print('Using first protocol image (no specific defNum requested)');
        }
      });
    } catch (e) {
      print('Error loading protocol images: $e');
      setState(() {
        _selectedProtocolImageUrl = null;
      });
    }
  }

  // Cache protocol image for instant access
  Future<void> _cacheProtocolImage(ProtocolImage image) async {
    try {
      if (_protocolImageCache.containsKey(image.imageUrl)) return;

      File? imageFile;
      if (image.imageUrl.startsWith('http')) {
        final response = await Dio().get(
          image.imageUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        final tempDir = await getTemporaryDirectory();
        final fileName = path.basename(image.imageUrl);
        imageFile = File('${tempDir.path}/$fileName');
        await imageFile.writeAsBytes(response.data);
      } else {
        imageFile = File(image.imageUrl);
      }

      if (await imageFile.exists()) {
        _protocolImageCache[image.imageUrl] = imageFile;
      } else {
        print('Protocol image file not found: ${image.imageUrl}');
      }
    } catch (e) {
      print('Error caching protocol image: $e');
    }
  }


  Future<void> _loadFooterImages() async {
    try {
      final images = await ApiService().fetchFooterImages();

      // Pre-cache all footer images
      for (var image in images) {
        await _cacheFooterImage(image);
      }

      setState(() {
        _footerImages = images;

        if (images.isEmpty) {
          _selectedFooterImageUrl = null;
          _selectedFooterImageFile = null;
          print('No footer images available');
          return;
        }

        // Filter based on defNum value
        if (widget.bottomDefNum > 0) {
          try {
            // Find image with exact defNum match
            final matchingImage = images.firstWhere(
                  (image) => image.defNum == widget.bottomDefNum,
            );
            _selectedFooterImageUrl = matchingImage.imageUrl;
            _selectedFooterImageFile = null;
            print('Selected footer image with defNum: ${widget.bottomDefNum}');
          } catch (e) {
            // If no exact match found, use first image as fallback
            print('No footer image found with defNum ${widget.bottomDefNum}, using first image');
            _selectedFooterImageUrl = images[0].imageUrl;
            _selectedFooterImageFile = null;
          }
        } else {
          // Use first image if no specific bottomDefNum requested
          _selectedFooterImageUrl = images[0].imageUrl;
          _selectedFooterImageFile = null;
          print('Using first footer image (no specific defNum requested)');
        }
      });
    } catch (e) {
      print('Error loading footer images: $e');
      setState(() {
        _selectedFooterImageUrl = null;
        _selectedFooterImageFile = null;
      });
    }
  }

  // Cache footer image for instant access
  Future<void> _cacheFooterImage(FooterImage image) async {
    try {
      if (_footerImageCache.containsKey(image.imageUrl)) return;

      File? imageFile;
      if (image.imageUrl.startsWith('http')) {
        final response = await Dio().get(
          image.imageUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        final tempDir = await getTemporaryDirectory();
        final fileName = path.basename(image.imageUrl);
        imageFile = File('${tempDir.path}/$fileName');
        await imageFile.writeAsBytes(response.data);
      } else {
        imageFile = File(image.imageUrl);
      }

      if (await imageFile.exists()) {
        _footerImageCache[image.imageUrl] = imageFile;
      } else {
        print('Footer image file not found: ${image.imageUrl}');
      }
    } catch (e) {
      print('Error caching footer image: $e');
    }
  }
  Future<void> _pickFooterImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedFooterImageFile = File(pickedFile.path);
        _selectedFooterImageUrl = pickedFile.path;
      });
    }
  }

  void _selectFooterImage(int index) {
    if (index < _footerImages.length) {
      setState(() {
        _selectedFooterImageUrl = _footerImages[index].imageUrl;
        _selectedFooterImageFile = null;
      });
    }
  }

  Future<void> _addProtocolImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // setState(() {
      //   _protocolImages.add(ProtocolImage(
      //     imageUrl: pickedFile.path,
      //     id: DateTime.now().millisecondsSinceEpoch.toString(),
      //   ));
      //   _selectedProtocolImageUrl = pickedFile.path;
      // });
    }
  }

  void _selectProtocolImage(int index) {
    if (index < _protocolImages.length) {
      setState(() {
        _selectedProtocolImageUrl = _protocolImages[index].imageUrl;
      });
    }
  }

  Widget _buildProtocolRow() {
    const double boxWidth = 200.0;
    const double boxHeight = 60.0;
    const double boxSpacing = 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Protocol",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ..._protocolImages.map((image) {
                      final isSelected = _selectedProtocolImageUrl == image.imageUrl;
                      final cachedImage = _protocolImageCache[image.imageUrl];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedProtocolImageUrl = null;
                            } else {
                              _selectedProtocolImageUrl = image.imageUrl;
                            }
                          });
                        },
                        child: Container(
                          width: boxWidth,
                          height: boxHeight,
                          margin: EdgeInsets.only(right: boxSpacing),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? SharedColors.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              color: Colors.grey[300],
                              child: cachedImage != null
                                  ? Image.file(
                                cachedImage,
                                fit: BoxFit.contain,
                              )
                                  : image.imageUrl.startsWith('http')
                                  ? CachedNetworkImage(
                                imageUrl: image.imageUrl,
                                fit: BoxFit.contain,
                                placeholder: (context, url) =>
                                    Container(color: Colors.grey[300]),
                                errorWidget: (context, url, error) =>
                                const Icon(Icons.broken_image),
                              )
                                  : Image.file(
                                File(image.imageUrl),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _togglePlayback() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }
  // void _togglePlayback() {
  //   setState(() {
  //     if (_controller.value.isPlaying) {
  //       _controller.pause();
  //       _isPlaying = false;
  //     } else {
  //       _controller.play();
  //       _isPlaying = true;
  //     }
  //   });
  // }

  Future<void> _pickBottomImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _selectedPosition = 'right'; // Default to right when adding new image
        _positionVersion++;
      });
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final storageGranted = await Permission.storage.isGranted;
      final photosGranted = await Permission.photos.isGranted;
      final manageStorageGranted = await Permission.manageExternalStorage.isGranted;

      if (storageGranted || photosGranted || manageStorageGranted) {
        return true;
      }

      final statuses = await [
        Permission.storage,
        Permission.photos,
        if (await Permission.manageExternalStorage.isRestricted)
          Permission.manageExternalStorage,
      ].request();

      if (statuses.values.any((status) => status.isGranted)) {
        return true;
      }

      bool? shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text('We need storage permissions to save your generated images.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Deny'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Allow'),
            ),
          ],
        ),
      );

      if (shouldOpenSettings == true) {
        await openAppSettings();
      }
      return false;
    }
    return true;
  }

  void _editText(String title, String currentValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $title"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter $title"),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      onSave(controller.text);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<File> _simulateVideoProcessing() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/processed_video_${DateTime.now().millisecondsSinceEpoch}.mp4';

    File originalVideoFile;
    if (widget.videoUrl.startsWith('http')) {
      final response = await Dio().get(
        widget.videoUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      originalVideoFile = File('${directory.path}/temp_video.mp4');
      await originalVideoFile.writeAsBytes(response.data);
    } else {
      originalVideoFile = File(widget.videoUrl);
      if (!await originalVideoFile.exists()) {
        throw Exception("Local video file not found: ${widget.videoUrl}");
      }
    }

    final videoWithOverlays = await _createVideoWithOverlays(originalVideoFile);

    if (widget.videoUrl.startsWith('http')) {
      await originalVideoFile.delete();
    }

    return videoWithOverlays;
  }

  Future<File> _createVideoWithOverlays(File originalVideo) async {
    final directory = await getApplicationDocumentsDirectory();
    final outputPath = '${directory.path}/final_video_${DateTime.now().millisecondsSinceEpoch}.mp4';

    await Directory(directory.path).create(recursive: true);

    final overlayImage = await _createCompositeOverlay();

    if (!await overlayImage.exists()) {
      throw Exception("Overlay image not found at ${overlayImage.path}");
    }

    final overlayPath = overlayImage.path;
    final inputVideoPath = originalVideo.path;

    // Set HD resolution (1080p)
    const hdWidth = 1920;
    const hdHeight = 1080;

    final command = '-y -i "$inputVideoPath" -i "$overlayPath" '
        '-filter_complex "[0:v][1]overlay=(W-w)/2:(H-h)/2:format=auto:alpha=1" '
        '-c:v libx264 -preset slower -crf 18 -pix_fmt yuv420p -map 0:a? "$outputPath"';


    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      final outputFile = File(outputPath);
      if (await outputFile.exists()) {
        return outputFile;
      } else {
        throw Exception("Output file not created: $outputPath");
      }
    } else {
      final logs = await session.getAllLogsAsString();
      throw Exception('FFmpeg failed with code $returnCode. Logs:\n$logs');
    }
  }

  void _updatePosition(String position) {
    setState(() {
      _selectedPosition = position.trim().toLowerCase();
      _positionVersion++;
    });
  }

  Widget _buildBottomImageSelector() {
    // Filter images based on current position selection
    final filteredImages = _apiSelfImages.where((image) =>
    image.position.toLowerCase().trim() == _selectedPosition).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Image",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...filteredImages.map((image) {
                      final isSelected = _selectedImage == _selfImageCache[image.imageUrl];
                      final cachedImage = _selfImageCache[image.imageUrl];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedImage = null;
                            } else {
                              _selectedImage = cachedImage;
                              _selectedPosition = image.position.toLowerCase();
                            }
                            _positionVersion++;
                          });
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? SharedColors.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: cachedImage != null
                                ? Image.file(
                              cachedImage,
                              fit: BoxFit.cover,
                            )
                                : image.imageUrl.startsWith('http')
                                ? CachedNetworkImage(
                              imageUrl: image.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Container(color: Colors.grey[300]),
                              errorWidget: (context, url, error) =>
                              const Icon(Icons.broken_image),
                            )
                                : Image.file(
                              File(image.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  Future<File> _createCompositeOverlay() async {
    try {
      if (!_controller.value.isInitialized) {
        throw Exception("Video controller not initialized");
      }

      final videoWidth = _controller.value.size.width.toInt();
      final videoHeight = _controller.value.size.height.toInt();
      final overlayImage = img.Image(width: videoWidth, height: videoHeight, numChannels: 4);
      img.fill(overlayImage, color: img.ColorRgba8(0, 0, 0, 0));

      int footerHeight = 0;

      // Protocol Banner (Top)
      if (_selectedProtocolImageUrl != null) {
        try {
          Uint8List bannerBytes;
          if (_selectedProtocolImageUrl!.startsWith('http')) {
            final response = await Dio().get(
              _selectedProtocolImageUrl!,
              options: Options(responseType: ResponseType.bytes),
            );
            bannerBytes = Uint8List.fromList(response.data);
          } else {
            bannerBytes = await File(_selectedProtocolImageUrl!).readAsBytes();
          }

          if (bannerBytes.isNotEmpty) {
            final bannerImage = img.decodeImage(bannerBytes);
            if (bannerImage != null) {
              final scaleFactor = videoWidth / bannerImage.width;
              final targetHeightMaintained = (bannerImage.height * scaleFactor).toInt();
              final resizedBanner = img.copyResize(
                bannerImage,
                width: videoWidth,
                height: targetHeightMaintained,
              );
              img.compositeImage(overlayImage, resizedBanner, dstX: 0, dstY: 0);
            }
          }
        } catch (e) {
          debugPrint('Error processing protocol image: $e');
        }
      }

      // Footer (Bottom)
      if (_selectedFooterImageUrl != null || _selectedFooterImageFile != null) {
        try {
          Uint8List footerBytes;
          if (_selectedFooterImageFile != null) {
            footerBytes = await _selectedFooterImageFile!.readAsBytes();
          } else if (_selectedFooterImageUrl!.startsWith('http')) {
            final response = await Dio().get(
              _selectedFooterImageUrl!,
              options: Options(responseType: ResponseType.bytes),
            );
            footerBytes = Uint8List.fromList(response.data);
          } else {
            footerBytes = await File(_selectedFooterImageUrl!).readAsBytes();
          }

          if (footerBytes.isNotEmpty) {
            final footerImage = img.decodeImage(footerBytes);
            if (footerImage != null) {
              final scaleFactor = videoWidth / footerImage.width;
              final targetHeightMaintained = (footerImage.height * scaleFactor).toInt();
              footerHeight = targetHeightMaintained;

              final resizedFooter = img.copyResize(
                footerImage,
                width: videoWidth,
                height: footerHeight,
              );

              img.compositeImage(
                overlayImage,
                resizedFooter,
                dstX: 0,
                dstY: videoHeight - footerHeight,
              );
            }
          }
        } catch (e) {
          debugPrint('Error processing footer image: $e');
        }
      } else {
        // No footer image, draw colored container
        final containerHeight = (videoHeight * 0.10).toInt();
        footerHeight = containerHeight;

        final containerColor = img.ColorRgba8(
          _nameContainerColor.red,
          _nameContainerColor.green,
          _nameContainerColor.blue,
          (_nameContainerColor.opacity * 255).toInt(),
        );
        img.fillRect(
          overlayImage,
          x1: 0,
          y1: videoHeight - containerHeight,
          x2: videoWidth,
          y2: videoHeight,
          color: containerColor,
        );
      }

      // Text Section
      final containerY = videoHeight - footerHeight;
      const padding = 3;

      final nameTextColor = img.ColorRgba8(
          _nameTextColor.red, _nameTextColor.green, _nameTextColor.blue, 255);
      final designationTextColor = img.ColorRgba8(
          _designationTextColor.red, _designationTextColor.green, _designationTextColor.blue, 255);
      final dividerColor = img.ColorRgba8(
          _dividerColor.red, _dividerColor.green, _dividerColor.blue, _dividerColor.alpha);

      final baseFont = videoWidth >= 720 ? img.arial48 : img.arial24;
      final textY = containerY + ((footerHeight - baseFont.lineHeight) / 2).toInt();

      // Divider
      final dividerX = videoWidth ~/ 2;
      img.drawLine(
        overlayImage,
        x1: dividerX,
        y1: containerY + 5,
        x2: dividerX,
        y2: videoHeight - 5,
        color: dividerColor,
        thickness: 2,
      );

      // Name and Designation
      img.drawString(
        overlayImage,
        _name,
        font: baseFont,
        x: padding,
        y: textY,
        color: nameTextColor,
      );
      img.drawString(
        overlayImage,
        _designation,
        font: baseFont,
        x: dividerX + padding,
        y: textY,
        color: designationTextColor,
      );

      // Bottom Image (Right/Left Above Footer)
      if (_selectedImage != null) {
        final bottomImageBytes = await _selectedImage!.readAsBytes();
        final bottomImage = img.decodeImage(bottomImageBytes);
        if (bottomImage != null) {
          final maxImageHeight = (videoHeight * 0.40).toInt();
          final resizedImage = img.copyResize(
            bottomImage,
            height: maxImageHeight,
          );

          final dstX = _selectedPosition == 'left' ? 0 : videoWidth - resizedImage.width;
          final dstY = videoHeight - footerHeight - resizedImage.height;

          img.compositeImage(
            overlayImage,
            resizedImage,
            dstX: dstX,
            dstY: dstY,
          );
        }
      }

      // Save the final overlay
      final tempDir = await getTemporaryDirectory();
      final overlayPath = '${tempDir.path}/overlay_${DateTime.now().millisecondsSinceEpoch}.png';
      final overlayFile = File(overlayPath);
      await overlayFile.writeAsBytes(img.encodePng(overlayImage));

      return overlayFile;
    } catch (e) {
      debugPrint('Error creating overlay: $e');
      rethrow;
    }
  }

  Future<void> _saveVideoToGallery(File videoFile) async {
    try {
      if (!await videoFile.exists() || await videoFile.length() == 0) {
        throw Exception("Video file is empty or doesn't exist");
      }

      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception("Storage permission not granted");
      }

      final result = await PhotoManager.editor.saveVideo(
        videoFile,
        title: "polyposter_video_${DateTime.now().millisecondsSinceEpoch}.mp4",
      );

      if (result == null) {
        throw Exception("Failed to save to gallery");
      }

      final downloadsDirectory = Platform.isAndroid
          ? Directory('/storage/emulated/0/Download')
          : await getApplicationDocumentsDirectory();

      if (!await downloadsDirectory.exists()) {
        await downloadsDirectory.create(recursive: true);
      }

      final fileName = 'polyposter_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final savedFile = File(path.join(downloadsDirectory.path, fileName));
      await videoFile.copy(savedFile.path);

      setState(() {
        _generatedVideoFile = savedFile;
        _generatedVideoController = VideoPlayerController.file(savedFile)
          ..initialize().then((_) {
            setState(() {
              _generatedVideoController.play();
            });
          });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video with all edits saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving video: ${e.toString()}')),
      );
    }
  }


  void _startVideoProcessing() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _progressValue = 0.1; // Start at 10%
    });

    // Timer to increase +10% every 2 seconds until 90%
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isProcessing) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_progressValue < 0.9) {
          _progressValue += 0.1;
          if (_progressValue > 0.9) _progressValue = 0.9;
        }
      });
    });

    try {
      // Actual video generation
      final processedFile = await _simulateVideoProcessing();

      // Save video once generated
      await _saveVideoToGallery(processedFile);

      // Force 100% after success
      setState(() {
        _progressValue = 1.0;
        _isProcessing = false;
      });

      // Show popup immediately
      _showGeneratedVideoPopup();
      _showDownloadSuccessPopup();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video processing complete!')),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing video: $e')),
      );
    }
  }



  Future<void> _shareVideo(String platform) async {
    if (_generatedVideoFile == null) return;

    final text = ' ';

    try {
      if (platform == 'other') {
        await Share.shareXFiles(
          [XFile(_generatedVideoFile!.path)],
          text: text,
        );
      } else {
        await Share.shareXFiles(
          [XFile(_generatedVideoFile!.path)],
          text: text,
          subject: 'My PolyPoster Video',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing video: $e')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> _selectContainerColor() async {
    final Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Container Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _nameContainerColor,
            onColorChanged: (color) {
              _nameContainerColor = color;
            },
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _nameContainerColor),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (pickedColor != null) {
      setState(() {
        _nameContainerColor = pickedColor;
      });
    }
  }

  Future<void> _selectNameTextColor() async {
    final Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Name Text Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _nameTextColor,
            onColorChanged: (color) {
              _nameTextColor = color;
            },
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _nameTextColor),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (pickedColor != null) {
      setState(() {
        _nameTextColor = pickedColor;
      });
    }
  }

  Future<void> _selectDesignationTextColor() async {
    final Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Designation Text Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _designationTextColor,
            onColorChanged: (color) {
              _designationTextColor = color;
            },
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _designationTextColor),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (pickedColor != null) {
      setState(() {
        _designationTextColor = pickedColor;
      });
    }
  }

  Future<void> _selectDividerColor() async {
    final Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Divider Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _dividerColor,
            onColorChanged: (color) {
              _dividerColor = color;
            },
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _dividerColor),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (pickedColor != null) {
      setState(() {
        _dividerColor = pickedColor;
      });
    }
  }

  void _showTextStyleDialog() {
    Color tempContainerColor = _nameContainerColor;
    Color tempNameColor = _nameTextColor;
    Color tempDesignationColor = _designationTextColor;
    Color tempDividerColor = _dividerColor;
    bool tempNameBold = _nameFontWeight == FontWeight.bold;
    bool tempNameItalic = _nameItalic;
    bool tempDesignationBold = _designationFontWeight == FontWeight.bold;
    bool tempDesignationItalic = _designationItalic;
    double tempNameFontSize = _nameFontSize;
    double tempDesignationFontSize = _designationFontSize;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Text & Container Style'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // LIVE PREVIEW
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: tempContainerColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name Preview',
                            style: TextStyle(
                              color: tempNameColor,
                              fontSize: tempNameFontSize,
                              fontWeight: tempNameBold ? FontWeight.bold : FontWeight.normal,
                              fontStyle: tempNameItalic ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Divider(
                            color: tempDividerColor,
                            thickness: 2,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Designation Preview',
                            style: TextStyle(
                              color: tempDesignationColor,
                              fontSize: tempDesignationFontSize,
                              fontWeight: tempDesignationBold ? FontWeight.bold : FontWeight.normal,
                              fontStyle: tempDesignationItalic ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Container Color
                    ListTile(
                      title: const Text('Container Color'),
                      trailing: GestureDetector(
                        onTap: () async {
                          final Color? pickedColor = await showDialog<Color>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Select Container Color'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: tempContainerColor,
                                  onColorChanged: (color) {
                                    setState(() => tempContainerColor = color);
                                  },
                                  showLabel: true,
                                  pickerAreaHeightPercent: 0.8,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, tempContainerColor),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          if (pickedColor != null) {
                            setState(() => tempContainerColor = pickedColor);
                          }
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: tempContainerColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    // Divider Color
                    ListTile(
                      title: const Text('Divider Color'),
                      trailing: GestureDetector(
                        onTap: () async {
                          final Color? pickedColor = await showDialog<Color>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Select Divider Color'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: tempDividerColor,
                                  onColorChanged: (color) {
                                    setState(() => tempDividerColor = color);
                                  },
                                  showLabel: true,
                                  pickerAreaHeightPercent: 0.8,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, tempDividerColor),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          if (pickedColor != null) {
                            setState(() => tempDividerColor = pickedColor);
                          }
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: tempDividerColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    // Name Text Style
                    const SizedBox(height: 16),
                    const Text('Name Text Style', style: TextStyle(fontWeight: FontWeight.bold)),
                    ListTile(
                      title: const Text('Name Color'),
                      trailing: GestureDetector(
                        onTap: () async {
                          final Color? pickedColor = await showDialog<Color>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Select Name Color'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: tempNameColor,
                                  onColorChanged: (color) {
                                    setState(() => tempNameColor = color);
                                  },
                                  showLabel: true,
                                  pickerAreaHeightPercent: 0.8,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, tempNameColor),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          if (pickedColor != null) {
                            setState(() => tempNameColor = pickedColor);
                          }
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: tempNameColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: tempNameBold,
                          onChanged: (value) => setState(() => tempNameBold = value!),
                        ),
                        const Text('Bold'),
                        const SizedBox(width: 20),
                        Checkbox(
                          value: tempNameItalic,
                          onChanged: (value) => setState(() => tempNameItalic = value!),
                        ),
                        const Text('Italic'),
                      ],
                    ),
                    Slider(
                      value: tempNameFontSize,
                      min: 10,
                      max: 30,
                      onChanged: (value) => setState(() => tempNameFontSize = value),
                      label: 'Font Size: ${tempNameFontSize.toInt()}',
                    ),
                    // Designation Text Style
                    const SizedBox(height: 16),
                    const Text('Designation Text Style', style: TextStyle(fontWeight: FontWeight.bold)),
                    ListTile(
                      title: const Text('Designation Color'),
                      trailing: GestureDetector(
                        onTap: () async {
                          final Color? pickedColor = await showDialog<Color>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Select Designation Color'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: tempDesignationColor,
                                  onColorChanged: (color) {
                                    setState(() => tempDesignationColor = color);
                                  },
                                  showLabel: true,
                                  pickerAreaHeightPercent: 0.8,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, tempDesignationColor),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          if (pickedColor != null) {
                            setState(() => tempDesignationColor = pickedColor);
                          }
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: tempDesignationColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: tempDesignationBold,
                          onChanged: (value) => setState(() => tempDesignationBold = value!),
                        ),
                        const Text('Bold'),
                        const SizedBox(width: 20),
                        Checkbox(
                          value: tempDesignationItalic,
                          onChanged: (value) => setState(() => tempDesignationItalic = value!),
                        ),
                        const Text('Italic'),
                      ],
                    ),
                    Slider(
                      value: tempDesignationFontSize,
                      min: 10,
                      max: 30,
                      onChanged: (value) => setState(() => tempDesignationFontSize = value),
                      label: 'Font Size: ${tempDesignationFontSize.toInt()}',
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _nameContainerColor = tempContainerColor;
                  _nameTextColor = tempNameColor;
                  _designationTextColor = tempDesignationColor;
                  _dividerColor = tempDividerColor;
                  _nameFontWeight = tempNameBold ? FontWeight.bold : FontWeight.normal;
                  _nameItalic = tempNameItalic;
                  _designationFontWeight = tempDesignationBold ? FontWeight.bold : FontWeight.normal;
                  _designationItalic = tempDesignationItalic;
                  _nameFontSize = tempNameFontSize;
                  _designationFontSize = tempDesignationFontSize;
                });
                Navigator.pop(context);
              },
              child: const Text('APPLY'),
            ),
          ],
        );
      },
    );
  }

// Helper function for color picker
  Future<Color?> pickColor(BuildContext context, Color currentColor) async {
    Color temp = currentColor;
    return showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pick Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (c) => temp = c,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, temp), child: Text('Select')),
        ],
      ),
    );
  }

  Widget _buildCustomControls() {
    final position = _controller.value.position;
    final duration = _controller.value.duration;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 20,
            ),
            onPressed: _togglePlayback,
          ),
          Text(
            _formatDuration(position),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          Expanded(
            child: Slider(
              activeColor: Colors.white,
              inactiveColor: Colors.white30,
              min: 0,
              max: duration.inSeconds.toDouble(),
              value: position.inSeconds.clamp(0, duration.inSeconds).toDouble(),
              onChanged: (value) {
                _controller.seekTo(Duration(seconds: value.toInt()));
              },
            ),
          ),
          Text(
            _formatDuration(duration),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.volume_up, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  Widget _buildResponsiveButton(String text, VoidCallback onPressed) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120), // Minimum width to maintain design
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: SharedColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(120, 48), // Maintain minimum touch target
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildShareButton(String imageName, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                'assets/images/$imageName.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.share),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFooterImageRow() {
    const double boxWidth = 200.0;
    const double boxHeight = 60.0;
    const double boxSpacing = 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Name & Designation",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ..._footerImages.map((image) {
                      final isSelected = _selectedFooterImageUrl == image.imageUrl;
                      final cachedImage = _footerImageCache[image.imageUrl];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedFooterImageUrl = null;
                              _selectedFooterImageFile = null;
                            } else {
                              _selectedFooterImageUrl = image.imageUrl;
                              _selectedFooterImageFile = null;
                            }
                          });
                        },
                        child: Container(
                          width: boxWidth,
                          height: boxHeight,
                          margin: EdgeInsets.only(right: boxSpacing),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? SharedColors.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              color: Colors.grey[300],
                              child: cachedImage != null
                                  ? Image.file(
                                cachedImage,
                                fit: BoxFit.contain,
                              )
                                  : image.imageUrl.startsWith('http')
                                  ? CachedNetworkImage(
                                imageUrl: image.imageUrl,
                                fit: BoxFit.contain,
                                placeholder: (context, url) =>
                                    Container(color: Colors.grey[300]),
                                errorWidget: (context, url, error) =>
                                const Icon(Icons.broken_image),
                              )
                                  : Image.file(
                                File(image.imageUrl),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.pageTitle ?? "Video Editor",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: SharedColors.primary,
        elevation: 0,
        toolbarHeight: kToolbarHeight,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // In the build method where you define the video player container
              Container(
                decoration: BoxDecoration(
                  color: SharedColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: _controller.value.isInitialized
                    ? Column(
                  children: [
                    // Calculate dimensions based on aspect ratio
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const double aspectRatio = 5 / 5.2;
                        final double canvasWidth = constraints.maxWidth;
                        final double canvasHeight = canvasWidth / aspectRatio;

                        final double protocolHeight = canvasHeight * 0.20;
                        final double profileImgHeight = canvasHeight * 0.40;
                        final double profileImgWidth = profileImgHeight * 0.9;
                        final double footerHeight = canvasHeight * 0.10;

                        return SizedBox(
                          width: canvasWidth,
                          height: canvasHeight,
                          child: Stack(
                            children: [
                              // Video player takes full canvas
                              SizedBox(
                                width: canvasWidth,
                                height: canvasHeight,
                                child: VideoPlayer(_controller),
                              ),

                              // Protocol banner (20% of height)
                              if (_selectedProtocolImageUrl != null)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  height: protocolHeight,
                                  child: _selectedProtocolImageUrl!.startsWith('http')
                                      ? Image.network(
                                    _selectedProtocolImageUrl!,
                                    width: double.infinity,
                                    height: protocolHeight,
                                    fit: BoxFit.cover,
                                  )
                                      : Image.file(
                                    File(_selectedProtocolImageUrl!),
                                    width: double.infinity,
                                    height: protocolHeight,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                              // Footer (10% of height)
                              if (_selectedFooterImageUrl != null || _selectedFooterImageFile != null)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  height: footerHeight,
                                  child: _selectedFooterImageFile != null
                                      ? Image.file(
                                    _selectedFooterImageFile!,
                                    width: double.infinity,
                                    height: footerHeight,
                                    fit: BoxFit.cover,
                                  )
                                      : _selectedFooterImageUrl!.startsWith('http')
                                      ? Image.network(
                                    _selectedFooterImageUrl!,
                                    width: double.infinity,
                                    height: footerHeight,
                                    fit: BoxFit.cover,
                                  )
                                      : Image.file(
                                    File(_selectedFooterImageUrl!),
                                    width: double.infinity,
                                    height: footerHeight,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                              // Profile image (40% of height)
                              if (_selectedImage != null)
                                Positioned(
                                  bottom: footerHeight,
                                  right: _selectedPosition == 'right' ? 0 : null,
                                  left: _selectedPosition == 'left' ? 0 : null,
                                  width: profileImgWidth,
                                  height: profileImgHeight,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),

                              // Name/designation container
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                height: footerHeight,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Center(
                                    child: IntrinsicHeight(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () => _editText("Name", _name, (value) => _name = value),
                                            child: Text(
                                              _name,
                                              style: TextStyle(
                                                fontSize: _nameFontSize,
                                                fontWeight: _nameFontWeight,
                                                color: _nameTextColor,
                                              ),
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            width: 2,
                                            height: 24,
                                            color: _dividerColor,
                                            margin: const EdgeInsets.symmetric(vertical: 2),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => _editText("Designation", _designation, (value) => _designation = value),
                                            child: Text(
                                              _designation,
                                              style: TextStyle(
                                                fontSize: _designationFontSize,
                                                fontWeight: _designationFontWeight,
                                                color: _designationTextColor,
                                              ),
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    _buildCustomControls(),
                  ],
                )
                    : const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),

              const SizedBox(height: 20),
              if (_isProcessing) ...[
                LinearProgressIndicator(
                  value: _progressValue,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(SharedColors.primary),
                  minHeight: 10,
                ),
                const SizedBox(height: 8),
                Text(
                  'Processing: ${(_progressValue * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBottomImageSelector(),
                  const SizedBox(height: 12),
                  _buildFooterImageRow(),
                  const SizedBox(height: 12),
                  _buildProtocolRow(),
                ],
              ),
              const SizedBox(height: 10),
              // Row(
              //   children: [
              //     Expanded(
              //       child: _buildResponsiveButton("Edit Name", () => _editText("Name", _name, (value) => _name = value)),
              //     ),
              //     const SizedBox(width: 10),
              //     Expanded(
              //       child: _buildResponsiveButton("Edit Designation", () => _editText("Designation", _designation, (value) => _designation = value)),
              //     ),
              //     const SizedBox(width: 10),
              //     _buildResponsiveButton("Text Style Options", _showTextStyleDialog),
              //   ],
              // ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isProcessing ? Colors.grey : SharedColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isProcessing ? null : _startVideoProcessing,
                  child: Text(
                    _isProcessing ? 'Processing...' : 'Generate Video',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_generatedVideoFile != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AspectRatio(
                    aspectRatio: _generatedVideoController.value.aspectRatio,
                    child: VideoPlayer(_generatedVideoController),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(
                        _generatedVideoController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: SharedColors.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_generatedVideoController.value.isPlaying) {
                            _generatedVideoController.pause();
                          } else {
                            _generatedVideoController.play();
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.replay, color: SharedColors.primary),
                      onPressed: () {
                        _generatedVideoController.seekTo(Duration.zero);
                        _generatedVideoController.play();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Share your video:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShareButton("whatsapp", "WhatsApp", () => _shareVideo('whatsapp')),
                    _buildShareButton("instagram", "Instagram", () => _shareVideo('instagram')),
                    _buildShareButton("facebook", "Facebook", () => _shareVideo('facebook')),
                    _buildShareButton("x", "X", () => _shareVideo('x')),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showGeneratedVideoPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          // Use Dialog instead of AlertDialog for more control
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: _generatedVideoController.value.aspectRatio,
                  child: VideoPlayer(_generatedVideoController),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(
                        _generatedVideoController.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: SharedColors.primary,
                        size: 30, // Slightly larger icons
                      ),
                      onPressed: () {
                        setState(() {
                          if (_generatedVideoController.value.isPlaying) {
                            _generatedVideoController.pause();
                          } else {
                            _generatedVideoController.play();
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.replay,
                          color: SharedColors.primary, size: 30),
                      onPressed: () {
                        _generatedVideoController.seekTo(Duration.zero);
                        _generatedVideoController.play();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Share your video:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShareButton("whatsapp", "WhatsApp", () {
                      Navigator.pop(context);
                      _shareVideo('whatsapp');
                    }),
                    _buildShareButton("instagram", "Instagram", () {
                      Navigator.pop(context);
                      _shareVideo('instagram');
                    }),
                    _buildShareButton("facebook", "Facebook", () {
                      Navigator.pop(context);
                      _shareVideo('facebook');
                    }),
                    _buildShareButton("x", "X", () => _shareVideo('x')),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _showDownloadSuccessPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottie/success.json',
                  width: 220,
                  height: 220,
                  repeat: true, // 👈 keep playing until OK is pressed
                ),
                const SizedBox(height: 12),
                const Text(
                  "4K HD video saved to gallery and downloads!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: SharedColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SharedColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


