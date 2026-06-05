import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../data/create_route_request.dart';
import '../data/route_photo.dart';
import '../data/route_photo_picker.dart';
import '../widgets/route_media_image.dart';
import 'route_feed_controller.dart';

class CreateRouteScreen extends StatefulWidget {
  const CreateRouteScreen({super.key});

  @override
  State<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends State<CreateRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _photoPicker = RoutePhotoPicker();
  final List<_StopFormData> _stops = [_StopFormData()];
  RoutePhoto? _coverPhoto;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    for (final stop in _stops) {
      stop.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<RouteFeedController>().isCreatingRoute;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni rota'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            children: [
              Text(
                'Rota bilgileri',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 12),
              _CoverImagePicker(
                imageSource: _coverPhoto?.source,
                isEnabled: !isSubmitting,
                onPick: _pickCoverImage,
                onRemove: () => setState(() => _coverPhoto = null),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.route_outlined),
                ),
                validator: _requiredValidator('Başlık boş geçilemez.'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                validator: _requiredValidator('Açıklama boş geçilemez.'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Estimated Budget',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  if (amount == null) {
                    return 'Bütçe boş geçilemez.';
                  }
                  if (amount <= 0) {
                    return "Bütçe 0'dan büyük olmalı.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Duraklar',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: isSubmitting ? null : _addStop,
                    icon: const Icon(Icons.add_location_alt_outlined),
                    label: const Text('Yeni durak ekle'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (var index = 0; index < _stops.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StopCard(
                    key: ValueKey(_stops[index]),
                    index: index,
                    stop: _stops[index],
                    canRemove: _stops.length > 1,
                    isEnabled: !isSubmitting,
                    onRemove: () => _removeStop(index),
                    onPickImages: () => _pickStopImages(index),
                    onRemoveImage: (photoIndex) =>
                        _removeStopImage(index, photoIndex),
                  ),
                ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: isSubmitting ? null : _submit,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(isSubmitting ? 'Kaydediliyor' : 'Rotayı kaydet'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  FormFieldValidator<String> _requiredValidator(String message) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  void _addStop() {
    setState(() => _stops.add(_StopFormData(dayNumber: _stops.length + 1)));
  }

  void _removeStop(int index) {
    final stop = _stops.removeAt(index);
    stop.dispose();
    setState(() {
      for (var i = 0; i < _stops.length; i++) {
        if (_stops[i].dayController.text.trim().isEmpty) {
          _stops[i].dayController.text = '${i + 1}';
        }
      }
    });
  }

  Future<void> _pickCoverImage() async {
    try {
      final photo = await _photoPicker.pickCoverPhoto();
      if (photo == null) return;

      setState(() => _coverPhoto = photo);
    } on RoutePhotoPickerException catch (error) {
      _showSnack(_galleryErrorMessage(error));
    }
  }

  Future<void> _pickStopImages(int stopIndex) async {
    try {
      final photos = await _photoPicker.pickStopPhotos();
      if (photos.isEmpty) return;

      setState(() {
        _stops[stopIndex].photos.addAll(photos);
      });
    } on RoutePhotoPickerException catch (error) {
      _showSnack(_galleryErrorMessage(error));
    }
  }

  void _removeStopImage(int stopIndex, int photoIndex) {
    setState(() {
      final photo = _stops[stopIndex].photos.removeAt(photoIndex);
      RoutePhotoMemoryStore.release(photo.source);
    });
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final request = CreateRouteRequest(
      title: _titleController.text,
      description: _descriptionController.text,
      estimatedBudget: double.parse(_budgetController.text.trim()),
      stops: _stops
          .map(
            (stop) => CreateRouteStopRequest(
              cityName: stop.cityController.text,
              stopName: stop.nameController.text,
              dayNumber: int.parse(stop.dayController.text.trim()),
              notes: stop.notesController.text,
              photos: List<RoutePhoto>.unmodifiable(stop.photos),
            ),
          )
          .toList(),
      coverPhoto: _coverPhoto,
    );

    try {
      await context.read<RouteFeedController>().createRoute(request);
      _clearForm();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      _showSnack(error.message);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Rota kaydedilemedi. Lütfen tekrar deneyin.');
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _budgetController.clear();
    _coverPhoto = null;
    for (final stop in _stops) {
      stop.dispose();
    }
    _stops
      ..clear()
      ..add(_StopFormData());
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _galleryErrorMessage(RoutePhotoPickerException error) {
    if (error.isPermissionDenied) {
      return 'Galeri izni verilmedi. Fotoğraf eklemek için izinleri kontrol edin.';
    }
    return 'Galeri açılamadı. Lütfen tekrar deneyin.';
  }
}

class _CoverImagePicker extends StatelessWidget {
  const _CoverImagePicker({
    required this.imageSource,
    required this.isEnabled,
    required this.onPick,
    required this.onRemove,
  });

  final String? imageSource;
  final bool isEnabled;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageSource == null)
                ColoredBox(
                  color: AppTheme.primary.withValues(alpha: 0.06),
                  child: const Center(
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 42,
                      color: AppTheme.primary,
                    ),
                  ),
                )
              else
                RouteMediaImage(
                  source: imageSource,
                  fallbackAsset: 'assets/images/aegean-wonders.jpg',
                ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Row(
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: isEnabled ? onPick : null,
                      icon: const Icon(Icons.photo_library_outlined),
                      label:
                          Text(imageSource == null ? 'Kapak seç' : 'Değiştir'),
                    ),
                    const Spacer(),
                    if (imageSource != null)
                      IconButton.filledTonal(
                        tooltip: 'Kapağı kaldır',
                        onPressed: isEnabled ? onRemove : null,
                        icon: const Icon(Icons.close_rounded),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StopCard extends StatelessWidget {
  const _StopCard({
    super.key,
    required this.index,
    required this.stop,
    required this.canRemove,
    required this.isEnabled,
    required this.onRemove,
    required this.onPickImages,
    required this.onRemoveImage,
  });

  final int index;
  final _StopFormData stop;
  final bool canRemove;
  final bool isEnabled;
  final VoidCallback onRemove;
  final VoidCallback onPickImages;
  final ValueChanged<int> onRemoveImage;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primary,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Durak ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: 'Durağı çıkar',
                  onPressed: canRemove && isEnabled ? onRemove : null,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: stop.cityController,
              enabled: isEnabled,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'City Name',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Şehir boş geçilemez.';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: stop.nameController,
              enabled: isEnabled,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Stop Name',
                prefixIcon: Icon(Icons.place_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Durak adı boş geçilemez.';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: stop.dayController,
              enabled: isEnabled,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Day Number',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              validator: (value) {
                final day = int.tryParse(value?.trim() ?? '');
                if (day == null) {
                  return 'Gün boş geçilemez.';
                }
                if (day <= 0) {
                  return "Gün 0'dan büyük olmalı.";
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: stop.notesController,
              enabled: isEnabled,
              minLines: 2,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'Notes',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.edit_note_outlined),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isEnabled ? onPickImages : null,
                    icon: const Icon(Icons.collections_outlined),
                    label: const Text('Durak fotoğrafları ekle'),
                  ),
                ),
              ],
            ),
            if (stop.photos.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 112,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: stop.photos.length,
                  itemBuilder: (context, photoIndex) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: photoIndex == stop.photos.length - 1 ? 0 : 10,
                      ),
                      child: _SelectedPhotoPreview(
                        imageSource: stop.photos[photoIndex].source,
                        onRemove:
                            isEnabled ? () => onRemoveImage(photoIndex) : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SelectedPhotoPreview extends StatelessWidget {
  const _SelectedPhotoPreview({
    required this.imageSource,
    required this.onRemove,
  });

  final String imageSource;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 112,
        height: 112,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RouteMediaImage(
              source: imageSource,
              fallbackAsset: 'assets/images/aegean-wonders.jpg',
            ),
            Positioned(
              right: 6,
              top: 6,
              child: IconButton.filled(
                tooltip: 'Fotoğrafı kaldır',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.58),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.square(30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StopFormData {
  _StopFormData({int dayNumber = 1}) {
    dayController.text = dayNumber.toString();
  }

  final cityController = TextEditingController();
  final nameController = TextEditingController();
  final dayController = TextEditingController();
  final notesController = TextEditingController();
  final List<RoutePhoto> photos = [];

  void dispose() {
    cityController.dispose();
    nameController.dispose();
    dayController.dispose();
    notesController.dispose();
  }
}
