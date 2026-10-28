import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/app_providers.dart';

class ImageUploadButton extends ConsumerStatefulWidget {
  final String purpose;
  final ValueChanged<String> onUploaded;
  const ImageUploadButton({
    super.key,
    required this.purpose,
    required this.onUploaded,
  });
  @override
  ConsumerState<ImageUploadButton> createState() => _ImageUploadButtonState();
}

class _ImageUploadButtonState extends ConsumerState<ImageUploadButton> {
  bool _busy = false;
  Future<void> _upload() async {
    setState(() => _busy = true);
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file == null) return;
      if (await file.length() > 10 * 1024 * 1024) {
        throw StateError('Choose an image smaller than 10 MB.');
      }
      final url = await ref
          .read(mediaRepositoryProvider)
          .upload(await file.readAsBytes(), purpose: widget.purpose);
      if (mounted) widget.onUploaded(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to upload image: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: _busy ? null : _upload,
    icon: _busy
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.add_photo_alternate_outlined),
    label: Text(
      _busy
          ? 'Uploading…'
          : widget.purpose == 'cover'
          ? 'Upload Cover'
          : 'Upload Profile Photo',
    ),
  );
}
